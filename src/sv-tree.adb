with SV.Geometry; use SV.Geometry;

package body SV.Tree is

   Max_Depth : constant := 10;
   Spread    : array (1 .. 2 ** (Max_Depth + 2)) of Float;  --  turn of each branch
   Depth     : Natural := 0;
   Ratio     : Float := 0.7;     --  child length / parent length
   Trunk     : Float := 0.0;     --  length of the first segment
   Speed     : Float := 0.0;
   Phase     : Float := 0.0;     --  0 .. 1: grow, hold, fold, hold
   Ink       : Pixel := 0;

   procedure Randomize is
      Power : Float := 1.0;
   begin
      Depth := Integer'Max (2, Integer'Min (Params (2), Max_Depth) - Random (3));
      Ratio := 0.66 + Float (Random (12)) / 100.0;
      for I in 0 .. Depth loop
         Power := Power * Ratio;
      end loop;
      Trunk := 0.9 * Float (Height) * (1.0 - Ratio) / (1.0 - Power);   --  bar fits exactly
      Speed := Float (2 + Random (4)) / 2000.0;
      for N in Spread'Range loop        --  left children turn left, right ones right
         Spread (N) := (if N mod 2 = 0 then -1.0 else 1.0) * Float (20 + Random (45)) / 100.0;
      end loop;
   end Randomize;

   procedure Start is
   begin
      Width  := Integer'Min (Params (1), Max_H);
      Height := Width;
      Ink    := (if Params (3) = 0 then 16#FFF0_F0F0# else Hue_Color (Params (3)));
      Phase  := 0.0;
      Randomize;
   end Start;

   --  Draw branch Node and, recursively, its two children.  Open = 0 puts
   --  everything in one column (the bar), Open = 1 is the full tree.
   procedure Branch (Node : Positive; Base : Vec; Angle, Len, Thick, Open : Float;
                     Level : Natural) is
      U   : constant Vec := Dir (Angle);
      Tip : constant Vec := Base + Len * U;
      Gap : constant Float := 2.0 * (1.0 - Open);   --  dark line between bar segments
   begin
      Stroke (Base, Tip - Gap * U, Thick, Thick * 0.8, Ink);
      if Level < Depth then
         for C in 0 .. 1 loop
            Branch (2 * Node + C, Tip, Angle + Open * Spread (2 * Node + C),
                    Len * Ratio, Float'Max (1.5, Thick * 0.6), Open, Level + 1);
         end loop;
      end if;
   end Branch;

   procedure Tick is
      Open : Float;
   begin
      Phase := Phase + Speed;
      if Phase >= 1.0 then
         Phase := 0.0;
         Randomize;
      end if;
      Open := (if Phase < 0.4 then Smooth (Phase / 0.4)
               elsif Phase < 0.5 then 1.0
               else 1.0 - Smooth ((Phase - 0.5) / 0.4));
      Clear;
      Branch (1, (Float (Width) / 2.0, Float (Height) * 0.97), -Pi / 2.0,
              Trunk, Float (Width) * 0.09, Open, 0);
   end Tick;

end SV.Tree;
