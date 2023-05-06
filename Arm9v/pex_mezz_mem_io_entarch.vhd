------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Mezz_Mem_Basic_IO
--
--  Architecture  : Standard
--
--  Filename      : pex_mezz_mem_io_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models the basic I/O components that provide an
--                  interface between PEX and a mezzanine memory card.
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
--  Pads(18 downto 0)      19      B    Address pads
--  Pads(82 downto 19)     64      B    Data pads
--  Pads(83)                1      B    Address chip select pad
--  Pads(84)                1      B    Low Dword chip select pad
--  Pads(85)                1      B    Hi Dword chip select pad
--  Pads(86)                1      B    Write enable pad
--  Pads(88 downto 87)      2      B    Crossbar mode pads
--  User_In.Addr_In        19      O    Address input
--  User_In.Data_In        64      O    Data input
--  User_In.Low_CS_In_n     1      O    Low Dword chip select input
--  User_In.Addr_CS_In_n    1      O    Address chip select input
--  User_In.High_CS_In_n    1      O    Hi Dword chip select input
--  User_In.WE_In_n         1      O    Write enable input
--  User_In.Xbar_Mode_In    2      O    Crossbar mode input
--  User_Out.Addr_Out      19      I    Address output
--  User_Out.Addr_OE_n     19      I    Address output enable
--  User_Out.Data_Out      64      I    Data output
--  User_Out.Data_OE_n     64      I    Data output enable
--  User_Out.Addr_CS_Out_n  1      I    Address chip select output
--  User_Out.Addr_CS_OE_n   1      I    Address chip sel out enable
--  User_Out.Low_CS_Out_n   1      I    Low Dword chip select output
--  User_Out.Low_CS_OE_n    1      I    Low Dword chip sel out enable
--  User_Out.High_CS_Out_n  1      I    Hi Dword chip select output
--  User_Out.High_CS_En_n   1      I    Hi Dword chip sel out enable
--  User_Out.WE_Out_n       1      I    Write enable output
--  User_Out.WE_OE_n        1      I    Write enable output enable
--  User_Out.Xbar_Mode_Out  2      I    Crossbar mode output
--  User_Out.Xbar_Mode_OE_n 2      I    Crossbar mode output enable
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use PEX_Lib.PE_Mezz_Mem_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity Mezz_Mem_Basic_IO is
  generic
  (
    INFF_Delay    : INTEGER := NODELAY;
    OBUF_Drive    : INTEGER := SLOW_12mA
  );
  port
  (
    Pads      : inout std_logic_vector ( 88 downto 0 );
    User_In   :   out Mezz_Mem_Basic_IO_In_Type;
    User_Out  : in    Mezz_Mem_Basic_IO_Out_Type
  );
end Mezz_Mem_Basic_IO;

------------------------ Architecture Declaration ----------------------

architecture Standard of Mezz_Mem_Basic_IO is

