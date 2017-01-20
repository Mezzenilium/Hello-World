WITH Buffer;
USE Buffer;
WITH Ada.Finalization;
USE Ada.Finalization;
WITH Ada.Containers;
USE Ada.Containers;
WITH Ada.Containers.Ordered_Maps;
WITH Ada.Text_Io;
USE Ada.Text_Io;
with ada.strings.unbounded;
use ada.strings.unbounded;
WITH Ada.Long_Float_Text_Io;
USE Ada.Long_Float_Text_Io;
WITH My_Declarations;
USE My_Declarations;
WITH Pile_Entier;
USE Pile_Entier;

WITH Ada.Unchecked_Deallocation;
--use Ada.Unchecked_Deallocation;

PACKAGE Menusnew IS
   PRAGMA Elaborate_Body;
   PACKAGE Long_Integer_Io IS NEW Ada.Text_Io.Integer_Io (Long_Integer);
   USE Long_Integer_Io;

   TYPE Integer_Pointeur IS ACCESS ALL Integer;
   
   procedure Free is new Ada.Unchecked_Deallocation (Integer, Integer_Pointeur);

   TASK Keyboard_Handler;

   PROTECTED Numeros IS
      PROCEDURE Get (
            Numero :    OUT Long_Integer);
   PRIVATE
      Count : Long_Integer := 0;
   END Numeros;

   TYPE Menu;
   TYPE Menu_Ptr IS ACCESS ALL Menu;

   PACKAGE Store_Menus IS NEW Ordered_Maps (
      Key_Type     => Long_Integer,
      Element_Type => Menu_Ptr,
      "<" => "<");
   USE Store_Menus;

   TYPE Rectangle IS NEW Controlled WITH
      RECORD
         Xr1 : Integer;          -- Coordonnees  point Haut - Gauche du menu dans l'écran
         Yr1 : Integer;
         Xr2 : Integer;          -- Coordonnees  point Bas - Droit du menu dans l'écran
         Yr2 : Integer;
      END RECORD;

   TYPE Fenetre IS NEW Rectangle WITH
      RECORD
         X1 : Integer; -- Coordonnées  point Haut - Gauche du menu
         --dans l'écran
         Y1 : Integer;
         X2 : Integer; -- Coordonnées  point Bas - Droit du menu
         --dans l'écran
         Y2             : Integer;
         Menus_Associes : Store_Menus.Map;
         Menu_En_Cours  : Menu_Ptr        := NULL;
      END RECORD;

   TYPE Fenetre_Ptr IS ACCESS ALL Fenetre'Class;
   OVERRIDING   PROCEDURE Initialize (
         F : IN OUT Fenetre);

   -- Update  des pointeurs des menus
   OVERRIDING   PROCEDURE Finalize (
         F : IN OUT Fenetre);

   FUNCTION Init (
         Xr1,
         Yr1,
         Xr2,
         Yr2 : Integer)
     RETURN Fenetre_Ptr;

   -----------
   -- Ecrit --
   -----------

   PROCEDURE Ecrit (
         W : ACCESS Fenetre'Class;
         X,
         Y :        Integer;
         T :        String);

   ------------
   -- Efface --
   ------------

   PROCEDURE Efface (
         W : ACCESS Fenetre'Class);

   ------------------
   -- clear_screen --
   ------------------

   PROCEDURE Clear_Screen (
         W : ACCESS Fenetre'Class);

   FUNCTION Visible (
         W : ACCESS Fenetre'Class)
     RETURN Boolean;

   PROCEDURE Choix_Menu (
         D : ACCESS Menu);

   PROCEDURE Choix_Menu_Associe (
         D : ACCESS Menu);

   TYPE Menu IS NEW Limited_Controlled WITH
      RECORD
         F :  ACCESS Fenetre'Class := NULL;
   Keyboard              : Clavier_Ptr;
   K0                    : Character;
   Titre                 : String (1 .. 80);
   Numero                : Long_Integer;
   Rafraichi,
   Sortie_Demandee,
   Entree_Demandee,
   Impression,
   Stockage              : Boolean;
   Attend_Entree_Clavier : Boolean          := True;

   --  La fenêtre d'un menu doit pouvoir au moins afficher son titre et un
   --  article et donc avoir une hauteur supérieure ou égale à 3.
   A              : Integer;    -- Numéro de l'article en cours - Compteur d'article
   As             : Integer; -- Numero de l'article selectionne
   Nombre_Article : Integer; -- Nombre d'articles  du menu
   --  Historique: Nombre d'articles des menus
   Compteur_Article : Pile_Entier.Pile_Entier;
   --  Historique: Numeros des articles sélectionnés des menus
   Article_Selectionne : Pile_Entier.Pile_Entier;
   --  Historique: Position des articles sélectionnés des menus dans leurs
   --  fenetres
   Fenetre : Pile_Entier.Pile_Entier;
   --  Visible : Boolean := False;
   Go : Boolean;
   --  Fichier_Sortie: Ada.Text_io.file_type;
   -- Fichier_Sortie : File_Type;
   Nom_Fichier    : ALIASED String (1 .. 70);          -- := 70 * " ";
   Fichier_Existe : Boolean                  := False;
END RECORD;

USE My_String;

FUNCTION Init (
      T :        String;
      F : ACCESS Fenetre'Class)
  RETURN Menu_Ptr;

FUNCTION Init (
      T :        String;
      F : ACCESS Fenetre'Class)
  RETURN Menu;

OVERRIDING PROCEDURE Initialize (
      Men : IN OUT Menu);
OVERRIDING PROCEDURE Finalize (
      Men : IN OUT Menu);

FUNCTION Get_Key (
      W : Menu'Class)
  RETURN Character;

PROCEDURE Increment_Article_Selectionne (
      Men : ACCESS Menu;
      I   : IN     Integer);
PROCEDURE Modifie_Article_Selectionne (
      Men : ACCESS Menu;
      V   : IN     Integer);

-- function Visible (Men : access Menu) return Boolean;
FUNCTION M0 (
      Men     : ACCESS Menu;
      Titre   : IN     String;
      C       : ACCESS Integer;
      Message :        String  := "EXIT")
  RETURN Boolean;
FUNCTION M00 (
      Men   : ACCESS Menu;
      Titre : IN     String;
      C     : ACCESS Integer)
  RETURN Boolean;

FUNCTION M1 (
      Men   : ACCESS Menu;
      Titre :        String;
      C     : ACCESS Integer)
  RETURN Boolean;
FUNCTION M2 (
      Men   : ACCESS Menu;
      Titre :        String;
      C     : ACCESS Integer)
  RETURN Boolean;

FUNCTION M (
      Men   : ACCESS Menu;
      Titre : IN     String;
      C     : ACCESS Integer)
  RETURN Boolean;
FUNCTION T (
      Men   : ACCESS Menu;
      Titre :        String)
  RETURN Boolean;
PROCEDURE T (
      Men   : ACCESS Menu;
      Titre :        String);
FUNCTION O (
      Men   : ACCESS Menu;
      Titre :        String)
  RETURN Boolean;
FUNCTION U (
      Men   : ACCESS Menu;
      Titre :        String)
  RETURN Boolean;
PROCEDURE Fin (
      Men : ACCESS Menu);
PROCEDURE Update (
      Men : ACCESS Menu);
-- procedure Clear_Screen (Men : access Menu);
PROCEDURE Affiche_Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      V     :        Long_Integer);
PROCEDURE Affiche_Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      V     :        Integer);
PROCEDURE Affiche_Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      V     :        Long_Float;
      Aft   : IN     Ada.Text_Io.Field := Default_Aft;
      Exp   : IN     Ada.Text_Io.Field := Default_Exp);
FUNCTION Input_Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      V     : ACCESS Integer)
  RETURN Boolean;
FUNCTION Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      V     : ACCESS Long_Float;
      Aft   : IN     Ada.Text_Io.Field := Default_Aft;
      Exp   : IN     Ada.Text_Io.Field := Default_Exp)
  RETURN Boolean;
FUNCTION Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      V     : ACCESS Long_Integer)
  RETURN Boolean;
