
with Ada.Strings.Bounded;
use Ada.Strings.Bounded;
package My_Declarations is
  package My_String is new Generic_Bounded_Length(78);
--  use My_String;
end My_Declarations;