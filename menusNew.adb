with Nt_Console;
use Nt_Console;
--with Ada.Text_Io;
--use Ada.Text_Io;
with Ada.Strings.Fixed;
use Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
--with ada.long_integer_text_io;
--use Ada.Long_Integer_Text_IO;
with Ada.Integer_Text_Io;
use Ada.Integer_Text_Io;
with Ada.Strings.Unbounded.Text_Io;
--with Buffer;
--use Buffer;

package body Menusnew is

   ----------------------
   -- Keyboard_Handler --
   ----------------------

   task body Keyboard_Handler is
      K0        : Character;
      Available : Boolean   := False;
      --  Clavier_Courant : Declare au niveau superieur
   begin
      loop
         Get_Immediate (K0, Available);
         if Available and then Character'Pos (K0) /= 0 then
            Clavier_Courant.Put (K0);
         end if;
         Get_Immediate (K0, Available);
         if Available and then Character'Pos (K0) /= 0 then
            Clavier_Courant.Put (K0);
         end if;
         Get_Immediate (K0, Available);
         if Available and then Character'Pos (K0) /= 0 then
            Clavier_Courant.Put (K0);
         end if;
         delay 0.06;
      end loop;
   end Keyboard_Handler;

   -------------
   -- Numeros --
   -------------

   protected body Numeros is

      ---------
      -- Get --
      ---------

      procedure Get (
            Numero :    out Long_Integer) is
      begin
         Count  := Count + 1;
         Numero := Count;
      end Get;

   end Numeros;

   ----------------
   -- initialize --
   ----------------

   procedure Initialize (
         F : in out Fenetre) is
   begin
      null;
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (
         F : in out Fenetre) is
   begin
      F.Menus_Associes.Clear;
   end Finalize;

   function Init (
         Xr1,
         Yr1,
         Xr2,
         Yr2 : Integer)
     return Fenetre_Ptr is
   begin
      -- put("Init fenetre ");
      return W : constant Fenetre_Ptr := new Fenetre do
      W.Xr1 := Xr1;
      W.Yr1 := Yr1;
      W.Xr2 := Xr2;
      W.Yr2 := Yr2;

      W.X1 := W.Xr1 - Cadre.Xr1;
      W.Y1 := W.Yr1 - Cadre.Yr1;
      W.X2 := W.Xr2 - Cadre.Xr1;
      W.Y2 := W.Yr2 - Cadre.Yr1;
   end return;
end Init;

