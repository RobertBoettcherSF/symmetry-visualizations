with SV.Geometry; use SV.Geometry;

package body SV.Mandala is

   Max_Points : constant := 16;
   Dots       : constant := 8;     --  small dots inside each rosette

   Points            : Natural := 7;
   Arm, Side, Mid    : Vec_Array (0 .. Max_Points - 1);  --  arm axis, its normal, between arms
   Rosette_Dot       : Vec_Array (0 .. Dots - 1);
   Turn, Turn_Speed  : Float := 0.0;   --  whole medallion
   Spin, Spin_Speed  : Float := 0.0;   --  rosettes, opposite direction
   Flow, Flow_Speed  : Float := 0.0;   --  triangles moving outwards
   Ink               : Pixel := 16#FFFF_FFFF#;

   procedure Start is
      Size : constant Natural := Integer'Min (Params (1), Max_H);
      Sign : constant Float := (if Random (2) = 0 then 1.0 else -1.0);
   begin
      Width  := Size;
      Height := Size;
      Points := Integer'Max (3, Integer'Min (Params (2), Max_Points));
      Ink    := (if Params (3) = 0 then 16#FFFF_FFFF# else Hue_Color (Params (3)));
      for K in 0 .. Points - 1 loop
         Arm (K)  := Dir (2.0 * Pi * Float (K) / Float (Points) - Pi / 2.0);
         Side (K) := (-Arm (K).Y, Arm (K).X);
         Mid (K)  := Dir (2.0 * Pi * (Float (K) + 0.5) / Float (Points) - Pi / 2.0);
      end loop;
      Turn_Speed := Sign * Float (2 + Random (8)) / 1000.0;       --  radians per frame
      Spin_Speed := -Sign * Float (5 + Random (30)) / 1000.0;
      Flow_Speed := Float (1 + Random (6)) / 1000.0;              --  radii per frame
   end Start;

   --  Colour of point Q (unit circle, already turned with the medallion)
   function Shade (Q : Vec) return Pixel is
      R2   : constant Float := Len2 (Q);
      Tri  : constant Float := Float (Params (4)) / 100.0;   --  triangle length
      A, C, E, T, P : Float;
      D    : Vec;
   begin
      if R2 > 1.0 then return 0;                          --  transparent outside
      elsif R2 > 0.95 * 0.95 then return Ink;             --  rim
      elsif R2 < 0.15 * 0.15 then return Black;           --  central disc
      elsif R2 < 0.19 * 0.19 then return Ink;
      end if;

      for K in 0 .. Points - 1 loop                       --  the star's arms
         A := Dot (Q, Arm (K));                           --  distance along the arm
         C := abs Dot (Q, Side (K));                      --  distance from its axis
         E := 0.2 * (1.0 - A / 0.95);                     --  half width at A
         if A > 0.0 and C < E then
            if E - C < 0.015 then return Ink; end if;     --  outline
            T := Frac ((A - Flow) / Tri);                 --  0 at a triangle's base
            if C < 0.45 * Tri * (1.0 - T) then return Ink; end if;    --  centre row
            P := E - C - 0.015;                           --  distance from outline
            T := Frac ((A - Flow) / (Tri * 0.5));
            if P < 0.04 and then P < 0.04 * T then return Ink; end if; --  edge rows
            return Black;
         end if;
      end loop;

      for K in 0 .. Points - 1 loop                       --  rosettes and fans
         D := Q - 0.6 * Mid (K);
         if Len2 (D) < 0.13 * 0.13 then
            if Len2 (D) > 0.11 * 0.11 then return Ink; end if;
            if Len2 (D) < 0.03 * 0.03 then return Black; end if;
            if Len2 (D) < 0.045 * 0.045 then return Ink; end if;
            for J in Rosette_Dot'Range loop
               if Len2 (D - Rosette_Dot (J)) < 0.017 * 0.017 then return Ink; end if;
            end loop;
            return Black;
         end if;
         D := Q - 0.95 * Mid (K);
         if Len2 (D) < 0.18 * 0.18 then
            if Len2 (D) > 0.16 * 0.16 or Len2 (D) < 0.03 * 0.03 then return Ink; end if;
            A := -Dot (D, Mid (K));
            C := Dot (D, (-Mid (K).Y, Mid (K).X));
            if Frac (5.0 * C / (abs C + A) + 0.5) < 0.4 then return Ink; end if;  --  ribs
            return Black;
         end if;
      end loop;
      return Black;
   end Shade;

   procedure Tick is
      U : constant Vec := Dir (-Turn);                    --  rotate points back
      H : constant Float := Float (Width) / 2.0;
      P, Q : Vec;
   begin
      Turn := Turn + Turn_Speed;
      Spin := Spin + Spin_Speed - Turn_Speed;   --  relative to the turning medallion
      Flow := Frac (Flow + Flow_Speed);
      for J in Rosette_Dot'Range loop
         Rosette_Dot (J) := 0.078 * Dir (Spin + 2.0 * Pi * Float (J) / Float (Dots));
      end loop;
      for Y in 0 .. Height - 1 loop
         for X in 0 .. Width - 1 loop
            P := (1.0 / H) * Vec'(Float (X) + 0.5 - H, Float (Y) + 0.5 - H);
            Q := (P.X * U.X - P.Y * U.Y, P.X * U.Y + P.Y * U.X);
            Put (X, Y, Shade (Q));
         end loop;
      end loop;
   end Tick;

end SV.Mandala;
