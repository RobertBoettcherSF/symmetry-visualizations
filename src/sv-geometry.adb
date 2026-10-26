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

   procedure Stroke (A, B : Vec; WA, WB : Float; C : Pixel) is
      AB : constant Vec := B - A;
      L2 : constant Float := Len2 (AB) + 1.0E-6;
      R  : constant Float := Float'Max (WA, WB) / 2.0 + 1.0;   --  bounding box margin
      P  : Vec;
      T, H : Float;
   begin
      for Y in Integer'Max (0, Integer (Float'Min (A.Y, B.Y) - R)) ..
               Integer'Min (Height - 1, Integer (Float'Max (A.Y, B.Y) + R))
      loop
         for X in Integer'Max (0, Integer (Float'Min (A.X, B.X) - R)) ..
                  Integer'Min (Width - 1, Integer (Float'Max (A.X, B.X) + R))
         loop
            P := Vec'(Float (X) + 0.5, Float (Y) + 0.5) - A;
            T := Dot (P, AB) / L2;                 --  0 at A, 1 at B
            H := (WA + T * (WB - WA)) / 2.0;       --  half width there
            if T in 0.0 .. 1.0 and then Len2 (P - T * AB) <= H * H then
               Put (X, Y, C);
            end if;
         end loop;
      end loop;
   end Stroke;

end SV.Geometry;
