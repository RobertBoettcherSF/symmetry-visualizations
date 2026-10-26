--  Runs Balance with many seeds, sizes and speeds and checks that the
--  picture changes in every half second (30 frames) and never jumps.
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces;  use Interfaces;
with SV;          use SV;
with SV.API;

procedure Balance_Stress is
   Before   : Pixel_Array;
   Changed  : Natural;
   Biggest  : Natural := 0;
   Smallest : Natural := Natural'Last;   --  fewest changed pixels in a window
   Window   : Natural;
   Failures : Natural := 0;
begin
   for Seed in Unsigned_32 range 1 .. 60 loop
      for Speed in 1 .. 6 loop
         Params := (120 + Integer (Seed mod 3) * 40, Speed, 0, 0, 0, 0, 0, 0);
         SV.API.Start (9, Seed);
         Window := 0;
         for Tick in 1 .. 1200 loop     --  20 seconds
            Before (0 .. Width * Height - 1) := Frame (0 .. Width * Height - 1);
            SV.API.Tick;
            Changed := 0;
            for I in 0 .. Width * Height - 1 loop
               if Frame (I) /= Before (I) then
                  Changed := Changed + 1;
               end if;
            end loop;
            Biggest := Natural'Max (Biggest, Changed * 1000 / (Width * Height));
            Window := Window + Changed;
            if Tick mod 30 = 0 then
               Smallest := Natural'Min (Smallest, Window);
               if Window = 0 then
                  Failures := Failures + 1;
               end if;
               Window := 0;
            end if;
         end loop;
      end loop;
   end loop;
   Put_Line ("runs: 360, still half-seconds:" & Failures'Image
             & ", fewest changed pixels in a half second:" & Smallest'Image
             & ", biggest change in one frame (per mille of picture):" & Biggest'Image);
end Balance_Stress;
