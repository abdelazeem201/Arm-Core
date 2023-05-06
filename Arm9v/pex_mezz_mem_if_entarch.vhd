------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Mezz_Mem_Std_IF
--
--  Architecture  : Standard
--
--  Filename      : pex_mezz_mem_if_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models the basic I/O components that provide an
--                  interface between PEX and a mezzanine memory card.
--                  The standard interface takes care of registering
--                  data immediately before and after the pads in
--                  order to ensure good timing.  It also delays the
--                  data output as necessary, so that the user may
--                  present both address and data to the interface
--                  on the same clock cycle when performing a write.
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
--  M_Clk                    1     I    Memory clock
--  Global_Reset             1     I    Global reset signal
--  Pads(18 downto 0)       19     B    Address pads
--  Pads(82 downto 19)      64     B    Data pads
--  Pads(83)                 1     B    Address chip select pad
--  Pads(84)                 1     B    Low Dword chip select pad
--  Pads(85)                 1     B    Hi Dword chip select pad
--  Pads(86)                 1     B    Write enable pad
--  Pads(88 downto 87)       2     B    Crossbar mode pads
--  User_In.Data_In         64     O    Data input
--  User_In.Data_Valid_n     1     O    Data input valid flag
--  User_In.Xbar_Mode_In     2     O    Crossbar mode input
--  User_In.Shunt_In        54     O    Shunt input
--  User_Out.Addr           20     I    Address output
--  User_Out.Data_Out       64     I    Data output
--  User_Out.Low_Strobe_n    1     I    Low Dword chip select output
--  User_Out.High_Strobe_n   1     I    Hi Dword chip select output
--  User_Out.Write_Sel_n     1     I    Write enable output
--  User_Out.Xbar_Mode_Out   2     I    Crossbar mode output
--  User_Out.Xbar_Mode_OE_n  1     I    Crossbar mode output enable
--  User_Out.Shunt_Out      54     I    Shunt output
--  User_Out.Shunt_OE_n     54     I    Shunt output enable
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use PEX_Lib.PE_Mezz_Mem_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity Mezz_Mem_Std_IF is
  generic
  (
    INFF_Delay    : INTEGER := NODELAY;
    OBUF_Drive    : INTEGER := SLOW_12mA
  );
  port
  (
    M_Clk         : in    std_logic;
    Global_Reset  : in    std_logic;
    Pads          : inout std_logic_vector ( 88 downto 0 );
    User_In       :   out Mezz_Mem_Std_IF_In_Type;
    User_Out      : in    Mezz_Mem_Std_IF_Out_Type
  );
end Mezz_Mem_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Standard of Mezz_Mem_Std_IF is

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
  --  Data_Out_d                Output data delayed 1 cycle
  --  Data_Out_dd               Output data delayed 2 cycles
  --  Write_d                   Write strobe delayed 1 cycle
  --  Write_dd                  Write strobe delayed 2 cycles
  --  Mem_User_In               Memory basic I/O input (user side)
  --  Mem_User_Out              Memory basic I/O output (user side)
  --  Mem_IO_In                 Memory basic I/O input (I/O side)
  --  Mem_IO_Out                Memory basic I/O output (I/O side)
  --  Shunt                     Shunt data path
  --  Shunt_d                   Shunt data path delayed 1 cycle
  --  Shunt_dd                  Shunt data path delayed 2 cycles
  --  Low_Valid                 Valid low in data flag
  --  Low_Valid_d               Valid low in data flag delayed 1 cycle
  --  Low_Valid_dd              Valid low in data flag delayed 2 cycles
  --  Low_Valid_ddd             Valid low in data flag delayed 3 cycles
  --  High_Valid                Valid high in data flag
  --  High_Valid_d              Valid high in data flag delayed 1 cycle
  --  High_Valid_dd             Valid high in data flag delayed 2 cycles
  --  High_Valid_ddd            Valid high in data flag delayed 3 cycles
  --
  ----------------------------------------------------------------------

  attribute syn_preserve : boolean;
  signal Data_Out_d : std_logic_vector ( 63 downto 0 );
  signal Data_Out_dd : std_logic_vector ( 63 downto 0 );
  signal Write_d : std_logic;
  signal Write_dd : std_logic_vector(3 downto 0);
  attribute syn_preserve of Write_dd : signal is TRUE;
  signal Mem_User_In : Mezz_Mem_Basic_IO_In_Type;
  signal Mem_User_Out : Mezz_Mem_Basic_IO_Out_Type;
  signal Mem_IO_In : Mezz_Mem_Basic_IO_In_Type;
  signal Mem_IO_Out : Mezz_Mem_Basic_IO_Out_Type;
  signal Shunt : std_logic;
  signal Shunt_d : std_logic;
  signal Shunt_dd : std_logic_vector(3 downto 0);
  attribute syn_preserve of Shunt_dd : signal is TRUE;
  signal Low_Valid : std_logic;
  signal Low_Valid_d : std_logic;
  signal Low_Valid_dd : std_logic;
  signal Low_Valid_ddd : std_logic;
  signal High_Valid : std_logic;
  signal High_Valid_d : std_logic;
  signal High_Valid_dd : std_logic;
  signal High_Valid_ddd : std_logic;

