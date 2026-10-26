with SV.Geometry; use SV.Geometry;

package body SV.Balance is

   --  Square 1 sits left of the pivot, square 2 right.  Sizes and pivot
   --  are chosen once per run.
   type Pair is array (1 .. 2) of Float;
   S, W, D : Pair := (0.0, 0.0);  --  side, weight (= area), distance from pivot
   Room    : Pair := (0.0, 0.0);  --  furthest distance on that arm
   Pivot, Half  : Float := 0.0;   --  pivot offset from centre, half beam length
   Leader       : Positive := 1;  --  the square that moves first; the other chases
   From, Target : Float := 0.0;   --  the leader slides From -> Target
   Time, Tilt   : Float := 0.0;
   Ink          : Pixel := 0;

   function Other (I : Positive) return Positive is (3 - I);

   --  Where the follower must be for equilibrium: W1 * D1 = W2 * D2
   function Balance_Spot (F : Positive) return Float is
     (W (Other (F)) * D (Other (F)) / W (F));

   --  A new disturbance: the other square leads now and slides to a spot far
   --  from where it is.  Its range is limited so the follower can still reach
   --  the balancing spot on its arm.
   procedure Disturb is
      F       : Positive;
      Hi, Mid : Float;
   begin
      Leader := Other (Leader);
      F      := Other (Leader);
      Hi     := Float'Min (Room (Leader), W (F) * Room (F) / W (Leader));
      Mid    := 0.55 * Hi;
      From   := D (Leader);
      Target := (if From > Mid then Hi * Float (10 + Random (35)) / 100.0
                 else Hi * Float (70 + Random (31)) / 100.0);
      Time   := 0.0;
   end Disturb;

   procedure Start is
      Size : constant Float := Float (Integer'Min (Params (1), Max_H));
   begin
      Width  := Integer (Size);
      Height := Width * 2 / 3;
      Ink    := SV.Ink (Params (3));
      S (1)  := Size * Float (6 + Random (10)) / 100.0;
      S (2)  := Size * Float (6 + Random (10)) / 100.0;
      W      := (S (1) * S (1), S (2) * S (2));
      Half   := Size * 0.42;
      Pivot  := Size * Float (Random (21) - 10) / 100.0;
      Room   := (Half + Pivot - S (1) / 2.0, Half - Pivot - S (2) / 2.0);
      D (2)  := 0.5 * Float'Min (Room (2), W (1) * Room (1) / W (2));
      D (1)  := 0.4 * Balance_Spot (1);   --  start out of balance: the beam tips at once
      Tilt   := 0.0;
      Leader := 2;
      Disturb;
   end Start;

   procedure Tick is
      Size   : constant Float := Float (Width);
      Speed  : constant Float := Float (Params (2));
      Apex   : constant Vec := (Size / 2.0 + Pivot, Float (Height) * 0.75);
      F      : constant Positive := Other (Leader);
      Torque : Float;
      U, N, Base : Vec;
   begin
      --  the leader eases to its target, the follower keeps chasing the
      --  balancing spot; the next disturbance starts before it gets there
      Time := Time + Speed / 200.0;
      D (Leader) := From + (Target - From) * Smooth (Time);
      D (F) := D (F) + 0.012 * Speed * (Balance_Spot (F) - D (F));
      if Time >= 1.6 then
         Disturb;
      end if;

      --  the beam turns towards the side with more torque (weight x distance)
      Torque := W (2) * D (2) - W (1) * D (1);
      Tilt := Tilt + 0.05 * (0.6 * Torque / (W (1) * D (1) + W (2) * D (2)) - Tilt);

      Clear;
      U := Dir (Tilt);                  --  along the beam
      N := (U.Y, -U.X);                 --  up from the beam
      Stroke (Apex, Apex + Vec'(0.0, Size * 0.1), 0.0, Size * 0.12, Ink);   --  pivot
      Base := Apex + (Size * 0.006) * N;
      Stroke (Base - (Half + Pivot) * U, Base + (Half - Pivot) * U,
              Size * 0.012, Size * 0.012, Ink);                                --  beam
      Base := Apex + (Size * 0.012) * N;
      Stroke (Base - D (1) * U, Base - D (1) * U + S (1) * N, S (1), S (1), Ink);  --  squares
      Stroke (Base + D (2) * U, Base + D (2) * U + S (2) * N, S (2), S (2), Ink);
   end Tick;

end SV.Balance;
