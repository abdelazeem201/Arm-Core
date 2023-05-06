------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : PEX
--
--  Filename      : pex_ent.vhd
--
--  Date          : 9/3/99
--
--  Description   : Top-level model of the processing element 'X'
--                  (PEX, where 'X' is 1 or 2).
--
------------------------------------------------------------------------

------------------------------- Glossary -------------------------------
--
--  Name Key:
--  =========
--  _AS       : Address Strobe
--  _CE       : Clock Enable
--  _CS       : Chip Select
--  _DS       : Data Strobe
--  _EN       : Enable
--  _OE       : Output Enable
--  _RD       : Read Select
--  _WE       : Write Enable
--  _WR       : Write Select
--  _d[d...]  : Delayed (registered) signal (each 'd' denotes one 
--              level of delay)
--  _n        : Active low signals (must be last part of name)
--
--  Port Name                      Dir  Description
--  ============================   ===  ================================
--  Pads.Clocks.M_Clk               I   Memory clock
--  Pads.Clocks.P_Clk               I   Processor clock
--  Pads.Clocks.K_Clk               I   LAD-bus clock
--  Pads.Clocks.U_Clk               I   User clock
--  Pads.Reset                      I   Global reset
--  Pads.LAD_Bus.Addr_Data          B   LAD-bus shared address/data bus
--  Pads.LAD_Bus.DS_n               I   LAD-bus data strobe
--  Pads.LAD_Bus.Reg_n              I   LAD-bus register select
--  Pads.LAD_Bus.WR_n               I   LAD-bus write select
--  Pads.LAD_Bus.CS_n               I   LAD-bus chip select
--  Pads.LAD_Bus.Int_Req_n          O   LAD-bus interrupt request
--  Pads.LAD_Bus.DMA_Chan           I   DMA channel number indicator
--  Pads.LAD_Bus.DMA_Stat           O   DMA channel status flags
--  Pads.Left_Mem.Addr              O   Left memory address bus
--  Pads.Left_Mem.Data              B   Left memory data bus
--  Pads.Left_Mem.Addr_CS_n         O   Left memory address chip select
--  Pads.Left_Mem.CS_n              O   Left memory chip select
--  Pads.Left_Mem.WE_n              O   Left memory write enable
--  Pads.Right_Mem.Addr             O   Left memory address bus
--  Pads.Right_Mem.Data             B   Left memory data bus
--  Pads.Right_Mem.Addr_CS_n        O   Left memory address chip select
--  Pads.Right_Mem.CS_n             O   Left memory chip select
--  Pads.Right_Mem.WE_n             O   Left memory write enable
--  Pads.Top_Sys                    B   Top systolic bus
--  Pads.Bot_Sys                    B   Bottom systolic bus
--  Pads.Mezz.Left                  B   Left mezzanine connector
--  Pads.Mezz.Right                 B   Right mezzanine connector
--  Pads.LEDs.Red_n                 O   Red light emitting diode
--  Pads.LEDs.Green_n               O   Green light emitting diode
--  Pads.PE0_Bus                    B   PE0 bus
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;

--------------------------- Entity Declaration -------------------------

entity PEX is
  generic
  (
    SYNTHESIS : boolean := TRUE
  );
  port
  (
    Pads : inout PEX_Pads_Type
  );
end PEX;

