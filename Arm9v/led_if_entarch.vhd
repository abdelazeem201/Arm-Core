------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : LED_Std_IF
--
--  Architecture  : Standard
--
--  Filename      : led_if_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models a standard user interface to the PEX LEDs.
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

entity LED_Std_IF is
  port
  (
    Pads      : inout LED_Pads_Type;
    User_Out  : in    LED_Std_IF_Out_Type
  );
end LED_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Structure of LED_Std_IF is

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
  --  LED_Out.Red_n             1     Red LED signal
  --  LED_Out.Green_n           1     Green LED signal
  --
  ----------------------------------------------------------------------

  signal LED_Out : LED_Basic_IO_Out_Type;

begin

  U_Basic_IO : LED_Basic_IO
    port map
    (
      Pads      => Pads,
      User_Out  => LED_Out
    );

  LED_Out.Red_n <= User_Out.Red_n;
  LED_Out.Green_n <= User_Out.Green_n;

end Structure;

