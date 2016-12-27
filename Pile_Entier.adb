package body Pile_Entier is
   procedure empile (P : in out PILE_entier; V : Integer) is
      P_New_Noeud : Noeud_Access;
   begin

      P_New_Noeud        := new Pile_Noeud;
      P_New_Noeud.p_suiv := P.haut;
      P_New_Noeud.val    := V;
      P.haut             := P_New_Noeud;
   end empile;

   procedure depile (P : in out PILE_entier; V : out Integer) is
      p_last_haut : Noeud_Access;
   begin
      p_last_haut := P.haut;
      V           := P.haut.val;
      P.haut      := P.haut.p_suiv;
      Free (p_last_haut);
   end depile;

   procedure increment (P : in PILE_entier; V : in Integer) is
   begin
      --  P.haut.Old_val := P.haut.val;
      P.haut.val := P.haut.val + V;
   end increment;
   procedure mvaleur (P : in PILE_entier; V : in Integer) is
   begin
      --    P.haut.Old_val := P.haut.val;
      P.haut.val := V;
   end mvaleur;
   function lvaleur (P : in PILE_entier) return Integer is
   begin
      return p.haut.val;
   end lvaleur;
   --     FUNCTION lold_valeur(P:in Pile_entier)return integer is
   --        begin
   --           return P.haut.old_val;
   --        end lold_valeur;
end Pile_Entier;