FUNCTION Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      V     : ACCESS Integer)
  RETURN Boolean;
FUNCTION Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      R     :        Long_Float;
      Aft   : IN     Ada.Text_Io.Field := Default_Aft;
      Exp   : IN     Ada.Text_Io.Field := Default_Exp)
  RETURN Boolean;
FUNCTION Nombre (
      Men   : ACCESS Menu;
      Titre :        String;
      R     :        Integer)
  RETURN Boolean;
PROCEDURE Nombre (
      Men   : ACCESS Menu;
      Titre : IN     String;
      R     : IN OUT Long_Float;
      Aft   : IN     Ada.Text_Io.Field := Default_Aft;
      Exp   : IN     Ada.Text_Io.Field := Default_Exp);
PROCEDURE Nombre (
      Men   : ACCESS Menu;
      Titre : IN     String;
      R     : IN OUT Long_Integer);
PROCEDURE Nombre (
      Men   : ACCESS Menu;
      Titre : IN     String;
      R     : IN OUT Integer);

PROCEDURE Modifie_Nombre (
      Men :        Menu_Ptr;
      T   :        String;
      N   : IN OUT Integer);

PROCEDURE Modifie_Nombre (
      Men :        Menu_Ptr;
      T   :        String;
      N   : IN OUT Long_Integer);

