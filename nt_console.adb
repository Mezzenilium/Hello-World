-----------------------------------------------------------------------
--
--  File:        nt_console.adb
--  Description: Win95/NT console support
--  Rev:         0.3
--  Date:        08-june-1999
--  Author:      Jerry van Dijk
--  Mail:        jdijk@acm.org
--
--  Copyright (c) Jerry van Dijk, 1997, 1998, 1999
--  Billie Holidaystraat 28
--  2324 LK  LEIDEN
--  THE NETHERLANDS
--  tel int + 31 71 531 43 65
--
--  Permission granted to use for any purpose, provided this copyright
--  remains attached and unmodified.
--
--  THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
--  IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
--  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--
-----------------------------------------------------------------------

pragma C_Pass_By_Copy (128);

with Interfaces; use Interfaces;
with Text_IO;    use Text_IO;
--with Text_IO.Integer_IO;    use Text_IO.Integer_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
package body Nt_Console is

   pragma Linker_Options ("-luser32");

   ---------------------
   -- WIN32 INTERFACE --
   ---------------------

   Beep_Error : exception;
   Fill_Char_Error : exception;
   Cursor_Get_Error : exception;
   Cursor_Set_Error : exception;
   Cursor_Pos_Error : exception;
   Buffer_Info_Error : exception;
   Set_Attribute_Error : exception;
   Invalid_Handle_Error : exception;
   Fill_Attribute_Error : exception;
   Cursor_Position_Error : exception;

   subtype Dword is Unsigned_32;
   subtype Handle is Unsigned_32;
   subtype Word is Unsigned_16;
   subtype Short is Short_Integer;
   subtype Winbool is Integer;

   type Lpdword is access all Dword;
   pragma Convention (C, Lpdword);

   type Nibble is mod 2 ** 4;
   for Nibble'Size use 4;

   type Attribute is record
      Foreground : Nibble;
      Background : Nibble;
      Reserved   : Unsigned_8 := 0;
   end record;

   for Attribute use record
      Foreground at 0 range 0 .. 3;
      Background at 0 range 4 .. 7;
      Reserved   at 1 range 0 .. 7;
   end record;

   for Attribute'Size use 16;
   pragma Convention (C, Attribute);

   type Coord is record
      X : Short;
      Y : Short;
   end record;
   pragma Convention (C, Coord);

   type Small_Rect is record
      Left   : Short;
      Top    : Short;
      Right  : Short;
      Bottom : Short;
   end record;
   pragma Convention (C, Small_Rect);

   type Console_Screen_Buffer_Info is record
      Size       : Coord;
      Cursor_Pos : Coord;
      Attrib     : Attribute;
      Window     : Small_Rect;
      Max_Size   : Coord;
   end record;
   pragma Convention (C, Console_Screen_Buffer_Info);

   type Pconsole_Screen_Buffer_Info is access all Console_Screen_Buffer_Info;
   pragma Convention (C, Pconsole_Screen_Buffer_Info);

   type Console_Cursor_Info is record
      Size    : Dword;
      Visible : Winbool;
   end record;
   pragma Convention (C, Console_Cursor_Info);

   type Pconsole_Cursor_Info is access all Console_Cursor_Info;
   pragma Convention (C, Pconsole_Cursor_Info);

   function Getch return Integer;
   pragma Import (C, Getch, "_getch");

   function Kbhit return Integer;
   pragma Import (C, Kbhit, "_kbhit");

   function Messagebeep (Kind : Dword) return Dword;
   pragma Import (Stdcall, Messagebeep, "MessageBeep");

   function Getstdhandle (Value : Dword) return Handle;
   pragma Import (Stdcall, Getstdhandle, "GetStdHandle");

   function Getconsolecursorinfo
     (Buffer : Handle;
      Cursor : Pconsole_Cursor_Info)
      return   Winbool;
   pragma Import (Stdcall, Getconsolecursorinfo, "GetConsoleCursorInfo");

   function Setconsolecursorinfo
     (Buffer : Handle;
      Cursor : Pconsole_Cursor_Info)
      return   Winbool;
   pragma Import (Stdcall, Setconsolecursorinfo, "SetConsoleCursorInfo");

   function Setconsolecursorposition
     (Buffer : Handle;
      Pos    : Coord)
      return   Dword;
   pragma Import
     (Stdcall,
      Setconsolecursorposition,
      "SetConsoleCursorPosition");

   function Setconsoletextattribute
     (Buffer : Handle;
      Attr   : Attribute)
      return   Dword;
   pragma Import
     (Stdcall,
      Setconsoletextattribute,
      "SetConsoleTextAttribute");

   function Getconsolescreenbufferinfo
     (Buffer : Handle;
      Info   : Pconsole_Screen_Buffer_Info)
      return   Dword;
   pragma Import
     (Stdcall,
      Getconsolescreenbufferinfo,
      "GetConsoleScreenBufferInfo");

   function Fillconsoleoutputcharacter
     (Console : Handle;
      Char    : Character;
      Length  : Dword;
      Start   : Coord;
      Written : Lpdword)
      return    Dword;
   pragma Import
     (Stdcall,
      Fillconsoleoutputcharacter,
      "FillConsoleOutputCharacterA");

   function Fillconsoleoutputattribute
     (Console : Handle;
      Attr    : Attribute;
      Length  : Dword;
      Start   : Coord;
      Written : Lpdword)
      return    Dword;
   pragma Import
     (Stdcall,
      Fillconsoleoutputattribute,
      "FillConsoleOutputAttribute");

   Win32_Error          : constant Dword  := 0;
   Invalid_Handle_Value : constant Handle := -1;
   Std_Output_Handle    : constant Dword  := -11;

   Color_Value      : constant array (Color_Type) of Nibble :=
     (0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      9,
      10,
      11,
      12,
      13,
      14,
      15);
   Color_Type_Value : constant array (Nibble) of Color_Type :=
     (Black,
      Blue,
      Green,
      Cyan,
      Red,
      Magenta,
      Brown,
      Gray,
      Black,
      Light_Blue,
      Light_Green,
      Light_Cyan,
      Light_Red,
      Light_Magenta,
      Yellow,
      White);

   -----------------------
   -- PACKAGE VARIABLES --
   -----------------------

   Output_Buffer    : Handle;
   Num_Bytes        : aliased Dword;
   Num_Bytes_Access : Lpdword                     := Num_Bytes'Access;
   Buffer_Info_Rec  : aliased Console_Screen_Buffer_Info;
   Buffer_Info      : Pconsole_Screen_Buffer_Info := Buffer_Info_Rec'Access;

   -------------------------
   -- SUPPORTING SERVICES --
   -------------------------
   procedure Get_Buffer_Info is
   begin
      if Getconsolescreenbufferinfo (Output_Buffer, Buffer_Info) =
         Win32_Error
      then
         raise Buffer_Info_Error;
      end if;
   end Get_Buffer_Info;

   --------------------
   -- CURSOR CONTROL --
   --------------------

   function Cursor_Visible return Boolean is
      Cursor : aliased Console_Cursor_Info;
   begin
      if Getconsolecursorinfo (Output_Buffer, Cursor'Unchecked_Access) =
         0
      then
         raise Cursor_Get_Error;
      end if;
      return Cursor.Visible = 1;
   end Cursor_Visible;

   procedure Set_Cursor (Visible : in Boolean) is
      Cursor : aliased Console_Cursor_Info;
   begin
      if Getconsolecursorinfo (Output_Buffer, Cursor'Unchecked_Access) =
         0
      then
         raise Cursor_Get_Error;
      end if;
      if Visible then
         Cursor.Visible := 1;
      else
         Cursor.Visible := 0;
      end if;
      if Setconsolecursorinfo (Output_Buffer, Cursor'Unchecked_Access) =
         0
      then
         raise Cursor_Set_Error;
      end if;
   end Set_Cursor;

   function Where_X return X_Pos is
   begin
      Get_Buffer_Info;
      return X_Pos (Buffer_Info_Rec.Cursor_Pos.X);
   end Where_X;

   function Where_Y return Y_Pos is
   begin
      Get_Buffer_Info;
      return Y_Pos (Buffer_Info_Rec.Cursor_Pos.Y);
   end Where_Y;

   procedure Goto_Xy
     (X : in X_Pos := X_Pos'First;
      Y : in Y_Pos := Y_Pos'First)
   is
      New_Pos : Coord := (Short (X), Short (Y));
   begin
      Get_Buffer_Info;
      if New_Pos.X > Buffer_Info_Rec.Size.X then
         New_Pos.X := Buffer_Info_Rec.Size.X;
      end if;
      if New_Pos.Y > Buffer_Info_Rec.Size.Y then
         New_Pos.Y := Buffer_Info_Rec.Size.Y;
      end if;
      if Setconsolecursorposition (Output_Buffer, New_Pos) =
         Win32_Error
      then
         raise Cursor_Pos_Error;
      end if;
   end Goto_Xy;

   -------------------
   -- COLOR CONTROL --
   -------------------

   function Get_Foreground return Color_Type is
   begin
      Get_Buffer_Info;
      return Color_Type_Value (Buffer_Info_Rec.Attrib.Foreground);
   end Get_Foreground;

   function Get_Background return Color_Type is
   begin
      Get_Buffer_Info;
      return Color_Type_Value (Buffer_Info_Rec.Attrib.Background);
   end Get_Background;

   procedure Set_Foreground (Color : in Color_Type := Gray) is
      Attr : Attribute;
   begin
      Get_Buffer_Info;
      Attr.Foreground := Color_Value (Color);
      Attr.Background := Buffer_Info_Rec.Attrib.Background;
      if Setconsoletextattribute (Output_Buffer, Attr) = Win32_Error then
         raise Set_Attribute_Error;
      end if;
   end Set_Foreground;

   procedure Set_Background (Color : in Color_Type := Black) is
      Attr : Attribute;
   begin
      Get_Buffer_Info;
      Attr.Foreground := Buffer_Info_Rec.Attrib.Foreground;
      Attr.Background := Color_Value (Color);
      if Setconsoletextattribute (Output_Buffer, Attr) = Win32_Error then
         raise Set_Attribute_Error;
      end if;
   end Set_Background;

   --------------------
   -- SCREEN CONTROL --
   --------------------

   procedure screen_dimension is
   begin
      Get_Buffer_Info;
--        wx:=integer(buffer_info_rec.size.x);
--        wy:=integer(buffer_info_rec.size.y);
      wx:=integer(buffer_info_rec.window.right - buffer_info_rec.window.left + 1);
      wy:=integer(buffer_info_rec.window.Bottom - buffer_info_rec.window.top + 1);
   end screen_dimension;

   procedure Clear_Screen (Color : in Color_Type := Black) is
      Length : Dword;
      Attr   : Attribute;
      Home   : constant Coord := (0, 0);
   begin
      Get_Buffer_Info;
      Length          := Dword (Buffer_Info_Rec.Size.X) *
                         Dword (Buffer_Info_Rec.Size.Y);
      Attr.Background := Color_Value (Color);
      Attr.Foreground := Buffer_Info_Rec.Attrib.Foreground;
      if Setconsoletextattribute (Output_Buffer, Attr) = Win32_Error then
         raise Set_Attribute_Error;
      end if;
      if Fillconsoleoutputattribute
            (Output_Buffer,
             Attr,
             Length,
             Home,
             Num_Bytes_Access) =
         Win32_Error
      then
         raise Fill_Attribute_Error;
      end if;
      if Fillconsoleoutputcharacter
            (Output_Buffer,
             ' ',
             Length,
             Home,
             Num_Bytes_Access) =
         Win32_Error
      then
         raise Fill_Char_Error;
      end if;
      if Setconsolecursorposition (Output_Buffer, Home) = Win32_Error then
         raise Cursor_Position_Error;
      end if;
   end Clear_Screen;

   -------------------
   -- SOUND CONTROL --
   -------------------
   procedure Bleep is
   begin
      if Messagebeep (16#FFFFFFFF#) = Win32_Error then
         raise Beep_Error;
      end if;
   end Bleep;

   -------------------
   -- INPUT CONTROL --
   -------------------

   function Get_Key return Character is
      Temp : Integer;
   begin
      Temp := Getch;
      if Temp = 16#00E0# then
         Temp := 0;
      end if;
      return Character'Val (Temp);
   end Get_Key;

   function Key_Available return Boolean is
   begin
      if Kbhit = 0 then
         return False;
      else
         return True;
      end if;
   end Key_Available;

   protected body Screen is

      -------------
      -- Goto_XY --
      -------------

      entry Goto_XY (X : in Integer; Y : Integer) when True is
      begin
         --  Generated stub: replace with real body!
         NT_Console.Goto_XY (X, Y);
         --   raise Program_Error;
      end Goto_XY;

      -----------------
      -- clearscreen --
      -----------------

      entry clearscreen when True is
      begin
         --  Generated stub: replace with real body!
         NT_Console.Clear_Screen;
         --   raise Program_Error;
      end clearscreen;

      entry Ecritcolor
        (X  : Integer;
         Y  : Integer;
         S1 : String;
         S2 : String) when True
      is
      begin
         NT_Console.Goto_XY (X, Y);
         Set_Foreground (Magenta);
         Put (S1);
         Put (S2);
         Set_Foreground (White);
      end Ecritcolor;

      entry Ecrit
        (X  : Integer;
         Y  : Integer;
         S1 : String;
         S2 : String) when True
      is
      begin
         NT_Console.Goto_XY (x, y);
         Put (s1);
         Put (s2);
      end Ecrit;

   end Screen;

begin

   --------------------------
   -- WIN32 INITIALIZATION --
   --------------------------

   Output_Buffer := Getstdhandle (Std_Output_Handle);
   if Output_Buffer = Invalid_Handle_Value then
      raise Invalid_Handle_Error;
   end if;

--     begin
      screen_dimension;
      put(wx);put("   "); put(wy);
   delay 1.0;
-- Put("PAZERTYUIOPOIUYTREZAZERTYUIOPOIUYTR");
--     end;

end Nt_Console;
