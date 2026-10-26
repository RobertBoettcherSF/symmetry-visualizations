package body SV.Life is

   type Grid is array (0 .. Max_W * Max_H - 1) of Boolean;
   Cells, Next : Grid;
   Frames      : Natural := 0;

   function Alive (X, Y : Integer) return Natural is
      XX : Integer := X;
      YY : Integer := Y;
   begin
      if Params (4) = 1 then            --  torus: leave one edge, enter the other
         XX := (X + Width) mod Width;
         YY := (Y + Height) mod Height;
      elsif X < 0 or Y < 0 or X >= Width or Y >= Height then
         return 0;                      --  outside counts as dead
      end if;
      return Boolean'Pos (Cells (YY * Width + XX));
   end Alive;

   procedure Draw is
      On : constant Pixel := Hue_Color (Params (6));
   begin
      for I in 0 .. Width * Height - 1 loop
         Frame (I) := (if Cells (I) then On else Black);
      end loop;
   end Draw;

   procedure Start is
   begin
      Width  := Integer'Min (Params (1), Max_W);
      Height := Integer'Min (Params (2), Max_H);
      for I in 0 .. Width * Height - 1 loop
         Cells (I) := Random (100) < Params (3);
      end loop;
      Frames := 0;
      Draw;
   end Start;

   procedure Step is
      N : Natural;
   begin
      for Y in 0 .. Height - 1 loop
         for X in 0 .. Width - 1 loop
            N := Alive (X - 1, Y - 1) + Alive (X, Y - 1) + Alive (X + 1, Y - 1)
               + Alive (X - 1, Y)                         + Alive (X + 1, Y)
               + Alive (X - 1, Y + 1) + Alive (X, Y + 1) + Alive (X + 1, Y + 1);
            Next (Y * Width + X) :=
              N = 3 or (N = 2 and Cells (Y * Width + X));
         end loop;
      end loop;
      Cells := Next;
   end Step;

   procedure Tick is
   begin
      Frames := Frames + 1;
      if Frames >= Params (5) then
         Frames := 0;
         Step;
         Draw;
      end if;
   end Tick;

end SV.Life;
