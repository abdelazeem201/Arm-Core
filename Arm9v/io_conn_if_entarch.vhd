------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : IO_Conn_Std_IF
--
--  Architecture  : Standard
--
--  Filename      : IO_Conn_if_entarch.vhd
--
--  Date          : 9/19/99
--
--  Description   : Models a standard user interface to the external I0
--                  card.
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
--  Pads                   66      B    Pad signals for the bus
--  User_In.Data_In        66      O    Input data from the pads
--  User_Out.Data_Out      66      I    Output data to the pads
--  User_Out.Data_OE_n     66      I    Individual tri-state controls
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity IO_Conn_Std_IF is
  generic
  (
    INFF_Delay    : INTEGER := NODELAY;
    OBUF_Drive    : INTEGER := FAST_8mA
  );
  port
  (
    Clk           : in    std_logic;
    Global_Reset  : in    std_logic;
    Pads_Top_Sys  : inout Systolic_Pads_Type;
    Pads_Bot_Sys  : inout Systolic_Pads_Type;
    Pads_PE0_Bus  : inout PE0_Bus_Pads_Type;
    User_In       :   out IO_Conn_Std_IF_In_Type;
    User_Out      : in    IO_Conn_Std_IF_Out_Type
  );
end IO_Conn_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Structure of IO_Conn_Std_IF is

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
  --  IO_Conn_In.Data_In        66    Input data from the pads
  --  IO_Conn_Out.Data_Out      66    Output data to the pads
  --  IO_Conn_Out.Data_OE_n     66    Individual tri-state controls
  --
  ----------------------------------------------------------------------

  signal Top_Sys_In : Systolic_Basic_IO_In_Type;
  signal Top_Sys_Out : Systolic_Basic_IO_Out_Type;
  signal Bot_Sys_In : Systolic_Basic_IO_In_Type;
  signal Bot_Sys_Out : Systolic_Basic_IO_Out_Type;
  signal PE0_Bus_In : PE0_Bus_Basic_IO_In_Type;
  signal PE0_Bus_Out : PE0_Bus_Basic_IO_Out_Type;

begin

  Init_Systolic_Basic_IO ( Top_Sys_In );
  Init_Systolic_Basic_IO ( Bot_Sys_In );
  Init_PE0_Bus_Basic_IO ( PE0_Bus_In );
  Init_IO_Conn_Std_IF ( User_In );

  U_TopSys_Basic_IO : Systolic_Basic_IO
    generic map
    (
      INFF_Delay => INFF_Delay,
      OBUF_Drive => OBUF_Drive
    )
    port map
    (
      Pads      => Pads_Top_Sys,
      User_In   => Top_Sys_In,
      User_Out  => Top_Sys_Out
    );

  U_BotSys_Basic_IO : Systolic_Basic_IO
    generic map
    (
      INFF_Delay => INFF_Delay,
      OBUF_Drive => OBUF_Drive
    )
    port map
    (
      Pads      => Pads_Bot_Sys,
      User_In   => Bot_Sys_In,
      User_Out  => Bot_Sys_Out
    );

  U_PE0Bus_Basic_IO : PE0_Bus_Basic_IO
    generic map
    (
      INFF_Delay => INFF_Delay,
      OBUF_Drive => OBUF_Drive
    )
    port map
    (
      Pads      => Pads_PE0_Bus,
      User_In   => PE0_Bus_In,
      User_Out  => PE0_Bus_Out
    );

  G_DataTop : for I in 31 downto 0 generate
    U_In : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => Top_Sys_In.Data_In(I),
        Q   => User_In.Data_In(I)
      );
    U_Out : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => User_Out.Data_Out(I),
        Q   => Top_Sys_Out.Data_Out(I)
      );
    U_OE : IOB_FDP
      port map
      (
        C   => Clk,
        PRE => Global_Reset,
        D   => User_Out.Data_OE_n(I),
        Q   => Top_Sys_Out.Data_OE_n(I)
      );
  end generate G_DataTop;

  G_DataPE0Bus : for I in 33 downto 32 generate
    U_In : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => PE0_Bus_In.Data_In(I-32),
        Q   => User_In.Data_In(I)
      );
    U_Out : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => User_Out.Data_Out(I),
        Q   => PE0_Bus_Out.Data_Out(I-32)
      );
    U_OE : IOB_FDP
      port map
      (
        C   => Clk,
        PRE => Global_Reset,
        D   => User_Out.Data_OE_n(I),
        Q   => PE0_Bus_Out.Data_OE_n(I-32)
      );
  end generate G_DataPE0Bus;

  G_DataBot : for I in 65 downto 34 generate
    U_In : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => Bot_Sys_In.Data_In(I-34),
        Q   => User_In.Data_In(I)
      );
    U_Out : IOB_FDC
      port map
      (
        C   => Clk,
        CLR => Global_Reset,
        D   => User_Out.Data_Out(I),
        Q   => Bot_Sys_Out.Data_Out(I-34)
      );
    U_OE : IOB_FDP
      port map
      (
        C   => Clk,
        PRE => Global_Reset,
        D   => User_Out.Data_OE_n(I),
        Q   => Bot_Sys_Out.Data_OE_n(I-34)
      );
  end generate G_DataBot;

end Structure;

