------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Systolic_Basic_IO
--
--  Architecture  : Structure
--
--  Filename      : systolic_io_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models an interface to the PEX systolic bus.
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

entity Systolic_Basic_IO is
  generic
  (
    INFF_Delay    : INTEGER := NODELAY;
    OBUF_Drive    : INTEGER := FAST_8mA
  );
  port
  (
    Pads      : inout Systolic_Pads_Type;
    User_In   :   out Systolic_Basic_IO_In_Type;
    User_Out  : in    Systolic_Basic_IO_Out_Type
  );
end Systolic_Basic_IO;

------------------------ Architecture Declaration ----------------------

architecture Structure of Systolic_Basic_IO is

begin

  Init_Systolic_Pads ( Pads );
  Init_Systolic_Basic_IO ( User_In );

  G_Data : for I in Pads'range generate
  begin

    G_Slow_12mA : if ( OBUF_Drive = SLOW_12mA ) generate
      U_Data_Out: OBUFT_S_12
        port map
        (
          O => Pads(I),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Slow_12mA;

    G_Slow_8mA : if ( OBUF_Drive = SLOW_8mA ) generate
      U_Data_Out: OBUFT_S_8
        port map
        (
          O => Pads(I),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Slow_8mA;

    G_Fast_12mA : if ( OBUF_Drive = FAST_12mA ) generate
      U_Data_Out: OBUFT_F_12
        port map
        (
          O => Pads(I),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Fast_12mA;

    G_Fast_8mA : if ( OBUF_Drive = FAST_8mA ) generate
      U_Data_Out: OBUFT_F_8
        port map
        (
          O => Pads(I),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Fast_8mA;

    G_Delay : if ( INFF_Delay = DELAY ) generate
      U_Data_In: IBUF
        port map
        (
          I => Pads(I),
          O => User_In.Data_In(I)
        );
    end generate G_Delay;

    G_Nodelay : if ( INFF_Delay = NODELAY ) generate
      attribute nodelay : string;
      attribute nodelay of U_Data_In : label is " ";
    begin
      U_Data_In: IBUF
        port map
        (
          I => Pads(I),
          O => User_In.Data_In(I)
        );
    end generate G_Nodelay;

  end generate;

end Structure;

