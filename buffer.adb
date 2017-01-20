package body Buffer is
   protected body Clavier is
      entry Put (X : in Character) when Count < N is
      begin
         A (In_Ptr) := X;
         In_Ptr     := In_Ptr + 1;
         Count      := Count + 1;
      end Put;
      entry Get (X : out Character) when Count > 0 is
      begin
         X       := A (Out_Ptr);
         Out_Ptr := Out_Ptr + 1;
         Count   := Count - 1;
      end Get;
   end Clavier;
end Buffer;
