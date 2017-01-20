with Unchecked_Deallocation;
package Buffer is
   N : constant := 128;
   type Index is mod N;
   type Char_Array is array (Index) of Character;
   protected type Clavier is
      entry Put (X : in Character);
      entry Get (X : out Character);
   private
      A               : Char_Array;
      In_Ptr, Out_Ptr : Index                := 0;
      Count           : Integer range 0 .. N := 0;
   end Clavier;
   type Clavier_Ptr is access all Clavier;
   procedure Free is new Unchecked_Deallocation (Clavier, Clavier_Ptr);
end Buffer;
