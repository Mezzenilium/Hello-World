A menu is controlled by keyboard actions from the user. We can have as many menus as tasks simultaneously running in the application. One menu at the time is controlled by the operator through the keyboard. We need so to associated a virtual keyboard at each menu; This would allow of course the user to control the active menu but also to a task to control the menu of an other task through its virtual keyboard.  Things start to be clearer !! So first : how to make a task which polls the keyboard on a transparent way for the user ?

The code could be this one :

     ----------------------
     -- Keyboard_Handler --
     ----------------------

    task body Keyboard_Handler is
      K0        : Character;
      Available : Boolean   := False;
      --  Clavier_Courant : Déclaré au niveau supérieur : Current Keyboard
    begin
      loop
         Get_Immediate (K0, Available);
         if Available and then Character'Pos (K0) /= 0 then
            Clavier_Courant.Put (K0);
         end if;
         delay 0.06;
      end loop;
    end Keyboard_Handler;

Un clavier est un buffer de caractères saisis au clavier. On va le définir comme un objet protégé dans un package appelé Buffer. Il doit être protégé car ce n'est pas seulemnet l' utilisateur qui peut l'alimenter mais aussi d'autres taches.

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

Le corps du package est alors :

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