function Init (
      T :        String;
      F : access Fenetre'Class)
  return Menu_Ptr is
begin
   return Pmen : constant Menu_Ptr := new Menu do
   Move (T, Pmen.Titre, Ada.Strings.Right);
   Pmen.F     := F;
   if F /= null then
      F.Menus_Associes.Insert (Pmen.Numero, Pmen);
      F.Menu_En_Cours := Pmen;
      -- put ("f not null ");
   else
      null;
      Put ("f is null ");
   end if;
end return;
end Init;

function Init (
      T :        String;
      F : access Fenetre'Class)
  return Menu is
begin
   return Pmen : aliased Menu do
   Move (T, Pmen.Titre, Ada.Strings.Right);
   Pmen.F     := F;
   if F /= null then
      F.Menus_Associes.Insert (Pmen.Numero, Pmen'Unchecked_Access);
      F.Menu_En_Cours := Pmen'Unchecked_Access;
      -- put ("f not null ");
   else
      null;
      Put ("f is null ");
   end if;
end return;
end Init;

--function Init(T: String; F : access Fenetre'Class) return Menu is
--begin
--   return (Titre => T, F => F);
--end;


-----------
-- Ecrit --
-----------

procedure Ecrit (
      W : access Fenetre'Class;
      X,
      Y :        Integer;
      T :        String) is
   Ligne : String (1 .. W.X2 - W.X1 - 1);
begin
   if W.Visible then
      Move (T, Ligne, Ada.Strings.Right);
      Ecran.Ecrit (X, Y, "  ", Ligne);
   end if;
end Ecrit;

------------
-- Efface --
------------

procedure Efface (
      W : access Fenetre'Class) is
begin
   if W.Visible then
      declare
         Blank_Line : constant String := (W.X2 - W.X1 + 1) * " ";
      begin
         for L in W.Y1 .. W.Y2 loop
            Ecran.Ecrit (W.X1, L, "", Blank_Line);
         end loop;
      end;
   end if;
end Efface;

------------------
-- clear_screen --
------------------

procedure Clear_Screen (
      W : access Fenetre'Class) is
begin
   W.Efface;
end Clear_Screen;

-------------
-- VISIBLE --
-------------

function Visible (
      W : access Fenetre'Class)
  return Boolean is
begin
   return Visibleb : Boolean do
   Visibleb := True;
   if W.Xr1 < Cadre.Xr1 or W.Xr2 > Cadre.Xr2 then
      Visibleb := False;
   end if;
   if W.Yr1 < Cadre.Yr1 or W.Yr2 > Cadre.Yr2 then
      Visibleb := False;
   end if;
end return;
end Visible;

procedure Choix_Menu (
      D : access Menu) is
   Cs    : Store_Menus.Cursor            := The_Store.First;
   C     : Store_Menus.Cursor;
   Ls    : Integer                       := D.Y1;
   Lmax  : Integer;
   K0    : Character;
   Ligne : String (1 .. D.X2 - D.X1 - 1);
begin
   loop
      if Store_Menus.Has_Element (Cs) then
         -- Impression de l'element => Cs a la ligne Ls de l'ecran
         Move (Store_Menus.Element (Cs).Titre, Ligne, Ada.Strings.Right);
         Ecran.Ecritcolor (D.X1, Ls, "=>", Ligne);
         C := Store_Menus.Previous (Cs);
         Toto:  for L in reverse D.Y1 .. Ls - 1 loop
            if Store_Menus.Has_Element (C) then
               -- imprime le titre de l'element a la ligne L
               Move
                  (Store_Menus.Element (C).Titre,
                  Ligne,
                  Ada.Strings.Right);
               Ecran.Ecrit (D.X1, L, "  ", Ligne);
               C:=Store_Menus.Previous (C);
            else
               declare
                  Blank_Line : constant String := (D.X2 - D.X1 + 1) * " ";
               begin
                  for Ll in reverse D.Y1 .. L loop
                     --imprime une ligne blanche a la ligne Ll
                     Ecran.Ecrit (D.X1, Ll, "", Blank_Line);
                  end loop;
                  exit Toto;
               end;
            end if;
            -- Store_Menus.Previous (C);
         end loop Toto;
         C := Store_Menus.Next (Cs);
         Marius : for L in Ls + 1 .. D.Y2 loop
            if Store_Menus.Has_Element (C) then
               -- imprime le titre de l'element a la ligne L
               Lmax:= L;
               Move
                  (Store_Menus.Element (C).Titre,
                  Ligne,
                  Ada.Strings.Right);
               Ecran.Ecrit (D.X1, L, "  ", Ligne);
            else
               declare
                  Blank_Line : constant String := (D.X2 - D.X1 + 1) * " ";
               begin
                  for Ll in L .. D.Y2 loop
                     Ecran.Ecrit (D.X1, Ll, "", Blank_Line);
                  end loop;
                  exit Marius;
               end;
            end if;
            Store_Menus.Next (C);
         end loop Marius;
      else
         Ecran.Ecrit(D.X1, D.Y1+1, "", "Il n'y a pas d'elements");
      end if;
      K0 := D.Get_Key;
      case K0 is
         when Key_Up =>
            C := Store_Menus.Previous (Cs);
            if Store_Menus.Has_Element (C) then
               Cs := C;
               if Ls > D.Y1 then
                  Ls := Ls - 1;
               else
                  Ls := D.Y1;
               end if;
            else
               Ls := Lmax;
               Cs := The_Store.Last;
            end if;
         when Key_Down =>
            C := Store_Menus.Next (Cs);
            if Store_Menus.Has_Element (C) then
               Cs := C;
               if Ls < D.Y2 then
                  Ls := Ls + 1;
               else
                  Ls:=D.Y2;
               end if;
            else
               Ls:= D.Y1;
               Cs:= The_Store.First;
            end if;
         when Key_Home =>
            Cs := The_Store.First;
            Ls := D.Y1;
         when Key_Left =>
            Clavier_Courant.Put('r');
            exit;
         when Key_Right =>
            Clavier_Courant.Put('r');
            declare
               Men : Menu_Ptr := Store_Menus.Element (Cs);
            begin
               --Clavier_Courant := Store_Menus.Element (Cs).Keyboard;
               Clavier_Courant := Men.Keyboard;
               Men.F.Menu_En_Cours := Men;
               Clavier_Courant.Put('r');
               Clavier_Courant.Put('l');
            end;
            exit;
         when others =>
            null;
      end case;
   end loop;
end Choix_Menu;

procedure Choix_Menu_Associe (
      D : access Menu) is
   Cs    : Store_Menus.Cursor            := D.F.Menus_Associes.First;
   C     : Store_Menus.Cursor;
   Ls    : Integer                       := D.Y1;
   Lmax  : Integer;
   K0    : Character;
   Ligne : String (1 .. D.X2 - D.X1 - 1);
begin
   loop
      if Store_Menus.Has_Element (Cs) then
         -- Impression de l'element => Cs a la ligne Ls de l'ecran
         Move (Store_Menus.Element (Cs).Titre, Ligne, Ada.Strings.Right);
         Ecran.Ecritcolor (D.X1, Ls, "=>", Ligne);
         C := Store_Menus.Previous (Cs);
         Toto:  for L in reverse D.Y1 .. Ls - 1 loop
            if Store_Menus.Has_Element (C) then
               -- imprime le titre de l'element a la ligne L
               Move
                  (Store_Menus.Element (C).Titre,
                  Ligne,
                  Ada.Strings.Right);
               Ecran.Ecrit (D.X1, L, "  ", Ligne);
               C:=Store_Menus.Previous (C);
            else
               declare
                  Blank_Line : constant String := (D.X2 - D.X1 + 1) * " ";
               begin
                  for Ll in reverse D.Y1 .. L loop
                     --imprime une ligne blanche a la ligne Ll
                     Ecran.Ecrit (D.X1, Ll, "", Blank_Line);
                  end loop;
                  exit Toto;
               end;
            end if;
            -- Store_Menus.Previous (C);
         end loop Toto;
         C := Store_Menus.Next (Cs);
         Marius : for L in Ls + 1 .. D.Y2 loop
            if Store_Menus.Has_Element (C) then
               -- imprime le titre de l'element a la ligne L
               Lmax:= L;
               Move
                  (Store_Menus.Element (C).Titre,
                  Ligne,
                  Ada.Strings.Right);
               Ecran.Ecrit (D.X1, L, "  ", Ligne);
            else
               declare
                  Blank_Line : constant String := (D.X2 - D.X1 + 1) * " ";
               begin
                  for Ll in L .. D.Y2 loop
                     Ecran.Ecrit (D.X1, Ll, "", Blank_Line);
                  end loop;
                  exit Marius;
               end;
            end if;
            Store_Menus.Next (C);
         end loop Marius;
      else
         Ecran.Ecrit(D.X1, D.Y1+1, "", "Il n'y a pas d'elements");
      end if;
      K0 := D.Get_Key;
      case K0 is
         when Key_Up =>
            C := Store_Menus.Previous (Cs);
            if Store_Menus.Has_Element (C) then
               Cs := C;
               if Ls > D.Y1 then
                  Ls := Ls - 1;
               else
                  Ls := D.Y1;
               end if;
            else
               Ls := Lmax;
               Cs := The_Store.Last;
            end if;
         when Key_Down =>
            C := Store_Menus.Next (Cs);
            if Store_Menus.Has_Element (C) then
               Cs := C;
               if Ls < D.Y2 then
                  Ls := Ls + 1;
               else
                  Ls:=D.Y2;
               end if;
            else
               Ls:= D.Y1;
               Cs:= The_Store.First;
            end if;
         when Key_Home =>
            Cs := The_Store.First;
            Ls := D.Y1;
         when Key_Left =>
            Clavier_Courant.Put('r');
            exit;
         when Key_Right =>
            Clavier_Courant.Put('r');
            declare
               Men : Menu_Ptr := Store_Menus.Element (Cs);
            begin
               --Clavier_Courant := Store_Menus.Element (Cs).Keyboard;
               Clavier_Courant := Men.Keyboard;
               Men.F.Menu_En_Cours := Men;
               Clavier_Courant.Put('r');
               Clavier_Courant.Put('l');
            end;
            exit;
         when others =>
            null;
      end case;
   end loop;
end Choix_Menu_Associe;


procedure Initialize (
      Men : in out Menu) is
   N        : Long_Integer;
   Inserted : Boolean;
begin
   --  Creation d'un clavier dedie au menu
   Men.Keyboard := new Clavier;
   --  Le menu recoit un numero unique croissant avec l'ordre de creation
   Numeros.Get (N); --  generateur de numeros
   Men.Numero := N; --  affectation du numero
   --  Insertion du menu dans le Cadre
   The_Store.Insert (N, Men'Unchecked_Access, Cursor_Menu_Courant, Inserted);
   Clavier_Courant := Men.Keyboard;
   --  a revoir si le menu cree n'a pas a etre operationnel immediatement
   --   if Men.F /= null then
   --      Men.F.Menu_en_cours := Men'unchecked_access;
   --      Men.F.Menus_Associes.Insert (N, Men'Unchecked_Access);
   --   else
   --      Put("f est null dans initialize menu ");
   --   end if;
   Empile (Men.Compteur_Article, 0);
   --  Création du pointeur d'article sélectionné. On commence par
   --  sélectionner le premier article rencontré
   Empile (Men.Article_Selectionne, 1);
   --  Position de l'article sélectionné dans la fenêtre du menu. Initialisé
   --  à 0.
   Empile (Men.Fenetre, 0);
   Men.Entree_Demandee := True;
   Men.Sortie_Demandee := False;
   Men.Impression      := False;
   Men.Rafraichi       := False;
   Clavier_Courant.Put('r');
end Initialize;

procedure Finalize (
      Men : in out Menu) is
begin
   The_Store.Delete (Men.Numero);
   Men.F.Menus_Associes.Delete(Men.Numero);
end Finalize;

--use My_String;

procedure Add (
      Str : in     String) is

begin
   Put (Str);
end Add;

procedure Clear_To_End_Of_Line is
begin
   null;
end Clear_To_End_Of_Line;

function To_String (
      N : Integer)
  return String is
begin
   return Integer'Image (N);
end To_String;

function To_String (
      N : Long_Integer)
  return String is
begin
   return Long_Integer'Image (N);
end To_String;

function To_String (
      N   :        Long_Float;
      Aft : in     Ada.Text_Io.Field := Default_Aft;
      Exp : in     Ada.Text_Io.Field := Default_Exp)
  return String is
   Bnombre,
   Bligne  : My_String.Bounded_String;
   Snombre : String (1 .. 35);
begin

   Put (
      To   => Snombre,
      Item => N,
      Aft  => Aft,
      Exp  => Exp);

   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   return To_String (Bnombre);
end To_String;

--   function To_String (
--         N   :        Long_Float;
--         Aft : in     Ada.Text_Io.Field := Default_Aft;
--         Exp : in     Ada.Text_Io.Field := Default_Exp)
--     return String is

--   begin
--      return Long_Float'Image(N);
--   end;

function Get_Key (
      W : Menu'Class)
  return Character is
begin
   return C : Character do
   if W.Keyboard /= null then
      W.Keyboard.Get (C);
   else
      Put ("KEYBOARD NULL ! ");
      C := ' ';
   end if;
end return;
end Get_Key;

function M0 (
      Men     : access Menu;
      Titre   :        String;
      C       : access Integer;
      Message :        String  := "EXIT")
  return Boolean is
   --  Fonction de controle de menu à utiliser dans une structure while. La
   --  variable c doit être initialisée à 0. La sortie est soumise à la
   --  confirmation de l'opérateur.
   R  : Character;
   Vc,
   Va,
   Vf : Integer;

begin
   Va := Lvaleur (Men.Article_Selectionne);
   Vf := Lvaleur (Men.Fenetre);
   Vc := C.All;--  +1 peut etre
   if M (Men, Titre, C) = False then
      Men.F.Clear_Screen;
      Ecran.Goto_Xy (Men.F.X1, Men.F.Y1);
      Put (Message & " (O/N)");
      -- Put ("VOULEZ VOUS SORTIR DEFINITIVEMENT DU MENU ? (O/N): ");
      R := Men.Get_Key;
      if not (R = 'O') then
         Men.F.Clear_Screen;
         Empile (Men.Compteur_Article, 0);
         Empile (Men.Article_Selectionne, Va);
         Empile (Men.Fenetre, Vf);
         Men.Sortie_Demandee := False;
         Men.Impression      := False;
         Men.Imp;
         Men.Impt (Titre);
         Men.Rafraichi := False;
         C.All         := Vc;
         return True;
      else
         Men.F.Clear_Screen;
         return False;
      end if;
   end if;
   return True;
end M0;


function M00 (
      Men   : access Menu;
      Titre :        String;
      C     : access Integer)
  return Boolean is
   --  Fonction de controle de menu à utiliser dans une structure while. La
   --  variable c doit être initialisée à 0. La sortie est soumise à la
   --  confirmation de l'opérateur.
   R : Character;
begin

   if Men.M2 (Titre, C) = False then
      Men.Clear_Screen;
      Ecran.Goto_Xy (Men.F.X1, Men.F.Y1);
      Put ("EXIT(O/N)");
      -- Put ("VOULEZ VOUS SORTIR DEFINITIVEMENT DU MENU ? (O/N): ");
      R := Men.Get_Key;
      if not (R = 'O') then
         return True;
      else
         Men.Clear_Screen;
         return False;
      end if;
   end if;
   Men.A := Lvaleur (Men.Compteur_Article);
   Men.As := Lvaleur (Men.Article_Selectionne);
   return True;
end M00;



function M1 (
      Men   : access Menu;
      Titre :        String;
      C     : access Integer)
  return Boolean is
   --  (*Fonction de controle de menu à utiliser dans une structure while.
   -- 	Le menu est activé des le premier appel
   -- 	La variable c doit être initialisée  à 0
   --  *)
begin
   if C.All = 0 then
      Clear_Screen;
      Men.Impt (Titre);
      C.All := 1;
      Empile (Men.Compteur_Article, 0);
      Empile (Men.Article_Selectionne, 1);
      Empile (Men.Fenetre, 0);
      Men.Rafraichi := True;
      return True;
   else
      if Men.M (Titre, C) = False then
         Men.Rafraichi := True;
         Men.Clear_Screen;
         C.All := 0;
         return False;
      else
         return True;
      end if;
   end if;
end M1;

--function m (
--      men   : access menu;
--      titre : in     string;
--      c     : access integer)
--  return boolean is
--   k0 : character;
--   v  : integer;
--   c1 : integer_pointeur :=
--   new integer'(0);
--   --  Fonction de contrôle de menu a utiliser dans une structure while. La
--   --  variable c.all doit être initialisée à 0
--begin
--   men.as := lvaleur (men.article_selectionne);
--   --  Mémorisation de l'article sélectionné
--   if c.all = 0 then --  3
--      --  Increment de 1 du compteur d'article
--      increment (men.compteur_article, 1);
--      men.a := lvaleur (men.compteur_article);
--      if (men.a = men.as) then  --  2: L'Article de rang A est sélectionné
--         if men.entree_demandee then --  1
--            men.entree_demandee := false;
--            --  On commence à compter les articles avec un nouveau Compteur
--            --  mis à 0
--            empile (men.compteur_article, 0);
--            --  L'Article selectionné sera le premier rencontré
--            empile (men.article_selectionne, 1);
--            --  L'Article sélectionné est affiché en haut de la fenêtre
--            empile (men.fenetre, 0);--  était commenté. A surveiller.
--            men.rafraichi := true;
--            -- men.clear_screen; -- Aujourd'hui
--            men.impt (titre);
--            --  impression du titre en haut et au milieu de la fenêtre
--            c.all := 1; --  mise à 1 du Compteur de boucle
--            return true;
--         else
--            --  l'Entrée n'est pas demandée, on affiche l'article du menu
--            --  avec une flèche de sélection
--            men.impf (titre);
--            return false;
--         end if; --  1
--      else  --  2
--         --  L'Article n'est pas sélectionné On l'affiche sans flèche
--         men.imps (titre);
--         return false;
--      end if;--  2
--   else--  3 C est different de 0, on boucle dans un menu
--      --  On va mettre à jour le nombre d'articles, le rang de l'article
--      --  sélectionné
--      if men.rafraichi then
--         c.all              := c.all + 1;
--         men.nombre_article := lvaleur (men.compteur_article);
--    --     pragma assert(men.nombre_article = 5, "problème");
--         if men.nombre_article > 0 then
--            mvaleur
--               (men.article_selectionne,
--               ((men.as - 1 + men.nombre_article) mod men.nombre_article) +
--               1);
--         else
--            mvaleur (men.article_selectionne, 1);
--         end if;
--         mvaleur (men.compteur_article, 0);
--         men.rafraichi := false;
--         men.clear_screen;
--         men.imp;
--         men.impt (titre);
--         --men.efface_fin_menu;
--         return true;
--      end if;
--      men.impression := false;
--      men.stockage   := false;
--      if men.attend_entree_clavier then
--         loop
--            k0 := men.get_key;
--            case k0 is
--               when key_up =>
--                  Increment_Article_Selectionne (Men, -1);
--                   men.rafraichi := true;

--                  exit;
--               when key_down =>
--                  Increment_Article_Selectionne (Men, 1);
--                  men.rafraichi := true;
--                  exit;
--               when key_right =>
--                  men.entree_demandee := true;
--                  exit;
--               when key_left =>
--                  men.sortie_demandee := true;
--                  exit;
--               when key_pagedown =>
--                  increment_article_selectionne (men, 4);
--                  exit;
--               when key_pageup =>
--                  increment_article_selectionne (men, -4);
--                  exit;
--               when key_home =>
--                  -- mvaleur (Men.Article_selectionne, 1);
--                  modifie_article_selectionne (men, 1);
--                  exit;
--               when key_end =>
--                  -- mvaleur (men.article_selectionne, 0);
--                  modifie_article_selectionne (men, 0);
--                  exit;
--               when 'r' =>
--                  men.clear_screen;
--                  exit;
--               when 'w' =>
--                  choix_menu (men);
--               when 'W' =>
--                  choix_menu_associe (men);

--               when key_f1 =>
--                  begin
--                     begin
--                        men.stockage := true;
--                        put (fichier_sortie, 78 * "*");
--                        new_line (fichier_sortie);
--                        exit;
--                     exception
--                        when status_error =>
--                           bleep;
--                           men.stockage := false;
--                           while men.m1(
--                                 "IL N'Y A PAS DE FICHIER DEFINI POUR LE STOCKAGE",
--                                 c1)
--                                 loop
--                              null;
--                           end loop;
--                           exit;
--                     end;
--                  end;
--               when key_alt_f =>
--                  while men.m1 ("MENU STOCKAGE", c1) loop
--                     --                     if Men.Chaine("NOM DU FICHIER DE
--                     --  STOCKAGE",S'access) then
--                     --                        Men.Nom_Fichier := S;
--                     --                        if Is_Open(Fichier_Sortie)
--                     --  then
--                     --                           Flush(Fichier_Sortie);
--                     --                           Close(Fichier_Sortie);
--                     --                        end if;
--                     --                     end if;
--                     if is_open (fichier_sortie) then
--                        move
--                           (name (fichier_sortie),
--                           men.nom_fichier,
--                           ada.strings.right);
--                        if men.t ("FERMET DU FICHIER") then
--                           close (fichier_sortie);
--                        end if;
--                        if men.t ("RESET DU FICHIER") then
--                           reset (fichier_sortie, out_file);
--                        end if;
--                     else
--                        begin
--                           --  test d'existence du fichier
--                           open
--                              (fichier_sortie,
--                              append_file,
--                              trim (men.nom_fichier, ada.strings.both));
--                           close (fichier_sortie);
--                           men.fichier_existe := true;
--                        exception
--                           when name_error =>
--                              men.fichier_existe := false;
--                        end;
--                        if men.fichier_existe then
--                           if men.t ("LE FICHIER EXISTE: l'OUVRIR") then
--                              open
--                                 (fichier_sortie,
--                                 append_file,
--                                 trim (men.nom_fichier, ada.strings.both));
--                           end if;
--                        else
--                           if men.t
--                                 ("LE FICHIER N'EXISTE PAS: LE CREER")
--                                 then
--                              create
--                                 (fichier_sortie,
--                                 append_file,
--                                 trim (men.nom_fichier, ada.strings.both));
--                           end if;
--                        end if;
--                     end if;
--                  end loop;
--                  exit;
--                  when others =>
--                     --bleep;
--                     --men.rafraichi := true;

--                  null;
--            end case;
--         end loop;
--      else
--         men.attend_entree_clavier := true;
--      end if;
--      if men.sortie_demandee then
--         men.sortie_demandee := false;
--         depile (men.compteur_article, v);
--         depile (men.article_selectionne, v);
--         depile (men.fenetre, v);
--         men.rafraichi := true;
--         men.clear_screen;
--         c.all := 0;
--         return false;
--      end if;
--      c.all := c.all + 1;
--      men.imp;
--      men.impt (titre);
--      mvaleur (men.compteur_article, 0);
--      return true;
--   end if;--  3
--end m;


function M (
      Men   : access Menu;
      Titre : in     String;
      C     : access Integer)
  return Boolean is
   K0 : Character;
   V  : Integer;
   --   C1 : Integer_Pointeur :=
   --   new Integer'(0);
   --  Fonction de contrôle de menu a utiliser dans une structure while. La
   --  variable c.all doit être initialisée à 0
begin
   if C.All = 0 then
      --  3  Le menu est un simple article et donc dans un état passif
      if Men.Rafraichi then --4
         Increment (Men.Compteur_Article, 1);
         return False;
      else
         -- 4 Men.Rafraichi = False : Le menu est à présenter comme un simple article dans une liste
         Increment (Men.Compteur_Article, 1);
         Men.A := Lvaleur (Men.Compteur_Article);
         Men.As := Lvaleur (Men.Article_Selectionne);
         if (Men.A = Men.As) then
            --  2: L'Article de rang A est sélectionné
            if Men.Entree_Demandee then
               --  1 l'Entrée dans le menu sélectionné est demandée.
               Men.Entree_Demandee := False;
               Empile (Men.Compteur_Article, 0);
               --  On commence à compter les articles avec un nouveau Compteur mis à 0
               Empile (Men.Article_Selectionne, 1);
               --  Nouveau pointeur d'article selectionné qui sera pour commencer le premier rencontré
               Empile (Men.Fenetre, 0);
               --  L'Article sélectionné du menu sera affiché en haut de la fenêtre
               Men.Impt (Titre);
               --  impression du titre en haut et au milieu de la fenêtre
               C.All := 1; --  mise à 1 du Compteur de boucle
               return True;
            else
               -- 1  l'Entrée dans le menu sélectionné n'est pas demandée.
               Men.Impf (Titre);
               return False;
            end if; --  1
         else
            --  2  L'Article de rang A n'est pas sélectionné. On l'affiche sans flèche.
            Men.Imps (Titre);
            return False;
         end if;--  2
      end if; -- 4 test sur men.rafraichi
   else --  3 C.all est different de 0, on boucle dans un menu actif
      C.All              := C.All + 1;
      Men.Nombre_Article := Lvaleur (Men.Compteur_Article);
      if Men.Nombre_Article > 0 then -- 6
         Mvaleur
            (Men.Article_Selectionne,
            ((Men.As - 1 + Men.Nombre_Article) mod Men.Nombre_Article) +
            1);
      else -- 6
         Mvaleur (Men.Article_Selectionne, 1);
      end if; -- 6
      Mvaleur (Men.Compteur_Article, 0);
      Men.Imp;
      Men.Impt (Titre);
      if Men.Rafraichi then -- 5
         Men.Rafraichi := False;
         return True;
      else -- 5 Men.rafraichi := false
         Men.Efface_Fin_Menu;
         loop
            K0 := Men.Get_Key;
            case K0 is
               when Key_Up =>
                  Increment_Article_Selectionne (Men, -1);
                  exit;
               when Key_Down =>
                  Increment_Article_Selectionne (Men, 1);
                  exit;
               when Key_Right =>
                  Men.Entree_Demandee := True;
                  exit;
               when Key_Left =>
                  Depile (Men.Compteur_Article, V);
                  Depile (Men.Article_Selectionne, V);
                  Depile (Men.Fenetre, V);
                  Men.As := Lvaleur (Men.Article_Selectionne);
                  Men.A := Lvaleur (Men.Compteur_Article);
                  Men.Rafraichi := True;
                  --Men.Clear_Screen;
                  C.All := 0;
                  return False;
               when Key_Pagedown =>
                  Increment_Article_Selectionne (Men, 4);
                  exit;
               when Key_Pageup =>
                  Increment_Article_Selectionne (Men, -4);
                  exit;
               when Key_Home =>
                  -- mvaleur (Men.Article_selectionne, 1);
                  Modifie_Article_Selectionne (Men, 1);
                  exit;
               when Key_End =>
                  -- mvaleur (men.article_selectionne, 0);
                  Modifie_Article_Selectionne (Men, 0);
                  exit;
                    when Key_Control_Pagedown =>
                  Increment_Article_Selectionne (Men, 40);
                  exit;
               when Key_Alt_F12 =>
                     Increment_Article_Selectionne (Men, 40);
                  exit;
               when Key_Control_Pageup =>
                  Increment_Article_Selectionne (Men, -40);
                  exit;
               when 'r' =>
                  Men.Clear_Screen;
                  exit;
               when 'l' =>
                  Men.Locate;
                  exit;

               when Key_Alt_Eright  =>
                  declare
                     C : Store_Menus.Cursor;
                  begin
                     C := Store_Menus.Next (Cursor_Menu_Courant);
                     if Store_Menus.Has_Element (C) then
                        Cursor_Menu_Courant := C;
                     else
                        Cursor_Menu_Courant := The_Store.First;
                     end if;
                     Clavier_Courant := Store_Menus.Element (Cursor_Menu_Courant).Keyboard;
                     Clavier_Courant.Put('l');
                     Clavier_Courant.Put('r');
                  end;
               when Key_Alt_Eleft  =>
                  declare
                     C : Store_Menus.Cursor;
                  begin
                     C := Store_Menus.Previous(Cursor_Menu_Courant);
                     if Store_Menus.Has_Element (C) then
                        Cursor_Menu_Courant := C;
                     else
                        Cursor_Menu_Courant := The_Store.Last;
                     end if;
                     Clavier_Courant := Store_Menus.Element (Cursor_Menu_Courant).Keyboard;
                     Clavier_Courant.Put('l');
                     Clavier_Courant.Put('r');
                  end;
               when Key_Alt_Eup =>
                  declare
                     C :          Store_Menus.Cursor := Cursor_Menu_Courant;
                     F : constant Fenetre_Ptr        := Fenetre_Ptr (Store_Menus.Element (Cursor_Menu_Courant).F);
                  begin
                     loop
                        C := Store_Menus.Previous(C);
                        if not Store_Menus.Has_Element (C)then
                           C := The_Store.Last;
                        end if;
                        if F = Fenetre_Ptr(Store_Menus.Element (C).F)then
                           Cursor_Menu_Courant := C;
                           Clavier_Courant := Store_Menus.Element (Cursor_Menu_Courant).Keyboard;
                           Clavier_Courant.Put('l');
                           Clavier_Courant.Put('r');
                           exit;
                        end if;
                     end loop;
                  end;
               when Key_Alt_Edown =>
                  declare
                     C :          Store_Menus.Cursor := Cursor_Menu_Courant;
                     F : constant Fenetre_Ptr        := Fenetre_Ptr (Store_Menus.Element (Cursor_Menu_Courant).F);
                  begin
                     loop
                        C := Store_Menus.Next(C);
                        if not Store_Menus.Has_Element (C)then
                           C := The_Store.First;
                        end if;
                        if F = Fenetre_Ptr(Store_Menus.Element (C).F)then
                           Cursor_Menu_Courant := C;
                           Clavier_Courant := Store_Menus.Element (Cursor_Menu_Courant).Keyboard;
                           Clavier_Courant.Put('l');
                           Clavier_Courant.Put('r');
                           exit;
                        end if;
                     end loop;
                  end;
               when 'w' =>
                  Choix_Menu (Men);
               when 'W' =>
                  Choix_Menu_Associe (Men);
               when others =>
                  --bleep;
                  --men.rafraichi := true;
                  null;
            end case;
         end loop;
         return True;
      end if; --5
   end if;--  3
end M;



function M2 (
      Men   : access Menu;
      Titre : in     String;
      C     : access Integer)
  return Boolean is
   K0 : Character;
   V  : Integer;
   --   C1 : Integer_Pointeur :=
   --   new Integer'(0);
   --  Fonction de contrôle de menu a utiliser dans une structure while. La
   --  variable c.all doit être initialisée à 0
begin
   if C.All = 0 then --  3  On entre pour la première fois dans le menu
      --    Increment (Men.Compteur_Article, 1);
      --    Men.A := Lvaleur (Men.Compteur_Article);
      --    Men.As := Lvaleur (Men.Article_Selectionne);
      Empile (Men.Compteur_Article, 0);
      --  On commence à compter les articles avec un nouveau Compteur mis à 0
      Empile (Men.Article_Selectionne, 1);
      --  Nouveau pointeur d'article selectionné qui sera pour commencer le premier rencontré
      Empile (Men.Fenetre, 0);
      --  L'Article sélectionné du menu sera affiché en haut de la fenêtre
      Men.Impt (Titre);
      --  impression du titre en haut et au milieu de la fenêtre
      C.All := 1; --  mise à 1 du Compteur de boucle
      Men.Rafraichi := True;

      return True;
   else --  3 C.all est different de 0, on boucle dans un menu actif
      C.All              := C.All + 1;
      Men.Nombre_Article := Lvaleur (Men.Compteur_Article);
      if Men.Nombre_Article > 0 then -- 6
         Mvaleur
            (Men.Article_Selectionne,
            ((Men.As - 1 + Men.Nombre_Article) mod Men.Nombre_Article) +
            1);
      else -- 6
         Mvaleur (Men.Article_Selectionne, 1);
      end if; -- 6
      Mvaleur (Men.Compteur_Article, 0);
      Men.Imp;
      Men.Impt (Titre);
      if Men.Rafraichi then -- 5
         Men.Rafraichi := False;
         return True;
      else -- 5 Men.rafraichi := false
         Men.Efface_Fin_Menu;
         loop
            K0 := Men.Get_Key;
            case K0 is
               when Key_Up =>
                  Increment_Article_Selectionne (Men, -1);
                  exit;
               when Key_Down =>
                  Increment_Article_Selectionne (Men, 1);
                  exit;
               when Key_Right =>
                  Men.Entree_Demandee := True;
                  exit;
               when Key_Left =>
                  Depile (Men.Compteur_Article, V);
                  Depile (Men.Article_Selectionne, V);
                  Depile (Men.Fenetre, V);
                  Men.As := Lvaleur (Men.Article_Selectionne);
                  Men.A := Lvaleur (Men.Compteur_Article);

                  Men.Rafraichi := True;
                  -- Men.Clear_Screen;
                  C.All := 0;
                  return False;
               when Key_Pagedown =>
                  Increment_Article_Selectionne (Men, 4);
                  exit;
               when Key_Pageup =>
                  Increment_Article_Selectionne (Men, -4);
                  exit;
               when Key_Home =>
                  -- mvaleur (Men.Article_selectionne, 1);
                  Modifie_Article_Selectionne (Men, 1);
                  exit;
               when Key_End =>
                  -- mvaleur (men.article_selectionne, 0);
                  Modifie_Article_Selectionne (Men, 0);
                  exit;
               when Key_Control_Pagedown =>
                  Increment_Article_Selectionne (Men, 40);
                  exit;
               when Key_Alt_F12 =>
                     Increment_Article_Selectionne (Men, 40);
                  exit;
               when Key_Control_Pageup =>
                  Increment_Article_Selectionne (Men, -40);
                  exit;

               when 'r' =>
                  Men.Clear_Screen;
                  exit;
               when 'l' =>
                  Men.Locate;
                  exit;

               when Key_Alt_Eright  =>
                  declare
                     C : Store_Menus.Cursor;
                  begin
                     C := Store_Menus.Next (Cursor_Menu_Courant);
                     if Store_Menus.Has_Element (C) then
                        Cursor_Menu_Courant := C;
                     else
                        Cursor_Menu_Courant := The_Store.First;
                     end if;
                     Clavier_Courant := Store_Menus.Element (Cursor_Menu_Courant).Keyboard;
                     --Store_Menus.Element (Cursor_Menu_Courant).locate;
                     Clavier_Courant.Put('l');
                     Clavier_Courant.Put('r');
                  end;
               when Key_Alt_Eleft  =>
                  declare
                     C : Store_Menus.Cursor;
                  begin
                     C := Store_Menus.Previous(Cursor_Menu_Courant);
                     if Store_Menus.Has_Element (C) then
                        Cursor_Menu_Courant := C;
                     else
                        Cursor_Menu_Courant := The_Store.Last;
                     end if;
                     Clavier_Courant := Store_Menus.Element (Cursor_Menu_Courant).Keyboard;
                     Clavier_Courant.Put('l');
                     Clavier_Courant.Put('r');
                  end;
               when Key_Alt_Eup =>
                  declare
                     C :          Store_Menus.Cursor := Cursor_Menu_Courant;
                     F : constant Fenetre_Ptr        := Fenetre_Ptr (Store_Menus.Element (Cursor_Menu_Courant).F);
                  begin
                     loop
                        C := Store_Menus.Previous(C);
                        if not Store_Menus.Has_Element (C)then
                           C := The_Store.Last;
                        end if;
                        if F = Fenetre_Ptr(Store_Menus.Element (C).F)then
                           Cursor_Menu_Courant := C;
                           Clavier_Courant := Store_Menus.Element (Cursor_Menu_Courant).Keyboard;
                           Clavier_Courant.Put('l');
                           Clavier_Courant.Put('r');
                           exit;
                        end if;
                     end loop;
                  end;
               when Key_Alt_Edown =>
                  declare
                     C :          Store_Menus.Cursor := Cursor_Menu_Courant;
                     F : constant Fenetre_Ptr        := Fenetre_Ptr (Store_Menus.Element (Cursor_Menu_Courant).F);
                  begin
                     loop
                        C := Store_Menus.Next(C);
                        if not Store_Menus.Has_Element (C)then
                           C := The_Store.First;
                        end if;
                        if F = Fenetre_Ptr(Store_Menus.Element (C).F)then
                           Cursor_Menu_Courant := C;
                           Clavier_Courant := Store_Menus.Element (Cursor_Menu_Courant).Keyboard;
                           Clavier_Courant.Put('l');
                           Clavier_Courant.Put('r');
                           exit;
                        end if;
                     end loop;
                  end;
               when 'w' =>
                  Choix_Menu (Men);
               when 'W' =>
                  Choix_Menu_Associe (Men);
               when others =>
                  null;
            end case;
         end loop;
         return True;
      end if; --5
   end if;--  3
end M2;

procedure Fin (
      Men : access Menu) is
begin
   Men.Sortie_Demandee       := True;
   Men.Attend_Entree_Clavier := False;
   --  rafraichi:= True;
end Fin;

procedure Update (
      Men : access Menu) is
begin
   Men.Rafraichi := True;
   Men.Clear_Screen;
   Mvaleur (Men.Compteur_Article, 0);
end Update;

function T (
      Men   : access Menu;
      Titre :        String)
  return Boolean is
   --  Fonction de controle d'un Article de menu. L'activation ne produit pas
   --  l'effacement de l'ecran et l'impression est disponible … la suite de
   --  'titre' sur l'écran du menu
begin
   Increment (Men.Compteur_Article, 1);
   Men.As := Lvaleur (Men.Article_Selectionne);
   Men.A := Lvaleur (Men.Compteur_Article);
   if Men.A = Men.As then
      if Men.Entree_Demandee then
         Men.Entree_Demandee := False;
         Men.Rafraichi := True;
         return True;
      else
         Men.Impf (Titre);
      end if;
   else
      Men.Imps (Titre);
   end if;
   return False;
end T;

procedure T (
      Men   : access Menu;
      Titre :        String) is
begin
   if Men.T (Titre) then
      null;
   end if;
end T;

function O (
      Men   : access Menu;
      Titre :        String)
  return Boolean is
   --  Fonction de contrôle d'un Article de menu. L'activation produit
   --  l'effacement de l'écran et l'impression de 'titre' au milieu du sommet
   --  de l'écran A l'issue de l'action le même Article reste sélectionné
begin
   Increment (Men.Compteur_Article, 1);
   Men.As := Lvaleur (Men.Article_Selectionne);
   Men.A := Lvaleur (Men.Compteur_Article);
   if Men.A = Men.As then
      if Men.Entree_Demandee then
         Men.Entree_Demandee := False;
         Men.Rafraichi       := True;
         Men.Clear_Screen;
         Men.Impt (Titre);
         -- Put_Line ("");
         return True;
      else
         Men.Impf (Titre);
      end if;
   else
      Men.Imps (Titre);
   end if;
   return False;
end O;

function U (
      Men   : access Menu;
      Titre :        String)
  return Boolean is
   --  Fonction de controle d'un Article de menu. L'activation produit
   --  l'effacement de l'ecran et l'impression de 'titre' au milieu du
   --  sommet de l'ecran. A l'issue de l'action l'Article suivant est
   --  selectionné.
   V : Boolean;
begin
   V := Men.O (Titre);
   if V then
      Increment_Article_Selectionne (Men, 1);
      Men.Attend_Entree_Clavier := False;
   end if;
   return V;
end U;

procedure Affiche_Nombre (
      Men   : access Menu;
      Titre :        String;
      V     :        Long_Integer) is
begin
   Men.T (Titre & ": " & To_String (V));
end Affiche_Nombre;
procedure Affiche_Nombre (
      Men   : access Menu;
      Titre :        String;
      V     :        Integer) is
begin
   Men.T (Titre & ": " & To_String (V));
end Affiche_Nombre;

procedure Affiche_Nombre (
      Men   : access Menu;
      Titre :        String;
      V     :        Long_Float;
      Aft   : in     Ada.Text_Io.Field := Default_Aft;
      Exp   : in     Ada.Text_Io.Field := Default_Exp) is
begin
   Men.T (Titre & ": " & To_String (V, Aft, Exp));
end Affiche_Nombre;

--FUNCTION Nombre (
--      Men   : ACCESS Menu;
--      Titre :        String;
--      V     : ACCESS Long_Float;
--      Aft   : IN     Ada.Text_Io.Field := Default_Aft;
--      Exp   : IN     Ada.Text_Io.Field := Default_Exp)
--  RETURN Boolean IS
--   --  Presentation pour modification d'un nombre reel
--   Btitre,
--   Bnombre,
--   Bligne  : My_String.Bounded_String;
--   Snombre : String (1 .. 35);
--   Us      : Unbounded_String;
--BEGIN
--   Btitre := To_Bounded_String (Titre);
--   Put (
--      To   => Snombre,
--      Item => V.All,
--      Aft  => Aft,
--      Exp  => Exp);
--   Bnombre := To_Bounded_String (Snombre);
--   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
--   Bligne  := Titre & ": " & Bnombre;
--   Increment (Men.Compteur_Article, 1);
--   Men.A := Lvaleur (Men.Compteur_Article);
--   IF Men.A = Men.As THEN
--      IF Men.Entree_Demandee THEN
--         Men.Entree_Demandee := False;
--         Men.Rafraichi       := True;
--         --  Men.Impf_Limite (To_String (Bligne));
--         Men.Impf (To_String (Bligne));
--         Put (" ?: ");
--         Get (V.All);
--         --  vidage tempon nécessaire pour ne pas interférer avec les
--         --  saisies suivantes
--         Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
--         RETURN True;
--      ELSE
--         Men.Impf (To_String (Bligne));
--      END IF;
--   ELSE
--      Men.Imps (To_String (Bligne));
--   END IF;
--   RETURN False;
--EXCEPTION
--   WHEN Data_Error =>
--      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
--      Bleep;
--      RETURN False;
--END Nombre;

function Nombre (
      Men   : access Menu;
      Titre :        String;
      V     : access Long_Float;
      Aft   : in     Ada.Text_Io.Field := Default_Aft;
      Exp   : in     Ada.Text_Io.Field := Default_Exp)
  return Boolean is
   --  Presentation pour modification d'un nombre reel
   --   Btitre,
   Bnombre,
   Bligne  : My_String.Bounded_String;
   Snombre : String (1 .. 35);
   Us      : Unbounded_String;
begin
   -- btitre := to_bounded_string (titre);
   Put (
      To   => Snombre,
      Item => V.All,
      Aft  => Aft,
      Exp  => Exp);
   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bnombre;
   if Men.T(To_String(Bligne)) then
      declare
         Las : constant Integer := Lvaleur (Men.Fenetre);
         --         Ligne : String (1 .. Men.X2 - Men.F.X1 - 1);
      begin
         Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + Las + 2, "=>", To_String(
               Bligne)& " ?: ");
         Get (V.All);
         --  vidage tempon nécessaire pour ne pas interférer avec les saisies suivantes
         Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
         Men.Rafraichi       := True;
         return True;
      end;
   else
      return False;
   end if;
exception
   when Data_Error =>
      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
      Bleep;
      Men.Rafraichi       := True;
      return False;
end Nombre;

procedure Locate (
      Men : access Menu) is
   Pink_Line  : constant String := (Men.X2 - Men.X1 + 1) * "-";
   Blank_Line : constant String := (Men.X2 - Men.X1 + 1) * " ";
begin
   Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + 1, "", Pink_Line);
   delay 0.41;
   Ecran.Ecrit (Men.F.X1, Men.F.Y1 + 1, "", Blank_Line);
end;

function Nombre (
      Men   : access Menu;
      Titre :        String;
      V     : access Long_Integer)
  return Boolean is
   --  Presentation pour modification d'un nombre reel
   Bnombre,
   Bligne  : My_String.Bounded_String;
   Snombre : String (1 .. 35);
   Us      : Unbounded_String;
begin
   Long_Integer_Io.Put (
      To   => Snombre,
      Item => V.All);
   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bnombre;
   if Men.T(To_String(Bligne)) then
      declare
         Las   : constant Integer                             := Lvaleur (Men.Fenetre);
         Ligne :          String (1 .. Men.X2 - Men.F.X1 - 1);
      begin
         Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + Las + 2, "=>", To_String(
               Bligne)& " ?: ");
         Get (V.All);
         --  vidage tempon nécessaire pour ne pas interférer avec les saisies suivantes
         Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
         Men.Rafraichi       := True;
         return True;
      end;
   end if;
   return False;
exception
   when Data_Error =>
      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
      Bleep;
      Men.Rafraichi       := True;
      return False;
end Nombre;

function Nombre (
      Men   : access Menu;
      Titre :        String;
      V     : access Integer)
  return Boolean is
   --  Presentation pour modification d'un nombre reel
   Btitre,
   Bnombre,
   Bligne  : My_String.Bounded_String;
   Snombre : String (1 .. 35);
   Us      : Unbounded_String;
begin
   -- btitre := to_bounded_string (titre);
   Ada.Integer_Text_Io.Put (
      To   => Snombre,
      Item => V.All);
   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bnombre;
   if Men.T(To_String(Bligne)) then
      declare
         Las   : Integer                             := Lvaleur (Men.Fenetre);
         Ligne : String (1 .. Men.X2 - Men.F.X1 - 1);
      begin
         Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + Las + 2, "=>", To_String(
               Bligne)& " ?: ");
         Get (V.All);
         --  vidage tempon nécessaire pour ne pas interférer avec les saisies suivantes
         Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
         Men.Rafraichi       := True;
         return True;
      end;
   end if;
   return False;
exception
   when Data_Error =>
      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
      Bleep;
      Men.Rafraichi       := True;
      return False;
end Nombre;

function Input_Nombre (
      Men   : access Menu;
      Titre :        String;
      V     : access Integer)
  return Boolean is
   --  Presentation pour modification d'un nombre reel
   Btitre,
   Bnombre,
   Bligne  : My_String.Bounded_String;
   Snombre : String (1 .. 35);
   Us      : Unbounded_String;
begin
   Ada.Integer_Text_Io.Put (
      To   => Snombre,
      Item => V.All);
   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bnombre;
   if Men.T(To_String(Bligne)) then
      Put (" ?: ");
      Get (V.All);
      Men.Rafraichi := True;
      --  vidage tempon nécessaire pour ne pas interférer avec les
      --  saisies suivantes
      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
   end if;
   return False;
exception

   when Data_Error =>
      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
      Men.Rafraichi := True;
      Bleep;
      return False;
end Input_Nombre;

function Nombre (
      Men   : access Menu;
      Titre :        String;
      R     :        Long_Float;
      Aft   : in     Ada.Text_Io.Field := Default_Aft;
      Exp   : in     Ada.Text_Io.Field := Default_Exp)
  return Boolean is
   Btitre,
   Bnombre,
   Bligne  : My_String.Bounded_String;
   Snombre : String (1 .. 35);
   Us      : Unbounded_String;
begin
   Btitre := To_Bounded_String (Titre);
   --  put(SNombre, R);
   Put (
      To   => Snombre,
      Item => R,
      Aft  => Aft,
      Exp  => Exp);
   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bnombre;
   return Men.T (To_String (Bligne));
end Nombre;

function Nombre (
      Men   : access Menu;
      Titre :        String;
      R     :        Long_Integer)
  return Boolean is
   Btitre,
   Bnombre,
   Bligne  : My_String.Bounded_String;
   Snombre : String (1 .. 35);
   Us      : Unbounded_String;
begin
   Btitre := To_Bounded_String (Titre);
   --  put(SNombre, R);
   Put (
      To   => Snombre,
      Item => R);
   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bnombre;
   return Men.T (To_String (Bligne));
end Nombre;

function Nombre (
      Men   : access Menu;
      Titre :        String;
      R     :        Integer)
  return Boolean is
   Btitre,
   Bnombre,
   Bligne  : My_String.Bounded_String;
   Snombre : String (1 .. 35);
   Us      : Unbounded_String;
begin
   Btitre := To_Bounded_String (Titre);
   --  put(SNombre, R);
   Put (
      To   => Snombre,
      Item => R);
   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bnombre;
   return Men.T (To_String (Bligne));
end Nombre;

procedure Nombre (
      Men   : access Menu;
      Titre : in     String;
      R     : in out Long_Float;
      Aft   : in     Ada.Text_Io.Field := Default_Aft;
      Exp   : in     Ada.Text_Io.Field := Default_Exp) is
   Tempo : aliased Long_Float := R;
begin
   if Men.Nombre (Titre, Tempo'access, Aft, Exp) then
      R := Tempo;
   end if;
end Nombre;

procedure Nombre (
      Men   : access Menu;
      Titre : in     String;
      R     : in out Long_Integer) is
   Tempo : aliased Long_Integer := R;
begin
   if Men.Nombre (Titre, Tempo'access) then
      R := Tempo;
   end if;
end Nombre;

procedure Nombre (
      Men   : access Menu;
      Titre : in     String;
      R     : in out Integer) is
   Tempo : aliased Integer := R;
begin
   if Men.Nombre (Titre, Tempo'access) then
      R := Tempo;
   end if;
end Nombre;

procedure Modifie_Nombre (
      Men :        Menu_Ptr;
      T   :        String;
      N   : in out Integer) is
   C : constant Integer_Pointeur :=
   new Integer'(0);
   K0 : Character;

begin
   if Men.T(T & ": "& Integer'Image(N)) then
      loop
         Men.Impf("  "&T & ": "& Integer'Image(N));
         K0 := Men.Get_Key;
         case  K0 is
            when Key_Up  =>
               N:=N+1;
            when Key_Down =>
               N:=N-1;
            when Key_Right =>
               declare
                  Us : Unbounded_String;
               begin
                  Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + Lvaleur(
                        Men.Fenetre) + 2, "=>", "  "&T & ": "&
                     Integer'Image(N) &" :?");
                  Get (N);
                  --  vidage tempon nécessaire pour ne pas interférer avec les saisies suivantes
                  Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
                  exit;
               exception
                  when others =>
                     Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
                     Bleep;
               end;
            when Key_Left =>
               exit;
            when others =>
               null;
         end case;
      end loop;
   end if;
end;

procedure Modifie_Nombre (
      Men :        Menu_Ptr;
      T   :        String;
      N   : in out Long_Integer) is
   --   C : constant Integer_Pointeur :=
   --   new Integer'(0);
   K0 : Character;

begin
   if Men.T(T & ": "& Long_Integer'Image(N)) then
      loop
         Men.Impf("  "&T & ": "& Long_Integer'Image(N));
         K0 := Men.Get_Key;
         case  K0 is
            when Key_Up  =>
               N:=N+1;
            when Key_Down =>
               N:=N-1;
            when Key_Right =>
               declare
                  Us : Unbounded_String;
               begin
                  Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + Lvaleur(
                        Men.Fenetre) + 2, "=>", "  "&T & ": "&
                     Long_Integer'Image(N) &" :?");
                  Get (N);
                  --  vidage tempon nécessaire pour ne pas interférer avec les saisies suivantes
                  Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
                  exit;
               exception
                  when others =>
                     Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
                     Bleep;
               end;
            when Key_Left =>
               exit;
            when others =>
               null;
         end case;
      end loop;
   end if;
end;

procedure Point (
      Men       : access Menu;
      Message   : in     String;
      X,
      Y         : in out Integer;
      Message_X : in     String  := "Abscisse";
      Message_Y : in     String  := "Ordonnee") is

   C : constant Integer_Pointeur :=
   new Integer'(0);
begin
   while Men.M
         (Message &
         ": " &
         Message_X &
         ": " &
         To_String (X) &
         " , " &
         Message_Y &
         ": " &
         To_String (Y),
         C)
         loop
      Men.Nombre (Message_X, X);
      if Men.T ("increase") then
         X := X + 1;
      end if;
      if Men.T ("decrease") then
         X := X - 1;
      end if;
      Men.T ("");
      Men.Nombre (Message_Y, Y);
      if Men.T ("increase") then
         Y := Y + 1;
      end if;
      if Men.T ("decrease") then
         Y := Y - 1;
      end if;
   end loop;
end Point;

procedure Point (
      Men       : access Menu;
      Message   : in     String;
      X,
      Y         : in out Long_Float;
      Message_X : in     String            := "Abscisse";
      Message_Y : in     String            := "Ordonnee";
      Aft       : in     Ada.Text_Io.Field := Default_Aft;
      Exp       : in     Ada.Text_Io.Field := Default_Exp) is

   C : constant Integer_Pointeur :=
   new Integer'(0);
begin
   while Men.M
         (Message &
         "=> " &
         Message_X &
         ": " &
         To_String (X, Aft => Aft, Exp => Exp) &
         " , " &
         Message_Y &
         ": " &
         To_String (Y, Aft => Aft, Exp => Exp),
         C)
         loop
      Men.Nombre (Message_X, X, Aft => Aft, Exp => Exp);
      if Men.T ("increase") then
         X := X + 1.0;
      end if;
      if Men.T ("decrease") then
         X := X - 1.0;
      end if;
      Men.T ("");
      Men.Nombre (Message_Y, Y, Aft => Aft, Exp => Exp);
      if Men.T ("increase") then
         Y := Y + 1.0;
      end if;
      if Men.T ("decrease") then
         Y := Y - 1.0;
      end if;
   end loop;
end Point;

procedure Cercle (
      Men       : access Menu;
      Message   : in     String;
      X,
      Y,
      R         : in out Integer;
      Message_X : in     String  := "Abscisse";
      Message_Y : in     String  := "Ordonnee";
      Message_R : in     String  := "Rayon") is

   C : constant Integer_Pointeur :=
   new Integer'(0);
begin
   while Men.M
         (Message &
         ": " &
         Message_X &
         ": " &
         To_String (X) &
         " , " &
         Message_Y &
         ": " &
         To_String (Y) &
         " , " &
         Message_R &
         ": " &
         To_String (R),
         C)
         loop
      Men.Nombre (Message_X, X);
      if Men.T ("increase") then
         X := X + 1;
      end if;
      if Men.T ("decrease") then
         X := X - 1;
      end if;
      Men.T ("");
      Men.Nombre (Message_Y, Y);
      if Men.T ("increase") then
         Y := Y + 1;
      end if;
      if Men.T ("decrease") then
         Y := Y - 1;
      end if;
      Men.T ("");
      Men.Nombre (Message_R, R);
      if Men.T ("increase") then
         R := R + 1;
      end if;
      if Men.T ("decrease") then
         R := R - 1;
      end if;
   end loop;
end Cercle;

procedure Message (
      Men   : access Menu;
      Titre : in     String) is
   C : constant Integer_Pointeur :=
   new Integer'(0);

begin
   while Men.M1 (Titre, C) loop
      null;
   end loop;
end Message;

procedure Chaine (
      Men   : access Menu;
      Titre :        String;
      V     : in out String) is
   W : aliased String := V;
begin
   Move (V, W, Ada.Strings.Right);
   if Men.Chaine (Titre, W'access) then
      Move (W, V, Ada.Strings.Right);
   end if;
end Chaine;

function Chaine (
      Men   : access Menu;
      Titre :        String;
      V     : access String)
  return Boolean is
   --  Presentation pour modification d'une chaine ce caracteres
   Btitre,
   Bchaine,
   Bligne  : My_String.Bounded_String;
   Us      : Unbounded_String;
begin
   Btitre  := To_Bounded_String (Titre);
   Bchaine := To_Bounded_String (V.All);
   Bchaine := My_String.Trim (Bchaine, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bchaine;
   Increment (Men.Compteur_Article, 1);
   Men.A := Lvaleur (Men.Compteur_Article);
   if Men.A = Lvaleur (Men.Article_Selectionne) then
      if Men.Entree_Demandee then
         Men.Entree_Demandee := False;
         Men.Rafraichi       := True;
         --  Men.Impf_Limite (To_String (Bligne));
         Men.Impf (To_String (Bligne));
         Put (" ?: ");
         Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
         Ada.Strings.Fixed.Move (To_String (Us), V.All, Ada.Strings.Right);
         --  vidage tempon nécessaire pour ne pas interférer avec les
         --  saisies suivantes
         return True;
      else
         Men.Impf (To_String (Bligne));
      end if;
   else
      Men.Imps (To_String (Bligne));
   end if;
   return False;
exception
   when Data_Error =>
      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
      Bleep;
      return False;
end Chaine;

function Chaine (
      Men   : access Menu;
      Titre :        String;
      V     :        String)
  return Boolean is
   Btitre,
   Bchaine,
   Bligne  : My_String.Bounded_String;
   Us      : Unbounded_String;
begin
   Btitre  := To_Bounded_String (Titre);
   Bchaine := To_Bounded_String (V);
   Bchaine := My_String.Trim (Bchaine, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bchaine;
   return Men.T (To_String (Bligne));
end Chaine;

procedure Chaine (
      Men   : access Menu;
      Titre :        String;
      V     : in out My_String.Bounded_String) is
   W : aliased My_String.Bounded_String := V;
begin
   --  Move(V,W,Ada.Strings.Right);
   W := V;
   if Men.Chaine (Titre, W'access) then
      --  Move(W,V,Ada.Strings.Right);
      V := W;
   end if;
end Chaine;

function Chaine (
      Men   : access Menu;
      Titre :        String;
      V     : in out Unbounded_String)
  return Boolean is
   --  Presentation pour modification d'une chaine ce caracteres
   Btitre,
   Bchaine,
   Bligne  : My_String.Bounded_String;
   Us      : Unbounded_String;
begin
   Btitre  := To_Bounded_String (Titre);
   Bchaine := To_Bounded_String (To_String (V));
   Bchaine := My_String.Trim (Bchaine, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bchaine;
   Increment (Men.Compteur_Article, 1);
   Men.A := Lvaleur (Men.Compteur_Article);
   if Men.A = Lvaleur (Men.Article_Selectionne) then
      if Men.Entree_Demandee then
         Men.Entree_Demandee := False;
         Men.Rafraichi       := True;
         Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + Lvaleur (Men.Fenetre) + 2, "=>", Titre);
         Put (": " & To_String(V));         
         Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + Lvaleur (Men.Fenetre) + 2, "=>", Titre);
         Put (": ");
         Set_Cursor(True); 
         Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
         Set_Cursor(False);
         V := Us;
         return True;
      else
         Men.Impf (To_String (Bligne));
      end if;
   else
      Men.Imps (To_String (Bligne));
   end if;
   return False;
exception
   when Data_Error =>
      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
      Bleep;
      return False;
end Chaine;

function Chaine (
      Men   : access Menu;
      Titre :        String;
      V     :        My_String.Bounded_String)
  return Boolean is
   Btitre,
   Bchaine,
   Bligne  : My_String.Bounded_String;
   Us      : Unbounded_String;
begin
   Btitre := To_Bounded_String (Titre);
   --  Bchaine:=To_Bounded_String(V);
   Bchaine := My_String.Trim (Bchaine, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bchaine;
   return Men.T (To_String (Bligne));
   end Chaine;
   
   function Chaine (
      Men   : access Menu;
      Titre :        String;
      V     : access My_String.Bounded_String)
  return Boolean is
   --  Presentation pour modification d'une chaine ce caracteres
   Btitre,
   Bchaine,
   Bligne  : My_String.Bounded_String;
   Us      : Unbounded_String;
begin
   Btitre  := To_Bounded_String (Titre);
   Bchaine := V.All;
   Bchaine := My_String.Trim (Bchaine, Side => Ada.Strings.Both);
   Bligne  := Titre & ": " & Bchaine;
   Increment (Men.Compteur_Article, 1);
   Men.A := Lvaleur (Men.Compteur_Article);
   if Men.A = Lvaleur (Men.Article_Selectionne) then
      if Men.Entree_Demandee then
         Men.Entree_Demandee := False;
         Men.Rafraichi       := True;
         --  Men.Impf_Limite (To_String (Bligne));
         Men.Impf (To_String (Bligne));

         Put (" ?: ");
         Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
         --  Ada.Strings.Fixed.Move(To_String(Us),V.all,Ada.Strings.Right);
         V.All := To_Bounded_String (To_String (Us));
         --  vidage tempon nécessaire pour ne pas interférer avec les
         --  saisies suivantes
         return True;
      else
         Men.Impf (To_String (Bligne));
      end if;
   else
      Men.Imps (To_String (Bligne));
   end if;
   return False;
exception
   when Data_Error =>
      Us := Ada.Strings.Unbounded.Text_Io.Get_Line;
      Bleep;
      return False;
end Chaine;
   
 

procedure Imp (
      Men : access Menu) is
   --  Acquisition des caracteristiques d'affichage du menu
begin
   Screen_Dimension;
   Cadre.Xr2 := Cadre.Xr1 + Wx - 1;
   Cadre.Yr2 := Cadre.Yr1 + Wy - 1;
   -- if Men.Visible then
   Men.F.X1 := Men.F.Xr1 - Cadre.Xr1;
   Men.F.Y1 := Men.F.Yr1 - Cadre.Yr1;
   Men.F.X2 := Men.F.Xr2 - Cadre.Xr1;
   Men.F.Y2 := Men.F.Yr2 - Cadre.Yr1;
   -- end if;
end Imp;

procedure Impt (
      Men   : access Menu;
      Titre :        String) is
   --  Impression de Titre en haut et au milieu de l'ecran
   S : String (1 .. Men.X2 - Men.F.X1 + 1);
   --  w                             : Integer := Men.X2 - Men.F.X1 + 1;
   --  l, marge_gauche, marge_droite : Integer := 0;
   --  blanc: UnBounded_string;
   --  Me parait Ok
begin
   --  On suppose dans une première approche que le menu tient entièrement
   --  dans la fenêtre de l'écran. Cette contrainte sera relachée
   --  ultérieurement.
   if Men.F.Visible and then Men = Men.F.Menu_En_Cours then
      -- Ecran.Goto_XY (Men.F.X1, Men.F.Y1);
      Move
         (Titre,
         S,
         Ada.Strings.Right,
         Justify => Ada.Strings.Center,
         Pad     => ' ');
      Ecran.Ecrit (Men.F.X1, Men.F.Y1, "", S);

      --           --        if Men.Stockage then
      --           --           Put (Fichier_Sortie, Marge_Gauche * '
      --');
      --           --           Put (Fichier_Sortie, Titre);
      --           --           Put (Fichier_Sortie, Marge_Droite * '
      --');
      --           --           New_Line (Fichier_Sortie);
      --           --        end if;
      --           else
      --              Put (Titre (Titre'First .. w));
      --              --        if Men.Stockage then
      --              --           Put (Fichier_Sortie, Titre(1..W));
      --              --           New_Line (Fichier_Sortie);
      --              --        end if;
      --           end if;
   end if;
end Impt;

---------------------
-- Efface_Fin_Menu --
---------------------

procedure Efface_Fin_Menu (
      Men : access Menu) is
   As         : Integer := Lvaleur (Men.Article_Selectionne);
   Las        : Integer := Lvaleur (Men.Fenetre);
   U          : Integer;
   Blank_Line : String  := (Men.X2 - Men.X1 + 1) * " ";
begin
   if Men.F.Visible and then Men = Men.F.Menu_En_Cours then
      if Men.Nombre_Article = 0 then
         for L in Men.Y1+2.. Men.Y2 loop
            Ecran.Ecrit (Men.X1, L, "", Blank_Line);
         end loop;
      else
         U := Men.Nombre_Article - As + Las ;
         for L in U + 1 .. Men.Y2-Men.Y1-2 loop
            Ecran.Ecrit (Men.X1, L+2, "", Blank_Line);
         end loop;
         Ecran.Ecrit (Men.X1, Men.Y1 + 1, "", Blank_Line);
      end if;
   end if;
end Efface_Fin_Menu;

procedure Imps (
      Men   : access Menu;
      Titre :        String) is
   --  Impression d'un Article 'Titre' non selectionne. Sans flèche.
   As    : Integer                             := Lvaleur (Men.Article_Selectionne);
   Las   : Integer                             := Lvaleur (Men.Fenetre);
   U     : Integer;
   Ligne : String (1 .. Men.X2 - Men.F.X1 - 1);
   --  Me parait Ok : C'était optimiste et peu clairvoyant !--        u := las
   --+ as - aas;
   --        if u < 0 then
   --           u := 0;
   --        elsif u > Men.Y2 - Men.F.Y1 - 1 then
   --           u := Men.Y2 - Men.F.Y1 - 1;
   --        end if;
   --        mvaleur (Men.Fenetre, u);
begin
   --  L'article est affiché seulement s'il apparaît en même temps que
   --  l'article sélectionné
   if Men.F.Visible and then Men = Men.F.Menu_En_Cours then
      U := Las + Men.A - As;
      if (0 <= U) and (U <= Men.Y2 - Men.F.Y1 - 2) then
         -- y2-y1+1-2=Umax-0+1
         --  Sinon l'article n'est pas affiché
         Move (Titre, Ligne, Ada.Strings.Right);
         Ecran.Ecrit (Men.F.X1, Men.F.Y1 + U + 2, "  ", Ligne);
      end if;
      --    Set_Foreground (White);
      --           Put ("  ");
      --           Move (Titre, ligne, Ada.Strings.Right);
      --           Put (ligne);
   end if;
   --        if Men.Stockage then
   --           Put (Fichier_Sortie, "  ");
   --           Move (Titre, Ligne);
   --           Put (Fichier_Sortie, Ligne);
   --           New_Line (Fichier_Sortie);
   --        end if;
end Imps;

procedure Impf (
      Men   : access Menu;
      Titre :        String) is
   --  Impression d'un Article 'titre' selectionne
   --        u     : Integer;
   --        as    : Integer := lvaleur (Men.Article_selectionne);
   --        aas   : Integer := lold_valeur (Men.Article_selectionne);
   Las   : constant Integer                             := Lvaleur (Men.Fenetre);
   Ligne :          String (1 .. Men.X2 - Men.F.X1 - 1);

begin
   if Men.F.Visible and then Men = Men.F.Menu_En_Cours then
      Move (Titre, Ligne, Ada.Strings.Right);
      Ecran.Ecritcolor (Men.F.X1, Men.F.Y1 + Las + 2, "=>", Ligne);

   end if;

   --   if Men.Stockage then
   --      Put (Fichier_Sortie, "=>");
   --      Move (Titre, Ligne);
   --      Put (Fichier_Sortie, Ligne);
   --      New_Line (Fichier_Sortie);
   --   end if;
end Impf;

--procedure impf_court (
--      men   : access menu;
--      titre :        string) is
--   las : integer := lvaleur (men.fenetre);
--begin
--   if men.f.visible then
--      ecran.ecritcolor (men.f.x1, men.f.y1 + las + 2, "=>", titre);
--   end if;
--end impf_court;


--procedure impf_limite (
--      men   : access menu;
--      titre :        string) is
--   --  Impression d'un Article 'titre' selectionne

--begin
--   --  U := Men.A - Men.B + 2;
--   --   IF (2 <= U) AND (U <= Men.H) THEN
--   --      Goto_XY (0, U);
--   --      Put ("=>");
--   --      Set_Foreground (Magenta);
--   --      Put (Titre);
--   --      Set_Foreground (White);
--   --   END IF;
--   if men.stockage then
--      put (fichier_sortie, "=>");
--      put (fichier_sortie, titre);
--      new_line (fichier_sortie);
--   end if;
--end impf_limite;
function Nombre_To_String (
      R : Long_Integer)
  return String is
   Bnombre : My_String.Bounded_String;
   Snombre : String (1 .. 35);
begin
   Put (
      To   => Snombre,
      Item => R);
   Bnombre := To_Bounded_String (Snombre);
   Bnombre := My_String.Trim (Bnombre, Side => Ada.Strings.Both);
   return To_String (Bnombre);
end Nombre_To_String;
procedure Boucle (
      Men : access Menu) is
begin
   Mvaleur (Men.Compteur_Article, 0);
   Men.Rafraichi := True;
end Boucle;

procedure Increment_Article_Selectionne (
      Men : access Menu;
      I   : in     Integer) is
   As,
   Nas,
   U   : Integer;
begin
   As := Lvaleur (Men.Article_Selectionne);
   if Men.Nombre_Article = 0 then
      Nas := 1;
   else
      Nas := ((As - 1 + I + Men.Nombre_Article) mod Men.Nombre_Article) +
         1;
   end if;
   U := Lvaleur (Men.Fenetre) + Nas - As;
   if U < 0 then
      U := 0;
   elsif U > Men.Y2 - Men.F.Y1 - 2 then
      U := Men.Y2 - Men.F.Y1 - 2;
   end if;
   Mvaleur (Men.Fenetre, U);
   Mvaleur (Men.Article_Selectionne, V => Nas);
end Increment_Article_Selectionne;

procedure Modifie_Article_Selectionne (
      Men : access Menu;
      V   : in     Integer) is
   As,
   Nas,
   U   : Integer;
begin
   As := Lvaleur (Men.Article_Selectionne);
   if Men.Nombre_Article = 0 then
      Nas := 1;
   else
      Nas := ((V - 1 + Men.Nombre_Article) mod Men.Nombre_Article) + 1;
   end if;
   U := Lvaleur (Men.Fenetre) + Nas - As;
   if U < 0 then
      U := 0;
   elsif U > Men.Y2 - Men.F.Y1 - 2 then
      U := Men.Y2 - Men.F.Y1 - 2;
   end if;
   Mvaleur (Men.Fenetre, V => U);
   Mvaleur (Men.Article_Selectionne, V => Nas);
end Modifie_Article_Selectionne;
procedure Clear_Screen (
      Men : access Menu) is
begin
   if Men.F.Visible and then Men = Men.F.Menu_En_Cours then
      Men.F.Clear_Screen;
   end if;
end Clear_Screen;
function X1 (
      Men : access Menu)
  return Integer is
begin
   return Men.F.X1;
end X1;
function Y1 (
      Men : access Menu)
  return Integer is
begin
   return Men.F.Y1;
end Y1;
function X2 (
      Men : access Menu)
  return Integer is
begin
   return Men.F.X2;
end X2;
function Y2 (
      Men : access Menu)
  return Integer is
begin
   return Men.F.Y2;
end Y2;

Xs1 : Integer renames Cadre.Xr1;
Ys1 : Integer renames Cadre.Yr1;
Xs2 : Integer renames Cadre.Xr2;
Ys2 : Integer renames Cadre.Yr2;

begin
   Set_Background (Black);
   Set_Foreground (White);
   Set_Cursor (False);
   Screen_Dimension;
   Cadre.Xr1 := 1;
   Cadre.Yr1 := 1;
   Cadre.Xr2 := Cadre.Xr1 + Wx - 1;
   Cadre.Yr2 := Cadre.Yr1 + Wy - 1;

   F0 := Init (Xs1, Ys1,Xs2,Ys2);
   Full_Console := F0;

   F1 := Init (1, 1, Xs2 / 2, Ys2 / 2);
   F2 := Init (Xs2 / 2 + 1, 1, Xs2, Ys2 /2);
   F3 := Init (1, Ys2 / 2 + 1, Xs2 / 2, Ys2);
   F4 := Init (Xs2 / 2 + 1, Ys2 / 2 + 1, Xs2, Ys2 );

   Fgauche := Init (1, 1, Xs2 / 2, Ys2);
   Fdroite := Init (Xs2 / 2 + 1, 1, Xs2, Ys2);

   Fhaut := Init (1, 1, Xs2, Ys2 / 2);
   Fbas := Init (1, Ys2 / 2 + 1, Xs2, Ys2);
   
   Fgauche_L := Init (1, 1, (Xs2 / 2) + 60, Ys2);
   Fdroite_E := Init ((Xs2 / 2) + 60 + 1, 1, Xs2, Ys2);
end Menusnew;
