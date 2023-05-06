------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : LAD_Bus_Std_IF
--
--  Architecture  : Standard
--
--  Filename      : lad_bus_if_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models the standard synchronous user 
--                  interface to the PEX LAD-bus pads.
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
--  ====================  ======  ===   ================================
--  K_Clk                    1     I    LAD-bus clock
--  Global_Reset             1     I    Asynchronous global PE reset
--  Pads.Addr_Data          32     B    Address/data bus pads
--  Pads.DS_n                1     I    Data strobe input pad
--  Pads.Reg_n               1     I    Register select input pad
--  Pads.WR_n                1     I    Read/Write select input pad
--  Pads.CS_n                1     I    Chip-select input pad
--  Pads.Int_Req_n           1     O    Interrupt request output pad
--  Pads.DMA_Chan            2     I    DMA channel number indicator
--  Pads.DMA_Stat            2     O    DMA channel status flags
--  User_In.Addr            23     O    Address bus input
--  User_In.Data_In         32     O    Data bus input
--  User_In.Reg_Strobe_n     1     O    Register access strobe
--  User_In.Mem_Strobe_n     1     O    Memory access strobe
--  User_In.Write_Sel_n      1     O    Write select
--  User_In.DMA_Chan         2     O    DMA channel number indicator
--  User_Out.Data_Out       32     I    Data bus output
--  User_Out.Int_Req_n       1     I    Interrupt request
--  User_Out.DMA_Stat        2     I    DMA channel status flags
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity LAD_Bus_Std_IF is
  port
  (
    K_Clk         : in    std_logic;
    Global_Reset  : in    std_logic;
    Pads          : inout LAD_Bus_Pads_Type;
    User_In       :   out LAD_Bus_Std_IF_In_Type;
    User_Out      : in    LAD_Bus_Std_IF_Out_Type
  );
end LAD_Bus_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Standard of LAD_Bus_Std_IF is

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
  --  Signal Name                   Description
  --  ============================  ====================================
  --  LAD_Bus_In.Addr_Data_In       Incoming address/data
  --  LAD_Bus_In.DS_n               Data strobe
  --  LAD_Bus_In.Reg_n              Register select
  --  LAD_Bus_In.WR_n               Read/Write strobe
  --  LAD_Bus_In.CS_n               Chip-select
  --  LAD_Bus_In.DMA_Chan           DMA channel number indicator
  --  LAD_Bus_Out.Addr_Data_Out     Outgoing data
  --  LAD_Bus_Out.Addr_Data_OE_n    Individual 3-state control
  --  LAD_Bus_Out.Int_Req_n         Interrupt request
  --  LAD_Bus_Out.DMA_Stat          DMA channel status flags
  --  Addr_Data_In                  Incoming LAD address/data input
  --  Addr_Data_OE_n                Outgoing LAD data output enable
  --  DS_n                          Incoming LAD data strobe
  --  Reg_n                         Incoming LAD register select
  --  WR_n                          Incoming LAD read/Write strobe
  --  CS_n                          Incoming LAD chip-select
  --  CS_d_n                        Registered incoming LAD chip-select
  --  Int_Req_d_n                   Registered user LAD interrupt req
  --  Int_Req_Pulse_n               Outgoing LAD interrupt req pulse
  --
  ----------------------------------------------------------------------

  signal LAD_Bus_In : LAD_Bus_Basic_IO_In_Type;
  signal LAD_Bus_Out : LAD_Bus_Basic_IO_Out_Type;
  signal Addr_Counter : std_logic_vector ( 22 downto 0 );
  signal Addr_Data_In : std_logic_vector ( 31 downto 0 );
  signal Addr_Data_OE_PRE : std_logic_vector ( 31 downto 0 );
  signal Addr_Data_OE_n : std_logic_vector ( 31 downto 0 );
  signal DS_n : std_logic;
  signal Reg_n : std_logic;
  signal WR_n : std_logic;
  signal CS_n : std_logic;
  signal CS_d_n : std_logic;
  signal Int_Req_d_n : std_logic;
  signal Int_Req_Pulse_n : std_logic;

