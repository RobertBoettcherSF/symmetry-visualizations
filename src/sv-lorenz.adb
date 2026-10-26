with SV.Geometry; use SV.Geometry;

package body SV.Lorenz is

   type Point is record
      X, Y, Z : Float;
   end record;

   function "+" (A, B : Point) return Point is ((A.X + B.X, A.Y + B.Y, A.Z + B.Z));
   function "*" (S : Float; A : Point) return Point is ((S * A.X, S * A.Y, S * A.Z));

   Max_Trail : constant := 8000;
   Trail     : array (0 .. Max_Trail - 1) of Point;
   Head      : Natural := 0;          --  newest entry of the ring buffer
   Filled    : Natural := 0;
   Length    : Positive := 4000;
   P         : Point := (1.0, 1.0, 1.0);
   Rho       : Float := 28.0;
   Angle     : Float := 0.0;          --  view angle and its random speed
   Turn      : Float := 0.0;
   Ink       : Pixel := 0;
   DT        : constant := 0.006;

   function Slope (A : Point) return Point is
     ((10.0 * (A.Y - A.X), A.X * (Rho - A.Z) - A.Y, A.X * A.Y - 8.0 / 3.0 * A.Z));

   procedure Step is                  --  classic Runge-Kutta, 4th order
      K1 : constant Point := Slope (P);
      K2 : constant Point := Slope (P + (DT / 2.0) * K1);
      K3 : constant Point := Slope (P + (DT / 2.0) * K2);
      K4 : constant Point := Slope (P + DT * K3);
   begin
      P := P + (DT / 6.0) * (K1 + 2.0 * K2 + 2.0 * K3 + K4);
   end Step;

   procedure Start is
   begin
      Square (Params (1));
      Length := Integer'Max (100, Integer'Min (Params (3), Max_Trail));
      Ink    := SV.Ink (Params (4), 16#FFFF_FFFF#);
      Rho    := Float (Params (5));
      P      := (Float (Random (200)) / 10.0 - 10.0, Float (Random (200)) / 10.0 - 10.0,
                 10.0 + Float (Random (300)) / 10.0);
      Angle  := Float (Random (628)) / 100.0;
      Turn   := (if Random (2) = 0 then 1.0 else -1.0) * Float (1 + Random (4)) / 1000.0;
      Head   := 0;
      Filled := 0;
   end Start;

   procedure Tick is
      Scale : constant Float := Float (Width) / (1.6 * Rho + 16.0);
      U     : Vec;
      Q     : Point;
      S     : Vec := (0.0, 0.0);
   begin
      for I in 1 .. Params (2) loop
         Step;
         Head := (Head + 1) mod Length;
         Trail (Head) := P;
         Filled := Integer'Min (Filled + 1, Length);
      end loop;
      Angle := Angle + Turn;
      U := Dir (Angle);
      Clear;
      for Age in reverse 0 .. Filled - 1 loop    --  oldest first, so new dots stay on top
         Q := Trail ((Head - Age + Length) mod Length);
         S := (Float (Width) / 2.0 + Scale * (Q.X * U.X + Q.Y * U.Y),
               Float (Height) / 2.0 - Scale * (Q.Z - Rho + 3.0));
         Line (S, S, Dim (Ink, 1.0 - Float (Age) / Float (Filled)));
      end loop;
      Stroke (S - Vec'(0.0, 3.0), S + Vec'(0.0, 3.0), 6.0, 6.0, Ink);   --  glowing head
   end Tick;

end SV.Lorenz;
