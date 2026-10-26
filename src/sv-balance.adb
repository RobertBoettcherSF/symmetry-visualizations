with SV.Geometry; use SV.Geometry;

package body SV.Balance is

   S1, S2         : Float := 0.0;   --  sides of the squares (pixels)
   W1, W2         : Float := 0.0;   --  weights = areas
   Pivot, Half    : Float := 0.0;   --  pivot offset from centre, half beam length
   D1, D2         : Float := 0.0;   --  distances of the squares from the pivot
   From1, To1     : Float := 0.0;
   From2, To2     : Float := 0.0;
   Tilt, Time     : Float := 0.0;
   Ink            : Pixel := 0;

   function Fraction return Float is (0.3 + Float (Random (65)) / 100.0);

   --  Distances for equilibrium, with D1 near Want and both on the beam
   procedure Balanced (Want : Float; A, B : out Float) is
      Max1 : constant Float := Half + Pivot - S1 / 2.0;   --  room on the left arm
      Max2 : constant Float := Half - Pivot - S2 / 2.0;   --  and on the right
   begin
      A := Want * Max1;
      B := W1 * A / W2;
      if B > Max2 then
         B := Max2;
         A := W2 * B / W1;
      end if;
   end Balanced;

   procedure New_Round is
      Size : constant Float := Float (Width);
   begin
      S1    := Size * Float (5 + Random (12)) / 100.0;
      S2    := Size * Float (5 + Random (12)) / 100.0;
      W1    := S1 * S1;
      W2    := S2 * S2;
      Half  := Size * 0.42;
      Pivot := Size * Float (Random (31) - 15) / 100.0;
      Balanced (Fraction, D1, D2);
      From1 := D1;
      From2 := D2;
      Balanced (Fraction, To1, To2);
      Time  := 0.0;
   end New_Round;

   procedure Start is
   begin
      Width  := Integer'Min (Params (1), Max_H);
      Height := Width * 2 / 3;
      Ink    := (if Params (3) = 0 then 16#FFF0_F0F0# else Hue_Color (Params (3)));
      Tilt   := 0.0;
      New_Round;
   end Start;

   procedure Tick is
      Size   : constant Float := Float (Width);
      Torque : Float;
      Apex   : constant Vec := (Size / 2.0 + Pivot, Float (Height) * 0.75);
      U, N, Base : Vec;
   begin
      --  one round: square 1 slides, square 2 follows, a pause, new round
      Time := Time + Float (Params (2)) / 200.0;
      D1 := From1 + (To1 - From1) * Smooth (Time);
      D2 := From2 + (To2 - From2) * Smooth (Time - 1.2);
      if Time > 2.8 then
         New_Round;
      end if;

      --  the beam turns towards the side with more torque (weight x distance)
      Torque := W2 * D2 - W1 * D1;
      Tilt := Tilt + 0.06 * (0.3 * Torque / (W1 * D1 + W2 * D2) - Tilt);

      Clear;
      U := Dir (Tilt);                  --  along the beam
      N := (U.Y, -U.X);                 --  up from the beam
      Stroke (Apex, Apex + Vec'(0.0, Size * 0.1), 0.0, Size * 0.12, Ink);   --  pivot
      Base := Apex + (Size * 0.006) * N;
      Stroke (Base - (Half + Pivot) * U, Base + (Half - Pivot) * U,
              Size * 0.012, Size * 0.012, Ink);                                --  beam
      Base := Apex + (Size * 0.012) * N;
      Stroke (Base - D1 * U, Base - D1 * U + S1 * N, S1, S1, Ink);              --  squares
      Stroke (Base + D2 * U, Base + D2 * U + S2 * N, S2, S2, Ink);
   end Tick;

end SV.Balance;
