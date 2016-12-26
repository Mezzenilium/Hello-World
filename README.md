# Hello-World
Some Flexible Menu Framework on Console for Ada 2012

I want to realise in Ada 2012 a library working under Linux and Windows which permits to drive a Console application through a menu integrated in its structure of control. 

On the Console the application would have this aspect :

                                           HELLO WORLD

    =>THANK YOU at GitHub
      MENU SYSTEM CONCEPTION
      MENU SYSTEM CODING
      MENU SYSTEM TESTING
      MENU SYSTEM IMPROVEMENTS
  
The navigation in the menu : selection of items, access to sub-menus, access to upper-menu etc... would be done through the use of the arrows of the keyboard.


The Ada program producing this Menu could be as follows:

    with Menu; use Menu;

    procedure Hello_World is
       C0, C1 : constant Integer_Pointeur := new Integer'(0); -- Menu Status Parameter
       Men    : Menu_Ptr                  := Init ("A MENU SYSTEM DEMONSTRATION", Full_Console);

    begin
      while Men.M0 ("HELLO WORLD", C0) loop
        if Men.T ("THANK YOU at GitHub") then
           null;
        end if;

        while Men.M ("MENU SYSTEM CONCEPTION", C1) loop
          if Men.T ("PRELIMIBARY DESIGN") then
             null;
          end if;

          if Men.T ("CRITICAL DESIGN") then
              null;
          end if;
        end loop;

        while Men.M ("MENU SYSTEM CODING", C1) loop
         if Men.T ("LINUX") then
            null;
         end if;

         if Men.T ("WINDOWS") then
            null;
         end if;
        end loop;

        if Men.T ("MENU SYSTEM TESTING") then
          null;
          while Men.M1 ("MENU SYSTEM TESTING", C1) loop
             null;
          end loop;
         end if;
       
        if Men.T ("MENU SYSTEM IMPROVEMENTS") then
           null;
        end if;
      end loop;
    end Hello_World;