begin

  Init_LAD_Bus_Basic_IO ( LAD_Bus_In );
  Init_LAD_Bus_Std_IF ( User_In );

  User_In.Addr <= Addr_Data_In ( 24 downto 2 ) when ( CS_d_n = '1' ) 
                  else Addr_Counter;
  User_In.Data_In <= Addr_Data_In;
  User_In.Reg_Strobe_n <= Reg_n when ( ( ( WR_n = '1' ) and ( CS_n = '0' ) ) or
                                       ( ( WR_n = '0' ) and ( CS_n = '0' ) and ( DS_n = '0' ) ) )
                          else '1';
  User_In.Mem_Strobe_n <= not Reg_n when ( ( ( WR_n = '1' ) and ( CS_n = '0' ) ) or
                                           ( ( WR_n = '0' ) and ( CS_n = '0' ) and ( DS_n = '0' ) ) )
                          else '1';
  User_In.Write_Sel_n <= WR_n;

  ----------------------------------------------------------------------
  --
  --  Input and output IOB buffers
  --
  ----------------------------------------------------------------------
  U_Basic_IO : LAD_Bus_Basic_IO
    port map
    (
      Pads      => Pads,
      User_In   => LAD_Bus_In,
      User_Out  => LAD_Bus_Out
    );

  ----------------------------------------------------------------------
  --
  --  Input IOB registers
  --
  ----------------------------------------------------------------------
  G_Addr_Data_In : for I in LAD_Bus_In.Addr_Data_In'range generate
    U_Addr_Data_In : IOB_FDC
      port map
      (
        C   => K_Clk,
        CLR => Global_Reset,
        D   => LAD_Bus_In.Addr_Data_In(I),
        Q   => Addr_Data_In(I)
      );
  end generate G_Addr_Data_In;

  U_DS : IOB_FDP
    port map
    (
      C   => K_Clk,
      PRE => Global_Reset,
      D   => LAD_Bus_In.DS_n,
      Q   => DS_n
    );

  U_Reg : IOB_FDP
    port map
    (
      C   => K_Clk,
      PRE => Global_Reset,
      D   => LAD_Bus_In.Reg_n,
      Q   => Reg_n
    );

  U_WR : IOB_FDP
    port map
    (
      C   => K_Clk,
      PRE => Global_Reset,
      D   => LAD_Bus_In.WR_n,
      Q   => WR_n
    );

  U_CS : IOB_FDP
    port map
    (
      C   => K_Clk,
      PRE => Global_Reset,
      D   => LAD_Bus_In.CS_n,
      Q   => CS_n
    );

  G_DMA_Chan : for I in LAD_Bus_In.DMA_Chan'range generate
    U_DMA_Chan : IOB_FDC
      port map
      (
        C   => K_Clk,
        CLR => Global_Reset,
        D   => LAD_Bus_In.DMA_Chan(I),
        Q   => User_In.DMA_Chan(I)
      );
  end generate G_DMA_Chan;

  ----------------------------------------------------------------------
  --
  --  Output IOB registers
  --
  ----------------------------------------------------------------------
  G_Data_Out : for I in LAD_Bus_Out.Addr_Data_Out'range generate
    U_Data_Out : IOB_FDC
      port map
      (
        C   => K_Clk,
        CLR => Global_Reset,
        D   => User_Out.Data_Out(I),
        Q   => LAD_Bus_Out.Addr_Data_Out(I)
      );
  end generate G_Data_Out;

  
  G_Addr_Data_OE : for I in LAD_Bus_Out.Addr_Data_OE_n'range generate
    Addr_Data_OE_PRE(I) <= Global_Reset;
    Addr_Data_OE_n(I) <= CS_d_n or ( not WR_n );
    U_Addr_Data_OE : IOB_FDP
      port map
      (
        C   => K_Clk,
        PRE => Addr_Data_OE_PRE(I),
        D   => Addr_Data_OE_n(I),
        Q   => LAD_Bus_Out.Addr_Data_OE_n(I)
      );
  end generate G_Addr_Data_OE;

  U_Int_Req : IOB_FDP
    port map
    (
      C   => K_Clk,
      PRE => Global_Reset,
      D   => Int_Req_Pulse_n,
      Q   => LAD_Bus_Out.Int_Req_n
    );

  G_DMA_Stat : for I in LAD_Bus_Out.DMA_Stat'range generate
    U_DMA_Stat : IOB_FDC
      port map
      (
        C   => K_Clk,
        CLR => Global_Reset,
        D   => User_Out.DMA_Stat(I),
        Q   => LAD_Bus_Out.DMA_Stat(I)
      );
  end generate G_DMA_Stat;

  ----------------------------------------------------------------------
  --
  --  Standard Interface Logic
  --
  ----------------------------------------------------------------------
  P_Std_IF : process 
    ( 
      Global_Reset,
      K_Clk
    )
  begin
    if ( Global_Reset = '1' ) then

      CS_d_n <= '1';
      Int_Req_d_n <= '1';
      Int_Req_Pulse_n <= '1';
      Addr_Counter <= ( others => '0' );

    elsif ( rising_edge ( K_Clk ) ) then

      CS_d_n <= CS_n;
      Int_Req_d_n <= User_Out.Int_Req_n;

      if ( ( User_Out.Int_Req_n = '0' ) and 
           ( Int_Req_d_n = '1' ) ) then
        Int_Req_Pulse_n <= '0';
      else
        Int_Req_Pulse_n <= '1';
      end if;

      if ( WR_n = '0' ) then
        if ( ( CS_n = '0' ) and ( CS_d_n = '1' ) ) then
          Addr_Counter <= Addr_Data_In ( 24 downto 2 );
        else
          if ( ( CS_n = '0' ) and ( DS_n = '0' ) ) then
            Addr_Counter <= Addr_Counter + 1;
          end if;
        end if;
      else
        if ( ( CS_n = '0' ) and ( CS_d_n = '1' ) ) then
          Addr_Counter <= Addr_Data_In ( 24 downto 2 ) + 1;
        else
          if ( CS_n = '0' ) then
            Addr_Counter <= Addr_Counter + 1;
          end if;
        end if;
      end if;

    end if;
  end process P_Std_IF;

end Standard;

