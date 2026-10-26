--  Field-line diagrams of point charges (five small figures in the book).
--  Variant 1 Dipole with equipotentials   2 Four-lobed loops (orbiting)
--          3 Two dipoles, dots flowing      4 Grid globe
--          5 Fan of three equal charges
--  Params: 1 Size  2 Lines per charge  3 Colour (0 = cream, else hue)
--  Charge strengths and speeds are random for every run.
package SV.Fields is
   procedure Start (Variant : Positive);
   procedure Tick;
end SV.Fields;
