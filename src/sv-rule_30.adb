package body SV.Rule_30 is

   type Row is array (0 .. Max_W - 1) of Boolean;
   Cells, Next : Row;
   Rows_Done   : Natural := 0;   --  rows drawn so far (until the screen is full)
   Frame_Count : Natural := 0;   --  frames since the last new row

   procedure Draw_Row (Y : Natural) is
      On : constant Pixel := Hue_Color (Params (6));
   begin
      for X in 0 .. Width - 1 loop
         Put (X, Y, (if Cells (X) then On else Black));
      end loop;
   end Draw_Row;

   procedure Start is
   begin
      Width  := Integer'Min (Params (2), Max_W);
      Height := Integer'Min (Params (3), Max_H);
      Clear;
      for X in 0 .. Width - 1 loop
         Cells (X) := Params (4) = 1 and then Random (2) = 1;
      end loop;
      Cells (Width / 2) := True;
      Draw_Row (0);
      Rows_Done := 1;
   end Start;

   procedure Step is
      Rule : constant Natural := Params (1);
      L, R : Natural;
      Pattern : Natural;   --  left, centre, right as a 3-bit number
   begin
      for X in 0 .. Width - 1 loop
         L := (X + Width - 1) mod Width;   --  the row wraps around
         R := (X + 1) mod Width;
         Pattern := Boolean'Pos (Cells (L)) * 4 + Boolean'Pos (Cells (X)) * 2
                    + Boolean'Pos (Cells (R));
         Next (X) := (Rule / 2 ** Pattern) mod 2 = 1;
      end loop;
      Cells := Next;

      if Rows_Done < Height then
         Draw_Row (Rows_Done);
         Rows_Done := Rows_Done + 1;
      else
         --  scroll everything up by one row, draw the new row at the bottom
         for I in 0 .. Width * (Height - 1) - 1 loop
            Frame (I) := Frame (I + Width);
         end loop;
         Draw_Row (Height - 1);
      end if;
   end Step;

   procedure Tick is
   begin
      Frame_Count := Frame_Count + 1;
      if Frame_Count >= Params (5) then
         Frame_Count := 0;
         Step;
      end if;
   end Tick;

end SV.Rule_30;