begin
 
  Pads <= ( others => 'Z' );
  Init_Mezz_Mem_Basic_IO ( User_In );

  G_Addr : for I in 0 to 18 generate
    G_Slow_12mA : if ( OBUF_Drive = SLOW_12mA ) generate
      U_Addr_Out : OBUFT_S_12
        port map
        (
          O => Pads(I),
          I => User_Out.Addr_Out(I),
          T => User_Out.Addr_OE_n(I)
        );
    end generate G_Slow_12mA;
    G_Slow_8mA : if ( OBUF_Drive = SLOW_8mA ) generate
      U_Addr_Out : OBUFT_S_8
        port map
        (
          O => Pads(I),
          I => User_Out.Addr_Out(I),
          T => User_Out.Addr_OE_n(I)
        );
    end generate G_Slow_8mA;
    G_Fast_12mA : if ( OBUF_Drive = FAST_12mA ) generate
      U_Addr_Out : OBUFT_F_12
        port map
        (
          O => Pads(I),
          I => User_Out.Addr_Out(I),
          T => User_Out.Addr_OE_n(I)
        );
    end generate G_Fast_12mA;
    G_Fast_8mA : if ( OBUF_Drive = FAST_8mA ) generate
      U_Addr_Out : OBUFT_F_8
        port map
        (
          O => Pads(I),
          I => User_Out.Addr_Out(I),
          T => User_Out.Addr_OE_n(I)
        );
    end generate G_Fast_8mA;
    G_Delay : if ( INFF_Delay = DELAY ) generate
      U_Addr_In : IBUF
        port map
        (
          I => Pads(I),
          O => User_In.Addr_In(I)
        );
    end generate G_Delay;
    G_Nodelay : if ( INFF_Delay = NODELAY ) generate
      attribute nodelay : string;
      attribute nodelay of U_Addr_In : label is " ";
    begin
      U_Addr_In : IBUF
        port map
        (
          I => Pads(I),
          O => User_In.Addr_In(I)
        );
    end generate G_Nodelay;
  end generate G_Addr;

  G_Data : for I in 0 to 63 generate
    G_Slow_12mA : if ( OBUF_Drive = SLOW_12mA ) generate
      U_Data_Out : OBUFT_S_12
        port map
        (
          O => Pads(I+19),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Slow_12mA;
    G_Slow_8mA : if ( OBUF_Drive = SLOW_8mA ) generate
      U_Data_Out : OBUFT_S_8
        port map
        (
          O => Pads(I+19),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Slow_8mA;
    G_Fast_12mA : if ( OBUF_Drive = FAST_12mA ) generate
      U_Data_Out : OBUFT_F_12
        port map
        (
          O => Pads(I+19),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Fast_12mA;
    G_Fast_8mA : if ( OBUF_Drive = FAST_8mA ) generate
      U_Data_Out : OBUFT_F_8
        port map
        (
          O => Pads(I+19),
          I => User_Out.Data_Out(I),
          T => User_Out.Data_OE_n(I)
        );
    end generate G_Fast_8mA;
    G_Delay : if ( INFF_Delay = DELAY ) generate
      U_Data_In : IBUF
        port map
        (
          I => Pads(I+19),
          O => User_In.Data_In(I)
        );
    end generate G_Delay;

    G_Nodelay : if ( INFF_Delay = NODELAY ) generate
      attribute nodelay : string;
      attribute nodelay of U_Data_In : label is " ";
    begin
      U_Data_In : IBUF
        port map
        (
          I => Pads(I+19),
          O => User_In.Data_In(I)
        );
    end generate G_Nodelay;
  end generate G_Data;

  G_Slow_12mA : if ( OBUF_Drive = SLOW_12mA ) generate

    U_Addr_CS_Out : OBUFT_S_12
      port map
      (
        O => Pads(83),
        I => User_Out.Addr_CS_Out_n,
        T => User_Out.Addr_CS_OE_n
      );

    U_Low_CS_Out : OBUFT_S_12
      port map
      (
        O => Pads(84),
        I => User_Out.Low_CS_Out_n,
        T => User_Out.Low_CS_OE_n
      );

    U_High_CS_Out : OBUFT_S_12
      port map
      (
        O => Pads(85),
        I => User_Out.High_CS_Out_n,
        T => User_Out.High_CS_OE_n
      );

    U_WE_Out : OBUFT_S_12
      port map
      (
        O => Pads(86),
        I => User_Out.WE_Out_n,
        T => User_Out.WE_OE_n
      );

  end generate G_Slow_12mA;

  G_Slow_8mA : if ( OBUF_Drive = SLOW_8mA ) generate

    U_Addr_CS_Out : OBUFT_S_8
      port map
      (
        O => Pads(83),
        I => User_Out.Addr_CS_Out_n,
        T => User_Out.Addr_CS_OE_n
      );

    U_Low_CS_Out : OBUFT_S_8
      port map
      (
        O => Pads(84),
        I => User_Out.Low_CS_Out_n,
        T => User_Out.Low_CS_OE_n
      );

    U_High_CS_Out : OBUFT_S_8
      port map
      (
        O => Pads(85),
        I => User_Out.High_CS_Out_n,
        T => User_Out.High_CS_OE_n
      );

    U_WE_Out : OBUFT_S_8
      port map
      (
        O => Pads(86),
        I => User_Out.WE_Out_n,
        T => User_Out.WE_OE_n
      );

  end generate G_Slow_8mA;

  G_Fast_12mA : if ( OBUF_Drive = FAST_12mA ) generate

    U_Addr_CS_Out : OBUFT_F_12
      port map
      (
        O => Pads(83),
        I => User_Out.Addr_CS_Out_n,
        T => User_Out.Addr_CS_OE_n
      );

    U_Low_CS_Out : OBUFT_F_12
      port map
      (
        O => Pads(84),
        I => User_Out.Low_CS_Out_n,
        T => User_Out.Low_CS_OE_n
      );

    U_High_CS_Out : OBUFT_F_12
      port map
      (
        O => Pads(85),
        I => User_Out.High_CS_Out_n,
        T => User_Out.High_CS_OE_n
      );

    U_WE_Out : OBUFT_F_12
      port map
      (
        O => Pads(86),
        I => User_Out.WE_Out_n,
        T => User_Out.WE_OE_n
      );

  end generate G_Fast_12mA;

  G_Fast_8mA : if ( OBUF_Drive = FAST_8mA ) generate

    U_Addr_CS_Out : OBUFT_F_8
      port map
      (
        O => Pads(83),
        I => User_Out.Addr_CS_Out_n,
        T => User_Out.Addr_CS_OE_n
      );

    U_Low_CS_Out : OBUFT_F_8
      port map
      (
        O => Pads(84),
        I => User_Out.Low_CS_Out_n,
        T => User_Out.Low_CS_OE_n
      );

    U_High_CS_Out : OBUFT_F_8
      port map
      (
        O => Pads(85),
        I => User_Out.High_CS_Out_n,
        T => User_Out.High_CS_OE_n
      );

    U_WE_Out : OBUFT_F_8
      port map
      (
        O => Pads(86),
        I => User_Out.WE_Out_n,
        T => User_Out.WE_OE_n
      );

  end generate G_Fast_8mA;

  G_Delay : if ( INFF_Delay = DELAY ) generate

    U_Addr_CS_In : IBUF
      port map
      (
        I => Pads(83),
        O => User_In.Addr_CS_In_n
      );

    U_Low_CS_In : IBUF
      port map
      (
        I => Pads(84),
        O => User_In.Low_CS_In_n
      );

    U_High_CS_In : IBUF
      port map
      (
        I => Pads(85),
        O => User_In.High_CS_In_n
      );

    U_WE_In : IBUF
      port map
      (
        I => Pads(86),
        O => User_In.WE_In_n
      );

  end generate G_Delay;

  G_Nodelay : if ( INFF_Delay = NODELAY ) generate
    attribute nodelay : string;
    attribute nodelay of U_Addr_CS_In : label is " ";
    attribute nodelay of U_Low_CS_In : label is " ";
    attribute nodelay of U_High_CS_In : label is " ";
    attribute nodelay of U_WE_In : label is " ";
  begin

    U_Addr_CS_In : IBUF
      port map
      (
        I => Pads(83),
        O => User_In.Addr_CS_In_n
      );

    U_Low_CS_In : IBUF
      port map
      (
        I => Pads(84),
        O => User_In.Low_CS_In_n
      );

    U_High_CS_In : IBUF
      port map
      (
        I => Pads(85),
        O => User_In.High_CS_In_n
      );

    U_WE_In : IBUF
      port map
      (
        I => Pads(86),
        O => User_In.WE_In_n
      );

  end generate G_Nodelay;

  G_Xbar_Mode : for I in 0 to 1 generate

    U_Xbar_Mode_Out : OBUFT_F_24 -- Always use OBUFT_F_24
      port map
      (
        O => Pads(I+87),
        I => User_Out.Xbar_Mode_Out(I),
        T => User_Out.Xbar_Mode_OE_n(I)
      );

    G_Delay : if ( INFF_Delay = DELAY ) generate
      U_Xbar_Mode_In : IBUF
        port map
        (
          I => Pads(I+87),
          O => User_In.Xbar_Mode_In(I)
        );
    end generate G_Delay;

    G_Nodelay : if ( INFF_Delay = NODELAY ) generate
      attribute nodelay : string;
      attribute nodelay of U_Xbar_Mode_In : label is " ";
    begin
      U_Xbar_Mode_In : IBUF
        port map
        (
          I => Pads(I+87),
          O => User_In.Xbar_Mode_In(I)
        );
    end generate G_Nodelay;

  end generate;

end Standard;

