--  Balance: two squares on a beam (weight = area).  One slides, the beam
--  tilts with the torque, the other slides until W1 * D1 = W2 * D2 again.
--  Params: 1 Size  2 Speed  3 Colour (0 = white, else hue)
package SV.Balance is
   procedure Start;
   procedure Tick;
end SV.Balance;
