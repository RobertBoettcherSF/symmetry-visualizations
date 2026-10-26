with SV.Geometry; use SV.Geometry;

package body SV.Fractals is

   Kind   : Positive := 1;
   Level  : Float := 0.0;      --  e.g. 2.4 = level 2 done, level 3 forty percent in
   Sign   : Float := 1.0;      --  building up (+1) or folding back (-1)
   Depth  : Natural := 5;
   Ink    : Pixel := 0;
   Sqrt3  : constant := 1.73205_08075_68877;

   --  Sierpinski triangle in "triangle coordinates": inside means U, V >= 0
   --  and U + V <= 1.  Each level cuts out the middle quarter (scaled by
   --  Grow while it appears) and zooms into the corner the point is in.
   function In_Triangle (U0, V0 : Float; Full : Natural; Grow : Float) return Boolean is
      U : Float := U0;
      V : Float := V0;
      HU, HV, S : Float;
   begin
      if U < 0.0 or V < 0.0 or U + V > 1.0 then
         return False;
      end if;
      for L in 0 .. Full loop
         S := (if L < Full then 1.0 else Grow);
         if S > 0.02 then
            HU := 1.0 / 3.0 + (U - 1.0 / 3.0) / S;
            HV := 1.0 / 3.0 + (V - 1.0 / 3.0) / S;
            if HU < 0.5 and HV < 0.5 and HU + HV > 0.5 then
               return False;
            end if;
         end if;
         exit when L = Full;
         if U >= 0.5 then
            U := 2.0 * U - 1.0;  V := 2.0 * V;
         elsif V >= 0.5 then
            U := 2.0 * U;        V := 2.0 * V - 1.0;
         else
            U := 2.0 * U;        V := 2.0 * V;
         end if;
      end loop;
      return True;
   end In_Triangle;

   --  Flat-topped hexagon with corner radius R around (0, 0)
   function In_Hex (P : Vec; R : Float) return Boolean is
     (abs P.Y <= 0.5 * Sqrt3 * R and Sqrt3 * abs P.X + abs P.Y <= Sqrt3 * R);

   --  Sierpinski hexagon: a ring of six hexagons a third the size; while a
   --  level appears the six start large (filling the parent) and shrink.
   Six : constant Vec_Array (0 .. 5) :=
     ((1.0, 0.0), (0.5, Sqrt3 / 2.0), (-0.5, Sqrt3 / 2.0),
      (-1.0, 0.0), (-0.5, -Sqrt3 / 2.0), (0.5, -Sqrt3 / 2.0));

   function In_Flake (P0 : Vec; Full : Natural; Grow : Float) return Boolean is
      P    : Vec := P0;
      Best : Vec;
      R    : Float;
   begin
      if not In_Hex (P, 1.0) then
         return False;
      end if;
      for L in 0 .. Full loop
         R := (if L < Full then 1.0 / 3.0 else 1.0 / 3.0 + (1.0 - Grow) * 0.5);
         Best := (0.0, 0.0);
         for J of Six loop                   --  the nearest of the six centres
            if Dot (P, J) > Dot (P, Best) then
               Best := J;
            end if;
         end loop;
         if not In_Hex (P - (2.0 / 3.0) * Best, R) then
            return False;
         end if;
         exit when L = Full;
         P := 3.0 * (P - (2.0 / 3.0) * Best);
      end loop;
      return True;
   end In_Flake;

   --  Koch snowflake as a polygon: every edge gets a bump of height Grow
   --  on its last level.
   Corners : Vec_Array (1 .. 3 * 4 ** 6);
   Count   : Natural := 0;

   procedure Koch (A, B : Vec; L : Natural; Full : Natural; Grow : Float) is
      D    : constant Vec := (1.0 / 3.0) * (B - A);
      Bump : constant Float := (if L < Full then 1.0 else Grow);
      Peak : constant Vec := A + 1.5 * D + (Bump * Sqrt3 / 2.0) * Vec'(D.Y, -D.X);
   begin
      if L > Full or Bump = 0.0 then
         Count := Count + 1;
         Corners (Count) := A;
      else
         Koch (A, A + D, L + 1, Full, Grow);
         Koch (A + D, Peak, L + 1, Full, Grow);
         Koch (Peak, A + 2.0 * D, L + 1, Full, Grow);
         Koch (A + 2.0 * D, B, L + 1, Full, Grow);
      end if;
   end Koch;

   procedure Start (Variant : Positive) is
   begin
      Kind   := Variant;
      Square (Params (1));
      Depth  := Integer'Max (1, Integer'Min (Params (2), (if Kind = 1 then 6 else 5)));
      Ink    := SV.Ink (Params (4));
      Level  := 0.0;
      Sign   := 1.0;
   end Start;

   procedure Tick is
      Size   : constant Float := Float (Width);
      Full   : Natural;
      Grow   : Float;
      P      : Vec;
      H      : constant Float := 0.45 * Size * Sqrt3;   --  height of the big triangle
      Inside : Boolean;
   begin
      Level := Level + Sign * Float (Params (3)) / 300.0;
      if Level >= Float (Depth) then
         Sign := -1.0;
      elsif Level <= 0.0 then
         Sign := 1.0;
      end if;
      Level := Float'Max (0.0, Float'Min (Float (Depth) - 0.001, Level));
      Full  := Natural (Floor (Level));
      Grow  := Smooth (Level - Float (Full));

      Clear;
      if Kind = 2 then
         Count := 0;
         declare   --  the triangle points down, like the book's first step
            C : constant Vec := (Size / 2.0, Size / 2.0);
            A : constant Vec := C + (0.3 * Size) * Dir (-5.0 * Pi / 6.0);
            B : constant Vec := C + (0.3 * Size) * Dir (-Pi / 6.0);
            E : constant Vec := C + (0.3 * Size) * Dir (Pi / 2.0);
         begin
            Koch (A, B, 0, Full, Grow);
            Koch (B, E, 0, Full, Grow);
            Koch (E, A, 0, Full, Grow);
         end;
         Fill (Corners (1 .. Count), Ink);
         return;
      end if;

      for Y in 0 .. Height - 1 loop
         for X in 0 .. Width - 1 loop
            P := (Float (X) + 0.5, Float (Y) + 0.5);
            if Kind = 1 then   --  corners (0.05 S, bottom), (0.95 S, bottom), top
               declare
                  V : constant Float := (0.5 * Size + H / 2.0 - P.Y) / H;
               begin
                  Inside := In_Triangle ((P.X - 0.05 * Size - V * 0.45 * Size) / (0.9 * Size),
                                         V, Full, Grow);
               end;
            else
               Inside := In_Flake ((2.2 / Size) * (P - Vec'(Size / 2.0, Size / 2.0)), Full, Grow);
            end if;
            if Inside then
               Put (X, Y, Ink);
            end if;
         end loop;
      end loop;
   end Tick;

end SV.Fractals;
