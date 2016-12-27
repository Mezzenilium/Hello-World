-- with ADA.Finalization ; use ADA.Finalization;
with Unchecked_Deallocation;

package Pile_Entier is

   -- Package to provide Stack of integers.
   --p_el=^elen;
   type Pile_Noeud; -- Incomplete type declaration.
   type Noeud_Access is access Pile_Noeud;

   type Pile_Noeud is record
      p_suiv : Noeud_Access;
      val    : Integer;
      -- old_Val: integer := 1;
   end record;

   -- type PILE_entier is new limited_controlled with record
   type PILE_entier is record
      haut : Noeud_Access;
   end record;
   procedure Free is new Unchecked_Deallocation (Pile_Noeud, Noeud_Access);

   --   procedure Initialize(Object : in out Pile_Entier);
   --procedure Finalize  (Object : in out Pile_Entier);
   procedure empile (P : in out PILE_entier; V : Integer);
   procedure depile (P : in out PILE_entier; V : out Integer);
   procedure increment (P : in PILE_entier; V : in Integer);
   procedure mvaleur (P : in PILE_entier; V : Integer);
   function lvaleur (p : in PILE_entier) return Integer;
   --    FUNCTION lold_valeur(P:in Pile_entier)return integer;
end Pile_Entier;