begin

  Pads <= ( others => 'Z' );
  Init_Mezz_Mem_Std_IF ( User_In );

  U_Basic_IO : Mezz_Mem_Basic_IO
    generic map
    (
      INFF_Delay => INFF_Delay,
      OBUF_Drive => OBUF_Drive
    )
    port map
    (
      Pads      => Pads,
      User_In   => Mem_IO_In,
      User_Out  => Mem_IO_Out
    );

  User_In.Data_In <= Mem_User_In.Data_In;
  User_In.Xbar_Mode_In <= Mem_User_In.Xbar_Mode_In;
  User_In.Shunt_In <= Mem_User_In.Data_In(31 downto 0)
                    & Mem_User_In.Addr_In(17 downto 0)
                    & Mem_User_In.Addr_CS_In_n 
                    & Mem_User_In.Low_CS_In_n 
                    & Mem_User_In.High_CS_In_n
                    & Mem_User_In.WE_In_n;
  User_In.Low_Valid_n <= not Low_Valid_ddd;
  User_In.High_Valid_n <= not High_Valid_ddd;

  Shunt <= Mem_User_In.Xbar_Mode_In(1);

  ----------------------------------------------------------------------
  --
  --  Register output data and write strobe for determining when to
  --  drive the data pins and the value to which to drive them.
  --
  ----------------------------------------------------------------------
  process 
    ( 
      Global_Reset, 
      M_Clk 
    )
  begin
    if ( Global_Reset = '1' ) then
      Data_Out_d <= ( others => '0' );
      Data_Out_dd <= ( others => '0' );
      Write_d <= '0';
      Write_dd <= ( others => '0' );
      Shunt_d <= '0';
      Shunt_dd <= ( others => '0' );
      Low_Valid <= '0';
      Low_Valid_d <= '0';
      Low_Valid_dd <= '0';
      Low_Valid_ddd <= '0';
      High_Valid <= '0';
      High_Valid_d <= '0';
      High_Valid_dd <= '0';
      High_Valid_ddd <= '0';
    elsif ( rising_edge ( M_Clk ) ) then
      Data_Out_d <= To_X01 ( User_Out.Data_Out );
      Data_Out_dd <= Data_Out_d;
      Write_d <= To_X01 ( ( not User_Out.Write_Sel_n ) and 
                          ( ( not User_Out.Low_Strobe_n ) or 
                            ( not User_Out.High_Strobe_n ) ) );
      Write_dd <= ( others => Write_d );
      Shunt_d <= Shunt;
      Shunt_dd <= ( others => Shunt_d );
      Low_Valid <= To_X01 ( User_Out.Write_Sel_n and 
                            ( not User_Out.Low_Strobe_n ) );
      Low_Valid_d <= Low_Valid;
      Low_Valid_dd <= Low_Valid_d;
      Low_Valid_ddd <= Low_Valid_dd;
      High_Valid <= To_X01 ( User_Out.Write_Sel_n and 
                             ( not User_Out.High_Strobe_n ) );
      High_Valid_d <= High_Valid;
      High_Valid_dd <= High_Valid_d;
      High_Valid_ddd <= High_Valid_dd;
    end if;
  end process;

  ----------------------------------------------------------------------
  --
  --  Memory outputs and tri-state controls come either from the normal
  --  memory-control signals (Shunt='0'), or from the vectorized
  --  bi-directional I/O lines, 'Shunt_Out' and 'Shunt_OE_n' (Shunt='1').
  --
  ----------------------------------------------------------------------
  process
    (
      User_Out,
      Shunt,
      Shunt_dd,
      Data_Out_dd,
      Write_dd
    )
    variable v_shunt_out : std_logic_vector ( 63 downto 0 );
    variable v_shunt_oe_n : std_logic_vector ( 63 downto 0 );
  begin

    if ( Shunt = '0' ) then
      Mem_User_Out.Addr_Out <= To_X01 ( User_Out.Addr(19 downto 17) & User_Out.Addr(15 downto 0) );
      Mem_User_Out.Addr_OE_n <= ( others => '0' );
      Mem_User_Out.Addr_CS_Out_n <= To_X01 ( User_Out.Addr(16) );
      Mem_User_Out.Addr_CS_OE_n <= '0';
      Mem_User_Out.Low_CS_Out_n <= To_X01 ( User_Out.Low_Strobe_n );
      Mem_User_Out.Low_CS_OE_n <= '0';
      Mem_User_Out.High_CS_Out_n <= To_X01 ( User_Out.High_Strobe_n );
      Mem_User_Out.High_CS_OE_n <= '0';
      Mem_User_Out.WE_Out_n <= To_X01 ( User_Out.Write_Sel_n );
      Mem_User_Out.WE_OE_n <= '0';
      Mem_User_Out.Xbar_Mode_Out <= User_Out.Xbar_Mode_Out;
      Mem_User_Out.Xbar_Mode_OE_n <= ( others => User_Out.Xbar_Mode_OE_n );
    else
      Mem_User_Out.Addr_Out <= "0" & To_X01 ( User_Out.Shunt_Out(21 downto 4) );
      Mem_User_Out.Addr_OE_n <= "1" & To_X01 ( User_Out.Shunt_OE_n(21 downto 4) );
      Mem_User_Out.Addr_CS_Out_n <= To_X01 ( User_Out.Shunt_Out(3) );
      Mem_User_Out.Addr_CS_OE_n <= To_X01 ( User_Out.Shunt_OE_n(3) );
      Mem_User_Out.Low_CS_Out_n <= To_X01 ( User_Out.Shunt_Out(2) );
      Mem_User_Out.Low_CS_OE_n <= To_X01 ( User_Out.Shunt_OE_n(2) );
      Mem_User_Out.High_CS_Out_n <= To_X01 ( User_Out.Shunt_Out(1) );
      Mem_User_Out.High_CS_OE_n <= To_X01 ( User_Out.Shunt_OE_n(1) );
      Mem_User_Out.WE_Out_n <= To_X01 ( User_Out.Shunt_Out(0) );
      Mem_User_Out.WE_OE_n <= To_X01 ( User_Out.Shunt_OE_n(0) );
      Mem_User_Out.Xbar_Mode_Out <= User_Out.Xbar_Mode_Out;
      Mem_User_Out.Xbar_Mode_OE_n <= ( others => User_Out.Xbar_Mode_OE_n );
    end if;

    v_shunt_out := x"00000000" & To_X01 ( User_Out.Shunt_Out(53 downto 22) );
    v_shunt_oe_n := x"FFFFFFFF" & To_X01 ( User_Out.Shunt_OE_n(53 downto 22) );
    for i in 0 to 3 loop
      if ( Shunt_dd(i) = '0' ) then
        Mem_User_Out.Data_Out((16*i)+15 downto i*16) <= Data_Out_dd((16*i)+15 downto i*16);
        Mem_User_Out.Data_OE_n((16*i)+15 downto i*16) <= 
		( (not Write_dd(i)) & (not Write_dd(i)) & (not Write_dd(i)) & (not Write_dd(i)) 
		& (not Write_dd(i)) & (not Write_dd(i)) & (not Write_dd(i)) & (not Write_dd(i)) 
		& (not Write_dd(i)) & (not Write_dd(i)) & (not Write_dd(i)) & (not Write_dd(i)) 
		& (not Write_dd(i)) & (not Write_dd(i)) & (not Write_dd(i)) & (not Write_dd(i)) );
      else
        Mem_User_Out.Data_Out((16*i)+15 downto i*16) <= v_shunt_out((16*i)+15 downto i*16);
        Mem_User_Out.Data_OE_n((16*i)+15 downto i*16) <= v_shunt_oe_n((16*i)+15 downto i*16);
      end if;
    end loop;

  end process;

  ----------------------------------------------------------------------
  --
  --  Register every signal in the IOBs:
  --
  --    All active high signals use IOB_FDC (async clear)
  --    All active low signals use IOB_FDP (async preset)
  --
  ----------------------------------------------------------------------
  G_Addr : for I in Mem_IO_Out.Addr_Out'range generate
    U_Addr_In : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Mem_IO_In.Addr_In(I),
        Q   => Mem_User_In.Addr_In(I)
      );
    U_Addr_Out : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Mem_User_Out.Addr_Out(I),
        Q   => Mem_IO_Out.Addr_Out(I)
      );
    U_Addr_OE : IOB_FDP
      port map
      (
        C   => M_Clk,
        PRE => Global_Reset,
        D   => Mem_User_Out.Addr_OE_n(I),
        Q   => Mem_IO_Out.Addr_OE_n(I)
      );
  end generate G_Addr;

  G_Data : for I in Mem_IO_Out.Data_Out'range generate
    U_Data_In : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Mem_IO_In.Data_In(I),
        Q   => Mem_User_In.Data_In(I)
      );
    U_Data_Out : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Mem_User_Out.Data_Out(I),
        Q   => Mem_IO_Out.Data_Out(I)
      );
    U_Data_OE : IOB_FDP
      port map
      (
        C   => M_Clk,
        PRE => Global_Reset,
        D   => Mem_User_Out.Data_OE_n(I),
        Q   => Mem_IO_Out.Data_OE_n(I)
      );
  end generate G_Data;

  G_Xbar_Mode : for I in Mem_IO_Out.Xbar_Mode_Out'range generate
    U_Xbar_Mode_In : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Mem_IO_In.Xbar_Mode_In(I),
        Q   => Mem_User_In.Xbar_Mode_In(I)
      );
    U_Xbar_Mode_Out : IOB_FDC
      port map
      (
        C   => M_Clk,
        CLR => Global_Reset,
        D   => Mem_User_Out.Xbar_Mode_Out(I),
        Q   => Mem_IO_Out.Xbar_Mode_Out(I)
      );
    U_Xbar_Mode_OE : IOB_FDP
      port map
      (
        C   => M_Clk,
        PRE => Global_Reset,
        D   => Mem_User_Out.Xbar_Mode_OE_n(I),
        Q   => Mem_IO_Out.Xbar_Mode_OE_n(I)
      );
  end generate G_Xbar_Mode;

  U_Addr_CS_In : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_IO_In.Addr_CS_In_n,
      Q   => Mem_User_In.Addr_CS_In_n
    );

  U_Low_CS_In : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_IO_In.Low_CS_In_n,
      Q   => Mem_User_In.Low_CS_In_n
    );

  U_High_CS_In : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_IO_In.High_CS_In_n,
      Q   => Mem_User_In.High_CS_In_n
    );

  U_WE_In : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_IO_In.WE_In_n,
      Q   => Mem_User_In.WE_In_n
    );

  U_Addr_CS_Out : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_User_Out.Addr_CS_Out_n,
      Q   => Mem_IO_Out.Addr_CS_Out_n
    );

  U_Addr_CS_OE : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_User_Out.Addr_CS_OE_n,
      Q   => Mem_IO_Out.Addr_CS_OE_n
    );

  U_Low_CS_Out : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_User_Out.Low_CS_Out_n,
      Q   => Mem_IO_Out.Low_CS_Out_n
    );

  U_Low_CS_OE : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_User_Out.Low_CS_OE_n,
      Q   => Mem_IO_Out.Low_CS_OE_n
    );

  U_High_CS_Out : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_User_Out.High_CS_Out_n,
      Q   => Mem_IO_Out.High_CS_Out_n
    );

  U_High_CS_OE : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_User_Out.High_CS_OE_n,
      Q   => Mem_IO_Out.High_CS_OE_n
    );

  U_WE_Out : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_User_Out.WE_Out_n,
      Q   => Mem_IO_Out.WE_Out_n
    );

  U_WE_OE : IOB_FDP
    port map
    (
      C   => M_Clk,
      PRE => Global_Reset,
      D   => Mem_User_Out.WE_OE_n,
      Q   => Mem_IO_Out.WE_OE_n
    );

end Standard;

