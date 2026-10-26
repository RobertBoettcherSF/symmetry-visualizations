with SV.Geometry; use SV.Geometry;

package body SV.Evolute is

   Theta : Float := 0.0;       --  how far the spiral is drawn (radians)
   Sign  : Float := 1.0;       --  drawing out (+1) or unwinding (-1)
   Grow  : Float := 0.5;       --  random shape of the growth, new every round
   Rot   : Float := 0.0;       --  turn of the radial lines
   Ink   : Pixel := 0;

   function Last return Float is (2.0 * Pi * Float (Params (2)) / 10.0);

   --  Radius at angle T: grows from 0 at the centre to the edge at Last
   function Radius (T : Float) return Float is
      F : constant Float := T / Last;
   begin
      return 0.46 * Float (Width) * F * (Grow + (1.0 - Grow) * F);
   end Radius;

   function Point (T : Float) return Vec is
     (Vec'(Float (Width) / 2.0, Float (Height) / 2.0) + Radius (T) * Dir (T));

   procedure Start is
   begin
      Square (Params (1));
      Ink    := SV.Ink (Params (4), 16#FFFF_FFFF#);
      Grow   := 0.2 + Float (Random (60)) / 100.0;
      Theta  := 0.0;
      Sign   := 1.0;
      Rot    := Float (Random (628)) / 100.0;
   end Start;

   procedure Tick is
      Step : constant Float := 0.05;
      T    : Float := 0.0;
      A    : Float;
      Ends : Vec_Array (0 .. 8) := (others => (0.0, 0.0));
      Have : array (0 .. 8) of Boolean := (others => False);
   begin
      Theta := Theta + Sign * Float (Params (3)) * Last / 1200.0;
      if Theta >= Last then
         Theta := Last;
         Sign  := -1.0;
      elsif Theta <= 0.0 then
         Theta := 0.0;
         Sign  := 1.0;
         Grow  := 0.2 + Float (Random (60)) / 100.0;
      end if;
      Rot := Rot - 0.004 * Float (Params (3));

      Clear;
      while T < Theta loop                  --  the spiral itself
         Stroke (Point (T), Point (Float'Min (T + Step, Theta)), 2.5, 2.5, Ink);
         T := T + Step;
      end loop;

      for J in 0 .. 7 loop                  --  dotted radials to the outermost wrap
         A := Frac ((Float (J) * Pi / 4.0 + Rot) / (2.0 * Pi)) * 2.0 * Pi;
         if A <= Theta then
            A := A + 2.0 * Pi * Floor ((Theta - A) / (2.0 * Pi));
            Ends (J) := Point (A);
            Have (J) := True;
            Line (Point (0.0), Ends (J), Dim (Ink, 0.7), Gap => 4);
         end if;
      end loop;
      Ends (8) := Ends (0);
      Have (8) := Have (0);
      for J in 0 .. 7 loop                  --  dotted chords between neighbours
         if Have (J) and Have (J + 1) then
            Line (Ends (J), Ends (J + 1), Dim (Ink, 0.7), Gap => 4);
         end if;
      end loop;
   end Tick;

end SV.Evolute;
