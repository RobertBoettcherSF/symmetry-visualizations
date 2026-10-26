--  Growth Tree: a segmented bar opens into a fan of strips and then into a
--  branching tree, folds back, and regrows with new random branch angles.
--  It is one recursive tree; only the opening angle changes.
--  Params: 1 Size  2 Max depth  3 Colour (0 = white, else hue)
package SV.Tree is
   procedure Start;
   procedure Tick;
end SV.Tree;
