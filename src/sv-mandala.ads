--  "Star Mandala": a star medallion (book photo) that rotates; the small
--  rosettes spin the other way and rows of triangles flow out along the arms.
--  Params: 1 Size (pixels)  2 Star points  3 Colour (0 = white, else hue)
--          4 Triangle size (1/100 of the radius)
--  Spin speeds and directions are chosen at random in Start, not settings.
package SV.Mandala is
   procedure Start;
   procedure Tick;
end SV.Mandala;
