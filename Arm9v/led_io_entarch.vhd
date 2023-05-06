------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : LED_Basic_IO
--
--  Architecture  : Structure
--
--  Filename      : led_io_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models an interface to the PEX LEDs.
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
--  Pads.Red_n              1      O    Pad signal for the red LED
--  Pads.Green_n            1      O    Pad signal for the green LED
--  User_Out.Red_n          1      I    Output data to the red LED
--  User_Out.Green_n        1      I    Output data to the green LED
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity LED_Basic_IO is
  port
  (
    Pads      : inout LED_Pads_Type;
    User_Out  : in    LED_Basic_IO_Out_Type
  );
end LED_Basic_IO;

------------------------ Architecture Declaration ----------------------

architecture Structure of LED_Basic_IO is

  signal GND : std_logic;

begin

  GND <= '0';

  Init_LED_Pads ( Pads );

  U_Red_Out: OBUFT
    port map
    (
      O => Pads.Red_n,
      I => GND,
      T => User_Out.Red_n
    );

  U_Green_Out: OBUFT
    port map
    (
      O => Pads.Green_n,
      I => GND,
      T => User_Out.Green_n
    );

end Structure;

