------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Mem_Basic_IO
--
--  Architecture  : Structure
--
--  Filename      : mem_io_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models the interface to the PEX memory port pads.
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
--  Pads.Addr               19     O    Address bus pads
--  Pads.Data               36     B    Data bus pads
--  Pads.Addr_CS_n           1     O    Address chip select pad
--  Pads.CS_n                1     O    Chip select pad
--  Pads.WE_n                1     O    Write enable pad
--  User_Out.Addr           19     I    Address bus output
--  User_In.Data_In         36     O    Input data bus
--  User_Out.Data_Out       36     I    Output data bus
--  User_Out.Data_OE_n      36     I    Output enable for data bytes
--  User_Out.Addr_CS_n       1     I    Address chip select output
--  User_Out.CS_n            1     I    Chip select output
--  User_Out.WE_n            1     I    Write enable output
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity Mem_Basic_IO is
  generic
  (
    INFF_Delay    : INTEGER := NODELAY;
    OBUF_Drive    : INTEGER := FAST_8mA
  );
  port
  (
    Pads      : inout Mem_Pads_Type;
    User_In   :   out Mem_Basic_IO_In_Type;
    User_OUt  : in    Mem_Basic_IO_Out_Type
  );
end Mem_Basic_IO;

------------------------ Architecture Declaration ----------------------

architecture Structure of Mem_Basic_IO is

begin

  Init_Mem_Pads ( Pads );
  Init_Mem_Basic_IO ( User_In );

  G_Addr : for I in Pads.Addr'range generate

    G_Slow_12mA : if ( OBUF_Drive = SLOW_12mA ) generate
      U_Addr : OBUF_S_12 
        port map
        (
          O => Pads.Addr(I),
          I => User_Out.Addr(I)
        );
    end generate G_Slow_12mA;

    G_Slow_8mA : if ( OBUF_Drive = SLOW_8mA ) generate
      U_Addr : OBUF_S_8 
        port map
        (
          O => Pads.Addr(I),
          I => User_Out.Addr(I)
        );
    end generate G_Slow_8mA;

    G_Fast_12mA : if ( OBUF_Drive = FAST_12mA ) generate
      U_Addr : OBUF_F_12 
        port map
        (
          O => Pads.Addr(I),
          I => User_Out.Addr(I)
        );
    end generate G_Fast_12mA;

    G_Fast_8mA : if ( OBUF_Drive = FAST_8mA ) generate
      U_Addr : OBUF_F_8 
        port map
        (
          O => Pads.Addr(I),
          I => User_Out.Addr(I)
        );
    end generate G_Fast_8mA;

  end generate;

  G_Data : for I in Pads.Data'range generate

    G_Slow_12mA : if ( OBUF_Drive = SLOW_12mA ) generate
      U_Data_Out: OBUFT_S_12
        port map
        (
          O => Pads.Data(I),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Slow_12mA;

    G_Slow_8mA : if ( OBUF_Drive = SLOW_8mA ) generate
      U_Data_Out: OBUFT_S_8
        port map
        (
          O => Pads.Data(I),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Slow_8mA;

    G_Fast_12mA : if ( OBUF_Drive = FAST_12mA ) generate
      U_Data_Out: OBUFT_F_12
        port map
        (
          O => Pads.Data(I),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Fast_12mA;

    G_Fast_8mA : if ( OBUF_Drive = FAST_8mA ) generate
      U_Data_Out: OBUFT_F_8
        port map
        (
          O => Pads.Data(I),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Fast_8mA;

    G_Delay : if ( INFF_Delay = DELAY ) generate
      U_Data_In: IBUF
        port map
        (
          I => Pads.Data(I),
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
          I => Pads.Data(I),
          O => User_In.Data_In(I)
        );
    end generate G_Nodelay;

  end generate;

  G_Slow_12mA : if ( OBUF_Drive = SLOW_12mA ) generate

    U_Addr_CS : OBUF_S_12
      port map
      (
        O => Pads.Addr_CS_n,
        I => User_Out.Addr_CS_n
      );

    U_CS : OBUF_S_12
      port map
      (
        O => Pads.CS_n,
        I => User_Out.CS_n
      );

    U_WE : OBUF_S_12
      port map
      (
        O => Pads.WE_n,
        I => User_Out.WE_n
      );

  end generate G_Slow_12mA;

  G_Slow_8mA : if ( OBUF_Drive = SLOW_8mA ) generate

    U_Addr_CS : OBUF_S_8
      port map
      (
        O => Pads.Addr_CS_n,
        I => User_Out.Addr_CS_n
      );

    U_CS : OBUF_S_8
      port map
      (
        O => Pads.CS_n,
        I => User_Out.CS_n
      );

    U_WE : OBUF_S_8
      port map
      (
        O => Pads.WE_n,
        I => User_Out.WE_n
      );

  end generate G_Slow_8mA;

  G_Fast_12mA : if ( OBUF_Drive = FAST_12mA ) generate

    U_Addr_CS : OBUF_F_12
      port map
      (
        O => Pads.Addr_CS_n,
        I => User_Out.Addr_CS_n
      );

    U_CS : OBUF_F_12
      port map
      (
        O => Pads.CS_n,
        I => User_Out.CS_n
      );

    U_WE : OBUF_F_12
      port map
      (
        O => Pads.WE_n,
        I => User_Out.WE_n
      );

  end generate G_Fast_12mA;

  G_Fast_8mA : if ( OBUF_Drive = FAST_8mA ) generate

    U_Addr_CS : OBUF_F_8
      port map
      (
        O => Pads.Addr_CS_n,
        I => User_Out.Addr_CS_n
      );

    U_CS : OBUF_F_8
      port map
      (
        O => Pads.CS_n,
        I => User_Out.CS_n
      );

    U_WE : OBUF_F_8
      port map
      (
        O => Pads.WE_n,
        I => User_Out.WE_n
      );

  end generate G_Fast_8mA;

end Structure;

