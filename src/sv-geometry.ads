--  2-D vectors and the little maths the visualizations need, written out
--  in Ada so no C maths library is required in the browser.
package SV.Geometry is

   Pi : constant := 3.14159_26535_89793;

   type Vec is record
      X, Y : Float;
   end record;
   type Vec_Array is array (Natural range <>) of Vec;

   function "+" (A, B : Vec) return Vec is ((A.X + B.X, A.Y + B.Y));
   function "-" (A, B : Vec) return Vec is ((A.X - B.X, A.Y - B.Y));
   function "*" (S : Float; A : Vec) return Vec is ((S * A.X, S * A.Y));
   function Dot (A, B : Vec) return Float is (A.X * B.X + A.Y * B.Y);
   function Len2 (A : Vec) return Float is (Dot (A, A));

   function Floor (F : Float) return Float is
     (Float (Integer (F)) - (if Float (Integer (F)) > F then 1.0 else 0.0));
   function Frac (F : Float) return Float is (F - Floor (F));

   function Dir (T : Float) return Vec;          --  (cos T, sin T)
   function Inv_Sqrt (X : Float) return Float;   --  1 / sqrt (X), X > 0
   function Smooth (X : Float) return Float is      --  easing 0 .. 1, slow at both ends
     (if X <= 0.0 then 0.0 elsif X >= 1.0 then 1.0 else X * X * (3.0 - 2.0 * X));

   --  Fill the strip from A to B (pixel coordinates) whose width changes
   --  from WA to WB: a rectangle, a tapered branch or (WA = 0) a triangle.
   procedure Stroke (A, B : Vec; WA, WB : Float; C : Pixel);

   --  A thin line from A to B; with Gap > 1 only every Gap-th pixel (dotted)
   procedure Line (A, B : Vec; C : Pixel; Gap : Positive := 1);

   --  A circle outline; with Gap > 1 dotted
   procedure Circle (Centre : Vec; R : Float; C : Pixel; Gap : Positive := 1);

   --  Colour C at brightness B (0 .. 1)
   function Dim (C : Pixel; B : Float) return Pixel;

   --  Fill the inside of a closed polygon (even-odd rule, pixel coordinates)
   procedure Fill (Corners : Vec_Array; C : Pixel);

end SV.Geometry;
