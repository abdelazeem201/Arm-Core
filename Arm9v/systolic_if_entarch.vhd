------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Systolic_Std_IF
--
--  Architecture  : Standard
--
--  Filename      : systolic_if_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models a standard user interface to the PEX 
--                  systolic bus pads.
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
--  Pads                   36      B    Pad signals for the bus
--  User_In.Data_In        36      O    Input data from the pads
--  User_Out.Data_Out      36      I    Output data to the pads
--  User_Out.Data_OE_n     36      I    Individual tri-state controls
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity Systolic_Std_IF is
  generic
  (
    INFF_Delay    : INTEGER := NODELAY;
    OBUF_Drive    : INTEGER := FAST_8mA
  );
  port
  (
    Clk           : in    std_logic;
    Global_Reset  : in    std_logic;
    Pads          : inout Systolic_Pads_Type;
    User_In       :   out Systolic_Std_IF_In_Type;
    User_Out      : in    Systolic_Std_IF_Out_Type
  );
end Systolic_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Structure of Systolic_Std_IF is

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
  --  Systolic_In.Data_In       36    Input data from the pads
  --  Systolic_Out.Data_Out     36    Output data to the pads
  --  Systolic_Out.Data_OE_n    36    Individual tri-state controls
  --
  ----------------------------------------------------------------------

  signal Systolic_In : Systolic_Basic_IO_In_Type;
  signal Systolic_Out : Systolic_Basic_IO_Out_Type;

begin

  Init_Systolic_Basic_IO ( Systolic_In );
  Init_Systolic_Std_IF ( User_In );

  U_Basic_IO : Systolic_Basic_IO
    generic map
    (
      INFF_Delay => INFF_Delay,
      OBUF_Drive => OBUF_Drive
    )
    port map
    (
      Pads      => Pads,
      User_In   => Systolic_In,
      User_Out  => Systolic_Out
    );

  G_Data : for I in Pads'range generate
    U_In : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => Systolic_In.Data_In(I),
        Q   => User_In.Data_In(I)
      );
    U_Out : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => User_Out.Data_Out(I),
        Q   => Systolic_Out.Data_Out(I)
      );
    U_OE : IOB_FDP
      port map
      (
        C   => Clk,
        PRE => Global_Reset,
        D   => User_Out.Data_OE_n(I),
        Q   => Systolic_Out.Data_OE_n(I)
      );
  end generate G_Data;

end Structure;

