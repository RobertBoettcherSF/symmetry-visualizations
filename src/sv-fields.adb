with SV.Geometry; use SV.Geometry;

package body SV.Fields is

   --  The charges.  Positive charges are sources, lines end at negative ones.
   Count : Natural := 0;
   Pos   : Vec_Array (1 .. 4);
   Q     : array (1 .. 4) of Float := (others => 0.0);

   Kind           : Positive := 1;
   Lines          : Positive := 16;
   Ink            : Pixel := 0;
   Scale          : Float := 1.0;    --  pixels per unit; the picture spans -1.15 .. 1.15
   Rx, Ry         : Float := 2.0;    --  lines and rings stay inside this ellipse
   T              : Float := 0.0;    --  frames since start
   Speed1, Speed2 : Float := 0.0;    --  random each run
   Max_Steps      : Natural := 0;    --  enough to cross the picture

   function Strength return Float is (0.75 + Float (Random (50)) / 100.0);

   function Dim (C : Pixel; B : Float) return Pixel is
      F : constant Unsigned_32 := Unsigned_32 (Float'Max (0.0, Float'Min (1.0, B)) * 255.0);
   begin
      return 16#FF00_0000# or Shift_Right ((C and 16#FF#) * F, 8)
        or (Shift_Right ((C and 16#FF00#) * F, 8) and 16#FF00#)
        or (Shift_Right ((C and 16#FF_0000#) * F, 8) and 16#FF_0000#);
   end Dim;

   function Inside (P : Vec) return Boolean is
     (abs P.X < 1.15 and abs P.Y < 1.15 and P.X * P.X / (Rx * Rx) + P.Y * P.Y / (Ry * Ry) < 1.0);

   procedure Plot (P : Vec; C : Pixel) is
      X : constant Integer := Integer (P.X * Scale) + Width / 2;
      Y : constant Integer := Integer (P.Y * Scale) + Height / 2;
   begin
      if X in 0 .. Width - 1 and Y in 0 .. Height - 1 then
         Put (X, Y, C);
      end if;
   end Plot;

   --  Coulomb: E = sum of q * d / |d|**3
   function Field (P : Vec) return Vec is
      E : Vec := (0.0, 0.0);
      D : Vec;
      R : Float;   --  1 / |d|
   begin
      for K in 1 .. Count loop
         D := P - Pos (K);
         R := Inv_Sqrt (Len2 (D) + 1.0E-6);
         E := E + (Q (K) * R * R * R) * D;
      end loop;
      return E;
   end Field;

   function Potential (P : Vec) return Float is
      V : Float := 0.0;
   begin
      for K in 1 .. Count loop
         V := V + Q (K) * Inv_Sqrt (Len2 (P - Pos (K)) + 1.0E-4);
      end loop;
      return V;
   end Potential;

   function At_Sink (P : Vec) return Boolean is
   begin
      for K in 1 .. Count loop
         if Q (K) < 0.0 and Len2 (P - Pos (K)) < 0.0004 then
            return True;
         end if;
      end loop;
      return False;
   end At_Sink;

   --  Follow the field from From for Steps pixels.  With Dots >= 0 a bright
   --  dot is drawn every 20 steps, shifted by Dots (so they move along).
   procedure Trace (From : Vec; Steps : Natural; Bright : Float; Dots : Integer := -1) is
      P : Vec := From;
      E : Vec;
   begin
      for S in 1 .. Steps loop
         E := Field (P);
         P := P + (0.8 / Scale * Inv_Sqrt (Len2 (E) + 1.0E-12)) * E;
         exit when not Inside (P) or At_Sink (P);
         if Dots >= 0 and then (S - Dots) mod 20 < 3 then
            for O in -1 .. 1 loop
               Plot (P + (Float (O) / Scale) * Vec'(1.0, 0.0), Ink);
               Plot (P + (Float (O) / Scale) * Vec'(0.0, 1.0), Ink);
            end loop;
         else
            Plot (P, Dim (Ink, Bright));
         end if;
      end loop;
   end Trace;

   --  Lines leaving every positive charge, evenly spaced, turned by Offset
   procedure All_Lines (Offset : Float; Steps : Natural; Bright : Float; Dots : Integer := -1) is
   begin
      for K in 1 .. Count loop
         if Q (K) > 0.0 then
            for I in 0 .. Lines - 1 loop
               Trace (Pos (K) + 0.03 * Dir (Offset + 2.0 * Pi * Float (I) / Float (Lines)),
                      Steps, Bright, Dots);
            end loop;
         end if;
      end loop;
   end All_Lines;

   --  "Diamond angle" 0 .. 4 around the centre: like an angle, but no arctan
   function Turn_Of (P : Vec) return Float is
      S : constant Float := abs P.X + abs P.Y + 1.0E-9;
   begin
      if P.Y >= 0.0 then
         return (if P.X >= 0.0 then P.Y / S else 1.0 - P.X / S);
      else
         return (if P.X < 0.0 then 2.0 - P.Y / S else 3.0 + P.X / S);
      end if;
   end Turn_Of;

   --  Dashed lines of equal potential; Phase moves them, Dash slides the dashes
   procedure Equipotentials (Density, Phase, Dash : Float) is
      P    : Vec;
      V, D : Float;
   begin
      for Y in 0 .. Height - 1 loop
         for X in 0 .. Width - 1 loop
            P := (1.0 / Scale) * Vec'(Float (X - Width / 2), Float (Y - Height / 2));
            if Inside (P) then
               V := Potential (P);
               D := Frac (V * Density + Phase);   --  0 or 1 = on a ring
               D := Float'Min (D, 1.0 - D) / Density;
               --  D / |E| is the distance to the ring; keep rings 1 pixel thin
               if D * D * Scale * Scale < 0.5 * Len2 (Field (P))
                 and then Frac (Turn_Of (P) * 16.0 + Dash) < 0.6
               then
                  Put (X, Y, Dim (Ink, 0.6));
               end if;
            end if;
         end loop;
      end loop;
   end Equipotentials;

   procedure Start (Variant : Positive) is
      Sign : constant Float := (if Random (2) = 0 then 1.0 else -1.0);
   begin
      Kind   := Variant;
      Square (Params (1));
      Scale  := Float (Width) / 2.3;
      Lines  := Integer'Max (2, Params (2));
      Ink    := SV.Ink (Params (3), 16#FFC8_E6F0#);
      Max_Steps := 4 * Width;
      T      := 0.0;
      Rx     := 1.05;
      Ry     := 1.05;
      Speed1 := Sign * Float (2 + Random (6)) / 1000.0;
      Speed2 := -Sign * Float (2 + Random (6)) / 1000.0;   --  the opposite way
      case Kind is
         when 1 | 4 =>                                       --  one dipole
            Count := 2;
            Pos (1) := (0.0, -0.3);   Q (1) := Strength;
            Pos (2) := (0.0, 0.3);    Q (2) := -Strength;
            if Kind = 4 then
               Rx := 0.8;
               Ry := 1.05;
            end if;
         when 2 =>                                           --  square, alternating signs
            Count := 4;
            for K in 1 .. 4 loop
               Q (K) := (if K mod 2 = 1 then Strength else -Strength);
            end loop;
         when 3 =>                                           --  two dipoles side by side
            Count := 4;
            Pos := ((-0.4, 0.4), (0.4, 0.4), (-0.4, -0.4), (0.4, -0.4));
            Q   := (Strength, Strength, -Strength, -Strength);
         when others =>                                      --  three equal charges
            Count := 3;
            for K in 1 .. 3 loop
               Pos (K) := 0.33 * Dir (2.0 * Pi * Float (K) / 3.0 - Pi / 2.0);
               Q (K)   := 1.0;
            end loop;
      end case;
   end Start;

   procedure Tick is
      Grown, Delay_Frames, Period, Fade : Float;
   begin
      Clear;
      T := T + 1.0;
      case Kind is
         when 1 =>     --  lines grow outwards, rings pulse the other way
            Equipotentials (3.0, T * abs Speed2 * 3.0, 0.0);
            Period := Float (Max_Steps) / 3.0 + 120.0;       --  grow 3 pixels a frame, then hold
            Grown := 3.0 * Frac (T / Period) * Period;
            All_Lines (0.0, Natural (Float'Min (Grown, Float (Max_Steps))), 1.0);
         when 2 =>     --  plus charges orbit one way, minus charges the other
            for K in 1 .. 4 loop
               Pos (K) := 0.42 * Dir (T * (if K mod 2 = 1 then Speed1 else Speed2)
                                      + Pi / 2.0 * Float (K) + Pi / 4.0);
            end loop;
            All_Lines (0.0, Max_Steps, 1.0);
         when 3 =>     --  dots flow from source to sink
            All_Lines (0.0, Max_Steps, 0.35, Natural (T * abs Speed1 * 400.0) mod 20);
         when 4 =>     --  meridians turn one way, the dashed rings the other
            Equipotentials (8.0, 0.0, T * Speed2 * 10.0);
            All_Lines (T * Speed1, Max_Steps, 1.0);
         when others => --  lines appear one by one, then everything fades
            Delay_Frames := 6.0;
            Period := Float (3 * Lines) * Delay_Frames + 160.0;
            Fade := Frac (T / Period) * Period;
            for J in 0 .. 3 * Lines - 1 loop
               Grown := (Fade - Float (J) * Delay_Frames) * (6.0 + 1000.0 * abs Speed1);
               if Grown > 0.0 then
                  Trace (Pos (J mod 3 + 1)
                           + 0.03 * Dir (2.0 * Pi * Float (J / 3) / Float (Lines)),
                         Natural (Float'Min (Grown, Float (Max_Steps))),
                         (Period - Fade) / 100.0);
               end if;
            end loop;
      end case;
   end Tick;

end SV.Fields;
