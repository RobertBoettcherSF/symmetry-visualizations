package body SV is

   State : Unsigned_32 := 2463534242;

   procedure Put (X, Y : Natural; C : Pixel) is
   begin
      Frame (Y * Width + X) := C;
   end Put;

   procedure Clear is
   begin
      for I in 0 .. Width * Height - 1 loop
         Frame (I) := Black;
      end loop;
   end Clear;

   procedure Seed (S : Unsigned_32) is
   begin
      State := (if S = 0 then 1 else S);
   end Seed;

   --  Marsaglia's xorshift32
   function Random (Below : Positive) return Natural is
   begin
      State := State xor Shift_Left (State, 13);
      State := State xor Shift_Right (State, 17);
      State := State xor Shift_Left (State, 5);
      return Natural (State mod Unsigned_32 (Below));
   end Random;

   procedure Square (Size : Natural) is
   begin
      Width  := Natural'Min (Size, Max_H);
      Height := Width;
   end Square;

   function Hue_Color (Hue : Natural) return Pixel is
      F    : constant Unsigned_32 := Unsigned_32 (Hue mod 60) * 255 / 60;
      R, G, B : Unsigned_32;
   begin
      case (Hue mod 360) / 60 is
         when 0      => R := 255;     G := F;       B := 0;
         when 1      => R := 255 - F; G := 255;     B := 0;
         when 2      => R := 0;       G := 255;     B := F;
         when 3      => R := 0;       G := 255 - F; B := 255;
         when 4      => R := F;       G := 0;       B := 255;
         when others => R := 255;     G := 0;       B := 255 - F;
      end case;
      return 16#FF00_0000# or Shift_Left (B, 16) or Shift_Left (G, 8) or R;
   end Hue_Color;

end SV;
