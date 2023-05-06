------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : PE0_Bus_Std_IF
--
--  Architecture  : Standard
--
--  Filename      : pe0_bus_if_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models a standard user interface to the PE0-PEX bus.
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
--  Port Name             Width   Dir   Description
--  ====================  =====   ===   ================================
--  Pads                    2      B    Pad signals for the bus
--  User_In.Data_In         2      O    Input data from the pads
--  User_Out.Data_Out       2      I    Output data to the pads
--  User_Out.Data_OE_n      2      I    Individual tri-state controls
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity PE0_Bus_Std_IF is
  generic
  (
    INFF_Delay    : INTEGER := NODELAY;
    OBUF_Drive    : INTEGER := FAST_8mA
  );
  port
  (
    Clk           : in    std_logic;
    Global_Reset  : in    std_logic;
    Pads          : inout PE0_Bus_Pads_Type;
    User_In       :   out PE0_Bus_Std_IF_In_Type;
    User_Out      : in    PE0_Bus_Std_IF_Out_Type
  );
end PE0_Bus_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Structure of PE0_Bus_Std_IF is

  ------------------------------- Glossary -----------------------------
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
  --  Port Name               Width   Description
  --  ======================  =====   ==================================
  --  PE0_Bus_In.Data_In        2     Input data from the pads
  --  PE0_Bus_Out.Data_Out      2     Output data to the pads
  --  PE0_Bus_Out.Data_OE_n     2     Individual tri-state controls
  --
  ----------------------------------------------------------------------

  signal PE0_Bus_In   : PE0_Bus_Basic_IO_In_Type;
  signal PE0_Bus_Out  : PE0_Bus_Basic_IO_Out_Type;

begin

  Init_PE0_Bus_Basic_IO ( PE0_Bus_In );
  Init_PE0_Bus_Std_IF ( User_In );

  U_Basic_IO : PE0_Bus_Basic_IO
    generic map
    (
      INFF_Delay => INFF_Delay,
      OBUF_Drive => OBUF_Drive
    )
    port map
    (
      Pads      => Pads,
      User_In   => PE0_Bus_In,
      User_Out  => PE0_Bus_Out
    );

  G_Data : for I in Pads'range generate
    U_In : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => PE0_Bus_In.Data_In(I),
        Q   => User_In.Data_In(I)
      );
    U_Out : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => User_Out.Data_Out(I),
        Q   => PE0_Bus_Out.Data_Out(I)
      );
    U_OE : IOB_FDP
      port map
      (
        C   => Clk,
        PRE => Global_Reset,
        D   => User_Out.Data_OE_n(I),
        Q   => PE0_Bus_Out.Data_OE_n(I)
      );
  end generate G_Data;

end Structure;

