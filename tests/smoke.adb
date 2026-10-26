--  Native smoke check: run both visualizations a little and print
--  how many cells are lit.  Build: gprbuild -P tests/smoke.gpr
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces;  use type Interfaces.Unsigned_32;
with SV;          use SV;
with SV.API;

procedure Smoke is
   function Lit return Natural is
      N : Natural := 0;
   begin
      for I in 0 .. Width * Height - 1 loop
         if Frame (I) /= Black then
            N := N + 1;
         end if;
      end loop;
      return N;
   end Lit;
begin
   Params := (30, 101, 50, 0, 1, 120, 0, 0);
   SV.API.Start (0, 1);
   for I in 1 .. 60 loop
      SV.API.Tick;
   end loop;
   Put_Line ("Rule 30 lit cells:" & Lit'Image);

   Params := (64, 48, 30, 1, 1, 200, 0, 0);
   SV.API.Start (1, 1);
   for I in 1 .. 50 loop
      SV.API.Tick;
   end loop;
   Put_Line ("Life lit cells:   " & Lit'Image);

   Params := (200, 7, 0, 6, 0, 0, 0, 0);
   SV.API.Start (2, 1);
   SV.API.Tick;
   Put_Line ("Mandala lit cells:" & Lit'Image);

   Params := (300, 7, 0, 0, 0, 0, 0, 0);
   for Viz in 3 .. 9 loop
      SV.API.Start (Viz, 7);
      for I in 1 .. 300 loop
         SV.API.Tick;
      end loop;
      Put_Line ("Viz" & Integer'Image (Viz) & " lit cells:" & Lit'Image);
   end loop;
end Smoke;
