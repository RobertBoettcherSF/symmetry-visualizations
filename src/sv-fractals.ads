--  Fractals that build up level by level and fold back again:
--  Variant 1 Sierpinski triangle  2 Koch snowflake  3 Sierpinski hexagon
--  Params: 1 Size  2 Max depth  3 Speed  4 Colour (0 = white)
package SV.Fractals is
   procedure Start (Variant : Positive);
   procedure Tick;
end SV.Fractals;