PROCEDURE Point (
      Men       : ACCESS Menu;
      Message   : IN     String;
      X,
      Y         : IN OUT Integer;
      Message_X : IN     String  := "Abscisse";
      Message_Y : IN     String  := "Ordonnee");
PROCEDURE Point (
      Men       : ACCESS Menu;
      Message   : IN     String;
      X,
      Y         : IN OUT Long_Float;
      Message_X : IN     String            := "Abscisse";
      Message_Y : IN     String            := "Ordonnee";
      Aft       : IN     Ada.Text_Io.Field := Default_Aft;
      Exp       : IN     Ada.Text_Io.Field := Default_Exp);
PROCEDURE Cercle (
      Men       : ACCESS Menu;
      Message   : IN     String;
      X,
      Y,
      R         : IN OUT Integer;
      Message_X : IN     String  := "Abscisse";
      Message_Y : IN     String  := "Ordonnee";
      Message_R : IN     String  := "Rayon");
FUNCTION Chaine (
      Men   : ACCESS Menu;
      Titre :        String;
      V     : ACCESS String)
  RETURN Boolean;
FUNCTION Chaine (
      Men   : ACCESS Menu;
      Titre :        String;
      V     :        String)
  RETURN Boolean;
PROCEDURE Chaine (
      Men   : ACCESS Menu;
      Titre :        String;
      V     : IN OUT String);
FUNCTION Chaine (
      Men   : ACCESS Menu;
      Titre :        String;
      V     : ACCESS My_String.Bounded_String)
  RETURN Boolean;
FUNCTION Chaine (
      Men   : ACCESS Menu;
      Titre :        String;
      V     :        My_String.Bounded_String)
  RETURN Boolean;
PROCEDURE Chaine (
      Men   : ACCESS Menu;
      Titre :        String;
                  V     : IN OUT My_String.Bounded_String);
function Chaine (
      Men   : access Menu;
      Titre :        String;
      V     : in out Unbounded_String)
  return Boolean;
PROCEDURE Message (
      Men   : ACCESS Menu;
      Titre : IN     String);
PROCEDURE Imp (
      Men : ACCESS Menu);
PROCEDURE Impt (
      Men   : ACCESS Menu;
      Titre :        String);
PROCEDURE Imps (
      Men   : ACCESS Menu;
      Titre :        String);
PROCEDURE Impf (
      Men   : ACCESS Menu;
      Titre :        String);
--procedure impf_court (
--      men   : access menu;
--      titre :        string);
--procedure impf_limite (
--      men   : access menu;
--      titre :        string);
PROCEDURE Efface_Fin_Menu (
      Men : ACCESS Menu);
PROCEDURE Boucle (
      Men : ACCESS Menu);
PROCEDURE Clear_Screen (
      Men : ACCESS Menu);
FUNCTION X1 (
      Men : ACCESS Menu)
  RETURN Integer;
FUNCTION Y1 (
      Men : ACCESS Menu)
  RETURN Integer;
FUNCTION X2 (
      Men : ACCESS Menu)
  RETURN Integer;
FUNCTION Y2 (
      Men : ACCESS Menu)
  RETURN Integer;
PROCEDURE Locate (
      Men : ACCESS Menu);


PROCEDURE Free IS
NEW Ada.Unchecked_Deallocation(Menu,Menu_Ptr);


PROCEDURE Add (
      Str : IN     String);
PROCEDURE Clear_To_End_Of_Line;
FUNCTION To_String (
      N : Integer)
  RETURN String;
FUNCTION To_String (
      N : Long_Integer)
  RETURN String;
FUNCTION To_String (
      N   :        Long_Float;
      Aft : IN     Ada.Text_Io.Field := Default_Aft;
      Exp : IN     Ada.Text_Io.Field := Default_Exp)
  RETURN String;
FUNCTION Nombre_To_String (
      R : Long_Integer)
  RETURN String;

-- Ensemble des menus crees
The_Store : Store_Menus.Map;

Menu_Courant : Menu_Ptr := NULL;
Clavier_Courant : Clavier_Ptr := NULL;
Cursor_Menu_Courant : Store_Menus.Cursor;

-- Définition de la zone ecran
Cadre : Rectangle;

Full_Console, F0,F1, F2, F3, F4, Fgauche, Fdroite, Fhaut, Fbas: Fenetre_Ptr;

Fgauche_L, Fdroite_E: Fenetre_Ptr;

Fichier_Sortie : File_Type;
END Menusnew;
