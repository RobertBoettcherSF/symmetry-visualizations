with SV.Rule_30;
with SV.Life;
with SV.Mandala;
with SV.Fields;
with SV.Tree;
with SV.Balance;
with SV.Lorenz;
with SV.Fractals;
with SV.Evolute;
with SV.Crystal;

package body SV.API is

   Current : Integer := 0;

   function Frame_Address return System.Address is (Frame'Address);
   function Frame_Width return Integer is (Width);
   function Frame_Height return Integer is (Height);

   procedure Set_Param (Index, Value : Integer) is
   begin
      Params (Index) := Value;
   end Set_Param;

   procedure Start (Viz : Integer; Seed : Unsigned_32) is
   begin
      SV.Seed (Seed);
      Current := Viz;
      case Current is
         when 0      => Rule_30.Start;
         when 1      => Life.Start;
         when 2      => Mandala.Start;
         when 3 .. 7 => Fields.Start (Viz - 2);
         when 8      => Tree.Start;
         when 9      => Balance.Start;
         when 10     => Lorenz.Start;
         when 11 .. 13 => Fractals.Start (Viz - 10);
         when 14     => Evolute.Start;
         when 15     => Crystal.Start;
         when others => null;
      end case;
   end Start;

   procedure Tick is
   begin
      case Current is
         when 0      => Rule_30.Tick;
         when 1      => Life.Tick;
         when 2      => Mandala.Tick;
         when 3 .. 7 => Fields.Tick;
         when 8      => Tree.Tick;
         when 9      => Balance.Tick;
         when 10     => Lorenz.Tick;
         when 11 .. 13 => Fractals.Tick;
         when 14     => Evolute.Tick;
         when 15     => Crystal.Tick;
         when others => null;
      end case;
   end Tick;

end SV.API;
