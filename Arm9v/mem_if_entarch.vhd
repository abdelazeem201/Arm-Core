------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Mem_Std_IF
--
--  Architecture  : Standard
--
--  Filename      : mem_if_entarch.vhd
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
--  User_Out.Addr           20     I    Address bus
--  User_In.Data_In         36     O    Input data bus
--  User_Out.Data_Out       36     I    Output data bus
--  User_In.Data_Valid_n     1     O    Valid input data flag
--  User_Out.Strobe_n        1     I    Memory cycle strobe
--  User_Out.Write_Sel_n     1     I    Write cycle select
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity Mem_Std_IF is
  generic
  (
    INFF_Delay    : INTEGER := NODELAY;
    OBUF_Drive    : INTEGER := SLOW_12mA
  );
  port
  (
    M_Clk         : in    std_logic;
    Global_Reset  : in    std_logic;
    Pads          : inout Mem_Pads_Type;
    User_In       :   out Mem_Std_IF_In_Type;
    User_Out      : in    Mem_Std_IF_Out_Type
  );
end Mem_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Standard of Mem_Std_IF is

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
  --  Signal Name               Description
  --  ========================  ========================================
  --  Mem_Out.Addr                  Address bus
  --  Mem_In.Data_In               Input data bus
  --  Mem_Out.Data_Out              Output data bus
  --  Mem_Out.Data_OE_n             Output enables data bus
  --  Mem_Out.Addr_CS_n             Address chip select (extra address line)
  --  Mem_Out.CS_n                  Chip select
  --  Mem_Out.WE_n                  Write enable
  --  Data_Out_d_n              Data output delayed one cycle
  --  Data_Out_dd_n             Data output delayed two cycles
  --  Data_OE_d_n               Data output enable delayed one cycle
  --  Data_OE_dd_n              Data output enable delayed two cycles
  --  Valid_Read_d_n            Valid_Read signal delayed one cycle
  --  Valid_Read_dd_n           Valid_Read signal delayed two cycles
  --  Valid_Read_ddd_n          Valid_Read signal delayed three cycles
  --
  ----------------------------------------------------------------------

  signal Mem_In : Mem_Basic_IO_In_Type;
  signal Mem_Out : Mem_Basic_IO_Out_Type;
  signal Addr_Out : std_logic_vector ( 18 downto 0 );
  signal Addr_CS_Out_n : std_logic;
  signal Data_Out_d : std_logic_vector ( 31 downto 0 );
  signal Data_Out_dd : std_logic_vector ( 31 downto 0 );
  signal Data_OE_d_n : std_logic;
  signal Data_OE_dd_n : std_logic;
  signal Valid_Read_d_n : std_logic;
  signal Valid_Read_dd_n : std_logic;
  signal Valid_Read_ddd_n : std_logic;

begin

  Init_Mem_Basic_IO ( Mem_In );
  Init_Mem_Std_IF ( User_In );

  U_Basic_IO : Mem_Basic_IO
    generic map
    (
      INFF_Delay => INFF_Delay,
      OBUF_Drive => OBUF_Drive
    )
    port map
    (
      Pads      => Pads,
      User_In   => Mem_In,
      User_Out  => Mem_Out
    );

  P_REG : process 
    ( 
      Global_Reset, 
      M_Clk 
    )
  begin

    if ( Global_Reset = '1' ) then

      Data_Out_d <= ( others => '0' );
      Data_Out_dd <= ( others => '0' );
      Data_OE_d_n <= '1';
      Data_OE_dd_n <= '1';

      Valid_Read_d_n <= '1';
      Valid_Read_dd_n <= '1';
      Valid_Read_ddd_n <= '1';
      User_In.Data_Valid_n <= '1';

    elsif ( rising_edge ( M_Clk ) ) then

      Data_Out_d <= To_X01 ( User_Out.Data_Out );
      Data_Out_dd <= To_X01 ( Data_Out_d );
      Data_OE_d_n <= To_X01 ( User_Out.Strobe_n or User_Out.Write_Sel_n );
      Data_OE_dd_n <= Data_OE_d_n;

      Valid_Read_d_n <= User_Out.Strobe_n or ( not User_Out.Write_Sel_n );
      Valid_Read_dd_n <= Valid_Read_d_n;
      Valid_Read_ddd_n <= Valid_Read_dd_n;
      User_In.Data_Valid_n <= Valid_Read_ddd_n;

    end if;

  end process P_REG;

  Addr_Out <= User_Out.Addr(19 downto 17) & User_Out.Addr(15 downto 0);
  Addr_CS_Out_n <= User_Out.Addr(16);

  G_Addr : for I in Mem_Out.Addr'range generate
    U_Addr : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Addr_Out(I),
        Q   => Mem_Out.Addr(I)
      );
  end generate G_Addr;

  G_Data : for I in Mem_In.Data_In'range generate
    U_Data_In : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Mem_In.Data_In(I),
        Q   => User_In.Data_In(I)
      );
    U_Data_Out : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Data_Out_dd(I),
        Q   => Mem_Out.Data_Out(I)
      );
    U_Data_OE : IOB_FDP
      port map
      (
        C   => M_Clk,
        PRE => Global_Reset,
        D   => Data_OE_dd_n,
        Q   => Mem_Out.Data_OE_n(I)
      );
  end generate G_Data;

  U_Addr_CS : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Addr_CS_Out_n,
      Q   => Mem_Out.Addr_CS_n
    );

  U_CS : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => User_Out.Strobe_n,
      Q   => Mem_Out.CS_n
    );

  U_WE : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => User_Out.Write_Sel_n,
      Q   => Mem_Out.WE_n
    );

end Standard;

