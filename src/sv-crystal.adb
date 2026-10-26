with SV.Geometry; use SV.Geometry;

package body SV.Crystal is

   Breath, Breath_Speed : Float := 0.0;    --  big circles
   Net, Net_Speed       : Float := 0.0;    --  node network
   Pulse, Pulse_Speed   : Float := 0.0;    --  pulses on the centre loops
   Ink                  : Pixel := 0;

   function Speed (Low : Float) return Float is (Low * (1.0 + Float (Random (100)) / 100.0));

   procedure Start is
   begin
      Square (Params (1));
      Ink    := SV.Ink (Params (3));
      Breath := 0.0;  Breath_Speed := Speed (0.02);
      Net    := 0.0;  Net_Speed    := Speed (0.002) * (if Random (2) = 0 then 1.0 else -1.0);
      Pulse  := 0.0;  Pulse_Speed  := Speed (0.015);
   end Start;

   procedure Tick is
      S     : constant Float := Float (Width);
      C     : constant Vec := (S / 2.0, S / 2.0);
      Rings : constant Positive := Integer'Max (1, Integer'Min (Params (2), 8));
      Faint : constant Pixel := Dim (Ink, 0.6);

      function Node (Ring, K : Natural) return Vec is   --  K-th node on a ring
         N : constant Positive := 4 * (Ring + 2);
         T : constant Float := (if Ring mod 2 = 0 then Net else -Net);   --  rings turn in turn
      begin
         return C + (S * (0.1 + 0.3 * Float (Ring) / Float (Rings))) *
           Dir (2.0 * Pi * Float (K) / Float (N) + T);
      end Node;

      A, B, U : Vec;
      Loop_R  : Float;
   begin
      Breath := Breath + Breath_Speed;
      Net    := Net + Net_Speed;
      Pulse  := Frac (Pulse + Pulse_Speed);
      Clear;

      for K in 0 .. 3 loop                  --  four big circles, breathing
         U := Dir (Pi / 2.0 * Float (K));
         Circle (C + (S * (0.19 + 0.02 * Dir (Breath).X)) * U,
                 S * (0.26 + 0.02 * Dir (Breath).Y), Ink);
      end loop;

      for K in 0 .. 3 loop                  --  loops through the centre, X shaped
         U := Dir (Pi / 4.0 + Pi / 2.0 * Float (K));
         for L in 1 .. 6 loop
            Loop_R := S * 0.03 * Float (L);
            Circle (C + Loop_R * U, Loop_R, Faint);
            A := C + Loop_R * U + Loop_R * Dir (Pi / 4.0 + Pi / 2.0 * Float (K) + Pi
                                            + 2.0 * Pi * Frac (Pulse + 0.13 * Float (L)));
            Stroke (A, A, 5.0, 5.0, Ink);   --  a pulse running round the loop
         end loop;
      end loop;

      for Ring in 0 .. Rings loop           --  the node network
         for K in 0 .. 4 * (Ring + 2) - 1 loop
            A := Node (Ring, K);
            Line (A, Node (Ring, K + 1), Faint);
            if Ring < Rings then            --  link to the nearest node one ring out
               B := Node (Ring + 1, 0);
               for J in 1 .. 4 * (Ring + 3) - 1 loop
                  if Len2 (Node (Ring + 1, J) - A) < Len2 (B - A) then
                     B := Node (Ring + 1, J);
                  end if;
               end loop;
               Line (A, B, Faint);
            end if;
         end loop;
         for K in 0 .. 4 * (Ring + 2) - 1 loop
            Circle (Node (Ring, K), S * 0.008 + 1.5, Ink);
         end loop;
      end loop;
   end Tick;

end SV.Crystal;
