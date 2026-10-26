with SV.Rule_30;
with SV.Life;
with SV.Mandala;
with SV.Fields;
with SV.Tree;
with SV.Balance;

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
         when others => null;
      end case;
   end Tick;

end SV.API;
