------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Clock_Basic_IO
--
--  Architecture  : Structure
--
--  Filename      : clock_io_entarch.vhd
--
--  Date          : 3/1/99
--
--  Description   : Model provides basic interface from PEX clock pads
--                  using Xilinx buffer primitives.
--  https://www.micro-semiconductor.sg/datasheet/07-PEX8311RDK.pdf
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

------------------------------- Glossary -------------------------------
--
--  Name Key:
--  =========
--  _AS       : Address Strobe
--  _CB       : CardBus
--  _CE       : Clock Enable
--  _CS       : Chip Select
--  _DS       : Data Strobe
--  _EN       : Enable
--  _OE       : Output Enable
--  _PE       : Processing Element
--  _RD       : Read Select
--  _WE       : Write Enable
--  _WR       : Write Select
--  _d[d...]  : Delayed (registered) signal (each 'd' denotes one 
--              level of delay)
--  _n        : Active low signals (must be last part of name)
--
--  Port Name                   Width  Dir  Description
--  ==========================  =====  ===  ============================
--  Pads.M_Clk                    1     I   Memory clock
--  Pads.P_Clk                    1     I   Processing element clock
--  Pads.K_Clk                    1     I   LAD-bus clock
--  Pads.U_Clk                    1     I   User clock
--  User_In.M_Clk                 1     O   Memory clock
--  User_In.P_Clk                 1     O   Processing element clock
--  User_In.K_Clk                 1     O   LAD-bus clock
--  User_In.U_Clk                 1     O   User clock
--
------------------------------------------------------------------------

--------------------------- Entity Declaration -------------------------

entity Clock_Basic_IO is
  port
  (
    Pads    : inout Clock_Pads_Type;
    User_In :   out Clock_Basic_IO_In_Type
  );
end entity;

------------------------ Architecture Declaration ----------------------

architecture Structure of Clock_Basic_IO is

begin

  Init_Clock_Pads ( Pads );
  Init_Clock_Basic_IO ( User_In );

  U_M_Clk : IBUFG
    port map
    (
      I => Pads.M_Clk,
      O => User_In.M_Clk
    );

  U_P_Clk : IBUFG
    port map
    (
      I => Pads.P_Clk,
      O => User_In.P_Clk
    );

  U_K_Clk : IBUFG
    port map
    (
      I => Pads.K_Clk,
      O => User_In.K_Clk
    );

  U_U_Clk : IBUFG
    port map
    (
      I => Pads.U_Clk,
      O => User_In.U_Clk
    );

end Structure;

