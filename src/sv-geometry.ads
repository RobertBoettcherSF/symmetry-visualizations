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

end SV.Geometry;
