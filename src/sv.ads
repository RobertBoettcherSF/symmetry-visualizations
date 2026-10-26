--  Shared state for all visualizations: one pixel frame, a parameter
--  list, a tiny random generator and a colour helper.
with Interfaces; use Interfaces;

package SV is

   Max_W : constant := 1024;
   Max_H : constant := 1024;

   subtype Pixel is Unsigned_32;   --  16#AABBGGRR#, the byte order of a canvas
   Black : constant Pixel := 16#FF10_1010#;

   type Pixel_Array is array (0 .. Max_W * Max_H - 1) of Pixel;
   Frame  : Pixel_Array;           --  what the browser draws
   Width  : Natural := 0;          --  size of the picture inside Frame
   Height : Natural := 0;

   type Param_Array is array (1 .. 8) of Integer;
   Params : Param_Array := (others => 0);   --  set by the Settings menu

   procedure Put (X, Y : Natural; C : Pixel) with Inline;
   procedure Clear;

   procedure Seed (S : Unsigned_32);
   function Random (Below : Positive) return Natural;   --  0 .. Below - 1

   function Hue_Color (Hue : Natural) return Pixel;     --  hue in degrees

end SV;
