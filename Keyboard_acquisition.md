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
