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

   procedure Line (A, B : Vec; C : Pixel; Gap : Positive := 1) is
      L2 : constant Float := Len2 (B - A) + 1.0E-6;
      N  : constant Natural := Natural (L2 * Inv_Sqrt (L2));   --  length in pixels
      P  : Vec;
   begin
      for I in 0 .. N loop
         if I mod Gap = 0 then
            P := A + (Float (I) / Float (N + 1)) * (B - A);
            if P.X >= 0.0 and P.Y >= 0.0 and P.X < Float (Width) and P.Y < Float (Height) then
               Put (Natural (Floor (P.X)), Natural (Floor (P.Y)), C);
            end if;
         end if;
      end loop;
   end Line;

   procedure Circle (Centre : Vec; R : Float; C : Pixel; Gap : Positive := 1) is
      N    : constant Positive := Natural (2.0 * Pi * abs R) + 8;   --  about one step per pixel
      Step : constant Vec := Dir (2.0 * Pi / Float (N));
      U    : Vec := (R, 0.0);
   begin
      for I in 1 .. N loop
         if I mod Gap = 0 then
            Line (Centre + U, Centre + U, C);
         end if;
         U := (U.X * Step.X - U.Y * Step.Y, U.X * Step.Y + U.Y * Step.X);   --  turn a little
      end loop;
   end Circle;

   function Dim (C : Pixel; B : Float) return Pixel is
      F : constant Unsigned_32 := Unsigned_32 (Float'Max (0.0, Float'Min (1.0, B)) * 255.0);
   begin
      return 16#FF00_0000# or Shift_Right ((C and 16#FF#) * F, 8)
        or (Shift_Right ((C and 16#FF00#) * F, 8) and 16#FF00#)
        or (Shift_Right ((C and 16#FF_0000#) * F, 8) and 16#FF_0000#);
   end Dim;

   procedure Fill (Corners : Vec_Array; C : Pixel) is
      Cross : array (1 .. 4096) of Float := (others => 0.0);   --  where edges cross this row
      N     : Natural;
      Y0    : Float;
      A, B  : Vec;
      T     : Float;
      J     : Natural;
   begin
      for Y in 0 .. Height - 1 loop
         Y0 := Float (Y) + 0.5;
         N  := 0;
         for I in Corners'Range loop
            A := Corners (I);
            B := Corners (if I = Corners'Last then Corners'First else I + 1);
            if (A.Y <= Y0) /= (B.Y <= Y0) and N < Cross'Last then
               T := A.X + (Y0 - A.Y) / (B.Y - A.Y) * (B.X - A.X);
               J := N;                        --  insertion sort as we go
               while J > 0 and then Cross (J) > T loop
                  Cross (J + 1) := Cross (J);
                  J := J - 1;
               end loop;
               Cross (J + 1) := T;
               N := N + 1;
            end if;
         end loop;
         for K in 1 .. N / 2 loop             --  fill between pairs of crossings
            for X in Integer'Max (0, Integer (Cross (2 * K - 1))) ..
                     Integer'Min (Width - 1, Integer (Cross (2 * K)) - 1)
            loop
               Put (X, Y, C);
            end loop;
         end loop;
      end loop;
   end Fill;

end SV.Geometry;
