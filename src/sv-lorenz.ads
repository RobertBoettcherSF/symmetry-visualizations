--  Lorenz attractor: dx = s (y - x), dy = x (r - z) - y, dz = x y - b z
--  with s = 10, b = 8/3.  A bright head leaves a dotted trail that fades,
--  and the view slowly turns around the vertical axis.
--  Params: 1 Size  2 Steps per frame  3 Trail length  4 Colour (0 = white)  5 Rho
package SV.Lorenz is
   procedure Start;
   procedure Tick;
end SV.Lorenz;
