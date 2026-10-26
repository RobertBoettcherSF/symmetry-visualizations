--  The functions the browser calls. Each visualization is a package with
--  Start and Tick; to add one, add a case branch below and an entry in
--  the VIZ table of web/template.html.
with System;

package SV.API is

   function Frame_Address return System.Address
     with Export, Convention => C, External_Name => "sv_frame";
   function Frame_Width return Integer
     with Export, Convention => C, External_Name => "sv_width";
   function Frame_Height return Integer
     with Export, Convention => C, External_Name => "sv_height";

   procedure Set_Param (Index, Value : Integer)
     with Export, Convention => C, External_Name => "sv_set_param";
   procedure Start (Viz : Integer; Seed : Unsigned_32)
     with Export, Convention => C, External_Name => "sv_start";
   procedure Tick
     with Export, Convention => C, External_Name => "sv_tick";

end SV.API;
