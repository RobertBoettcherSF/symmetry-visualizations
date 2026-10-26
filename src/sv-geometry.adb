with Ada.Unchecked_Conversion;

package body SV.Geometry is

   --  Taylor series after reducing T to -Pi .. Pi
   function Dir (T : Float) return Vec is
      A    : constant Float := T - 2.0 * Pi * Floor ((T + Pi) / (2.0 * Pi));
      Term : Float := 1.0;
      C, S : Float := 0.0;
   begin
      for N in 0 .. 17 loop
         if N mod 2 = 0 then C := C + Term; else S := S + Term; end if;
         Term := (if N mod 2 = 1 then -Term else Term) * A / Float (N + 1);
      end loop;
      return (C, S);
   end Dir;

   --  The famous bit trick: a first guess from the float's bits, then Newton
   function Inv_Sqrt (X : Float) return Float is
      function To_Bits is new Ada.Unchecked_Conversion (Float, Unsigned_32);
      function To_Float is new Ada.Unchecked_Conversion (Unsigned_32, Float);
      Y : Float := To_Float (16#5F37_59DF# - Shift_Right (To_Bits (X), 1));
   begin
      for I in 1 .. 2 loop
         Y := Y * (1.5 - 0.5 * X * Y * Y);
      end loop;
      return Y;
   end Inv_Sqrt;

end SV.Geometry;
