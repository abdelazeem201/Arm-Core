------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Clock_Std_IF
--
--  Architecture  : Standard
--
--  Filename      : clock_if_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models a standard interface to the clock resources
--                  of the PEX.
--  https://www.micro-semiconductor.sg/datasheet/07-PEX8311RDK.pdf
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
--  Generic Name                  Description
--  ============================  ======================================
--  M_CLK_DLL_TYPE                Type of CLKDLL to be used for M_Clk:
--                                NONE (below 25 MHz), LOW_FREQ (25 to
--                                90 MHz), or HIGH_FREQ (60 to 180 MHz).
--  P_CLK_DLL_TYPE                Type of CLKDLL to be used for P_Clk:
--                                NONE (below 25 MHz), LOW_FREQ (25 to
--                                90 MHz), or HIGH_FREQ (60 to 180 MHz).
--  U_CLK_DLL_TYPE                Type of CLKDLL to be used for U_Clk:
--                                NONE (below 25 MHz), LOW_FREQ (25 to
--                                90 MHz), or HIGH_FREQ (60 to 180 MHz).
--
--  Port Name                 Width  Dir  Description
--  ====================      =====  ===  ==============================
--  Pads.M_Clk                  1     I   Memory clock
--  Pads.P_Clk                  1     I   Processing element clock
--  Pads.K_Clk                  1     I   LAD-bus clock
--  Pads.U_Clk                  1     I   User clock
--  User_In.M_Clk               1     O   Memory clock
--  User_In.P_Clk               1     O   Processing element clock
--  User_In.K_Clk               1     O   LAD-bus clock
--  User_In.U_Clk               1     O   User clock
--  User_In.M_Clk_Locked        1     O   M_Clk CLKDLL locked flag
--  User_In.P_Clk_Locked        1     O   P_Clk CLKDLL locked flag
--  User_In.K_Clk_Locked        1     O   K_Clk CLKDLL locked flag
--  User_In.U_Clk_Locked        1     O   U_Clk CLKDLL locked flag
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

entity Clock_Std_IF is
  generic
  (
    M_CLK_DLL_TYPE  : INTEGER := LOW_FREQ;
    P_CLK_DLL_TYPE  : INTEGER := LOW_FREQ;
    U_CLK_DLL_TYPE  : INTEGER := LOW_FREQ
  );
  port
  (
    Pads    : inout Clock_Pads_Type;
    User_In :   out Clock_Std_IF_In_Type
  );
end Clock_Std_IF;
 
------------------------ Architecture Declaration ----------------------

architecture Standard of Clock_Std_IF is

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
  --  Clock_In.M_Clk                Memory clock
  --  Clock_In.P_Clk                Processing element clock
  --  Clock_In.K_Clk                LAD-bus clock
  --  Clock_In.U_Clk                User clock
  --  M_CLK_FB                      M_Clk CLKDLL feedback clock
  --  M_CLK_RST                     M_Clk CLKDLL reset signal
  --  M_CLK_0                       M_Clk CLKDLL 0 degree phase clock
  --  M_CLK_90                      M_Clk CLKDLL 90 degree phase clock
  --  M_CLK_180                     M_Clk CLKDLL 180 degree phase clock
  --  M_CLK_270                     M_Clk CLKDLL 270 degree phase clock
  --  M_CLK_2X                      M_Clk CLKDLL 2x clock
  --  M_CLK_DV                      M_Clk CLKDLL divided clock
  --  P_CLK_FB                      P_Clk CLKDLL feedback clock
  --  P_CLK_RST                     P_Clk CLKDLL reset signal
  --  P_CLK_0                       P_Clk CLKDLL 0 degree phase clock
  --  P_CLK_90                      P_Clk CLKDLL 90 degree phase clock
  --  P_CLK_180                     P_Clk CLKDLL 180 degree phase clock
  --  P_CLK_270                     P_Clk CLKDLL 270 degree phase clock
  --  P_CLK_2X                      P_Clk CLKDLL 2x clock
  --  P_CLK_DV                      P_Clk CLKDLL divided clock
  --  K_CLK_FB                      K_Clk CLKDLL feedback clock
  --  K_CLK_RST                     K_Clk CLKDLL reset signal
  --  K_CLK_0                       K_Clk CLKDLL 0 degree phase clock
  --  K_CLK_90                      K_Clk CLKDLL 90 degree phase clock
  --  K_CLK_180                     K_Clk CLKDLL 180 degree phase clock
  --  K_CLK_270                     K_Clk CLKDLL 270 degree phase clock
  --  K_CLK_2X                      K_Clk CLKDLL 2x clock
  --  K_CLK_DV                      K_Clk CLKDLL divided clock
  --  U_CLK_FB                      U_Clk CLKDLL feedback clock
  --  U_CLK_RST                     U_Clk CLKDLL reset signal
  --  U_CLK_0                       U_Clk CLKDLL 0 degree phase clock
  --  U_CLK_90                      U_Clk CLKDLL 90 degree phase clock
  --  U_CLK_180                     U_Clk CLKDLL 180 degree phase clock
  --  U_CLK_270                     U_Clk CLKDLL 270 degree phase clock
  --  U_CLK_2X                      U_Clk CLKDLL 2x clock
  --  U_CLK_DV                      U_Clk CLKDLL divided clock
  --
  --  Attribute Name                  Description
  --  ==============================  ==================================
  --  STARTUP_WAIT                    Component string attribute that
  --                                  when TRUE causes the DONE signal
  --                                  to be delayed during configuration 
  --                                  until the CLKDLL has gained a 
  --                                  lock.
  --  DUTY_CYCLE_CORRECTION           Component string attribute that
  --                                  when true causes the CLKDLL to
  --                                  correct the duty cycle of its
  --                                  output clock to be a 50% duty
  --                                  cycle.
  --  CLKDV_DIVIDE                    Component string attribute that
  --                                  indicates the amount the CLKDLL
  --                                  is to divide the CLKIN signal to
  --                                  produce the CLKDV signal.
  --
  ----------------------------------------------------------------------
  signal Clock_In : Clock_Basic_IO_In_Type;
  signal M_CLK_FB : std_logic;
  signal M_CLK_RST : std_logic;
  signal M_CLK_0 : std_logic;
  signal M_CLK_90 : std_logic;
  signal M_CLK_180 : std_logic;
  signal M_CLK_270 : std_logic;
  signal M_CLK_2X : std_logic;
  signal M_CLK_DV : std_logic;
  signal P_CLK_FB : std_logic;
  signal P_CLK_RST : std_logic;
  signal P_CLK_0 : std_logic;
  signal P_CLK_90 : std_logic;
  signal P_CLK_180 : std_logic;
  signal P_CLK_270 : std_logic;
  signal P_CLK_2X : std_logic;
  signal P_CLK_DV : std_logic;
  signal K_CLK_FB : std_logic;
  signal K_CLK_RST : std_logic;
  signal K_CLK_0 : std_logic;
  signal K_CLK_90 : std_logic;
  signal K_CLK_180 : std_logic;
  signal K_CLK_270 : std_logic;
  signal K_CLK_2X : std_logic;
  signal K_CLK_DV : std_logic;
  signal U_CLK_FB : std_logic;
  signal U_CLK_RST : std_logic;
  signal U_CLK_0 : std_logic;
  signal U_CLK_90 : std_logic;
  signal U_CLK_180 : std_logic;
  signal U_CLK_270 : std_logic;
  signal U_CLK_2X : std_logic;
  signal U_CLK_DV : std_logic;

  attribute STARTUP_WAIT : string;
  attribute DUTY_CYCLE_CORRECTION : string;
  attribute CLKDV_DIVIDE : string;

  attribute STARTUP_WAIT of U_K_CLK_DLL : label is "FALSE";
  attribute DUTY_CYCLE_CORRECTION of U_K_CLK_DLL : label is "FALSE";
  attribute CLKDV_DIVIDE of U_K_CLK_DLL : label is "2.0";

begin

  Init_Clock_Std_IF ( User_In );
  Init_Clock_Basic_IO ( Clock_In );

  M_CLK_RST <= '0';
  P_CLK_RST <= '0';
  K_CLK_RST <= '0';
  U_CLK_RST <= '0';

  User_In.M_Clk <= M_CLK_FB;
  User_In.P_Clk <= P_CLK_FB;
  User_In.K_Clk <= K_CLK_FB;
  User_In.U_Clk <= U_CLK_FB;

  U_Clock_Basic_IO : Clock_Basic_IO
    port map
    (
      Pads    => Pads,
      User_In => Clock_In
    );

  ----------------------------------------------------------------------
  --
  --  Clock Delay Locked Loops (CLKDLL)
  --
  ----------------------------------------------------------------------

  G_NO_M_DLL : if ( M_CLK_DLL_TYPE = NONE ) generate
    M_CLK_0 <= Clock_In.M_Clk;
    User_In.M_Clk_Locked <= '1';
  end generate G_NO_M_DLL;

  G_LF_M_DLL : if ( M_CLK_DLL_TYPE = LOW_FREQ ) generate
    attribute STARTUP_WAIT of U_M_CLK_DLL : label is "FALSE";
    attribute DUTY_CYCLE_CORRECTION of U_M_CLK_DLL : label is "FALSE";
    attribute CLKDV_DIVIDE of U_M_CLK_DLL : label is "2.0";
  begin
    U_M_CLK_DLL : CLKDLL
      -- synopsys synthesis_off
      generic map
      (
        DUTY_CYCLE_CORRECTION => FALSE,
        CLKDV_DIVIDE          => 2.0
      )
      -- synopsys synthesis_on
      port map
      (
        CLKIN   => Clock_In.M_Clk,
        CLKFB   => M_CLK_FB,
        RST     => M_CLK_RST,
        CLK0    => M_CLK_0,
        CLK90   => M_CLK_90,
        CLK180  => M_CLK_180,
        CLK270  => M_CLK_270,
        CLK2X   => M_CLK_2X,
        CLKDV   => M_CLK_DV,
        LOCKED  => User_In.M_Clk_Locked
      );
  end generate G_LF_M_DLL;

  G_HF_M_DLL : if ( M_CLK_DLL_TYPE = HIGH_FREQ ) generate
    attribute STARTUP_WAIT of U_M_CLK_DLL : label is "FALSE";
    attribute DUTY_CYCLE_CORRECTION of U_M_CLK_DLL : label is "FALSE";
    attribute CLKDV_DIVIDE of U_M_CLK_DLL : label is "2.0";
  begin
    U_M_CLK_DLL : CLKDLLHF
      -- synopsys synthesis_off
      generic map
      (
        DUTY_CYCLE_CORRECTION => FALSE,
        CLKDV_DIVIDE          => 2.0
      )
      -- synopsys synthesis_on
      port map
      (
        CLKIN   => Clock_In.M_Clk,
        CLKFB   => M_CLK_FB,
        RST     => M_CLK_RST,
        CLK0    => M_CLK_0,
        CLK180  => M_CLK_180,
        CLKDV   => M_CLK_DV,
        LOCKED  => User_In.M_Clk_Locked
      );
  end generate G_HF_M_DLL;

  G_NO_P_DLL : if ( P_CLK_DLL_TYPE = NONE ) generate
    P_CLK_0 <= Clock_In.P_Clk;
    User_In.P_Clk_Locked <= '1';
  end generate G_NO_P_DLL;

  G_LF_P_DLL : if ( P_CLK_DLL_TYPE = LOW_FREQ ) generate
    attribute STARTUP_WAIT of U_P_CLK_DLL : label is "FALSE";
    attribute DUTY_CYCLE_CORRECTION of U_P_CLK_DLL : label is "FALSE";
    attribute CLKDV_DIVIDE of U_P_CLK_DLL : label is "2.0";
  begin
    U_P_CLK_DLL : CLKDLL
      -- synopsys synthesis_off
      generic map
      (
        DUTY_CYCLE_CORRECTION => FALSE,
        CLKDV_DIVIDE          => 2.0
      )
      -- synopsys synthesis_on
      port map
      (
        CLKIN   => Clock_In.P_Clk,
        CLKFB   => P_CLK_FB,
        RST     => P_CLK_RST,
        CLK0    => P_CLK_0,
        CLK90   => P_CLK_90,
        CLK180  => P_CLK_180,
        CLK270  => P_CLK_270,
        CLK2X   => P_CLK_2X,
        CLKDV   => P_CLK_DV,
        LOCKED  => User_In.P_Clk_Locked
      );
  end generate G_LF_P_DLL;

  G_HF_P_DLL : if ( P_CLK_DLL_TYPE = HIGH_FREQ ) generate
    attribute STARTUP_WAIT of U_P_CLK_DLL : label is "FALSE";
    attribute DUTY_CYCLE_CORRECTION of U_P_CLK_DLL : label is "FALSE";
    attribute CLKDV_DIVIDE of U_P_CLK_DLL : label is "2.0";
  begin
    U_P_CLK_DLL : CLKDLLHF
      -- synopsys synthesis_off
      generic map
      (
        DUTY_CYCLE_CORRECTION => FALSE,
        CLKDV_DIVIDE          => 2.0
      )
      -- synopsys synthesis_on
      port map
      (
        CLKIN   => Clock_In.P_Clk,
        CLKFB   => P_CLK_FB,
        RST     => P_CLK_RST,
        CLK0    => P_CLK_0,
        CLK180  => P_CLK_180,
        CLKDV   => P_CLK_DV,
        LOCKED  => User_In.P_Clk_Locked
      );
  end generate G_HF_P_DLL;

  U_K_CLK_DLL : CLKDLL
    -- synopsys synthesis_off
    generic map
    (
      DUTY_CYCLE_CORRECTION => FALSE,
      CLKDV_DIVIDE          => 2.0
    )
    -- synopsys synthesis_on
    port map
    (
      CLKIN   => Clock_In.K_Clk,
      CLKFB   => K_CLK_FB,
      RST     => K_CLK_RST,
      CLK0    => K_CLK_0,
      CLK90   => K_CLK_90,
      CLK180  => K_CLK_180,
      CLK270  => K_CLK_270,
      CLK2X   => K_CLK_2X,
      CLKDV   => K_CLK_DV,
      LOCKED  => User_In.K_Clk_Locked
    );

  G_NO_U_DLL : if ( U_CLK_DLL_TYPE = NONE ) generate
    U_CLK_0 <= Clock_In.U_Clk;
    User_In.U_Clk_Locked <= '1';
  end generate G_NO_U_DLL;

  G_LF_U_DLL : if ( U_CLK_DLL_TYPE = LOW_FREQ ) generate
    attribute STARTUP_WAIT of U_U_CLK_DLL : label is "FALSE";
    attribute DUTY_CYCLE_CORRECTION of U_U_CLK_DLL : label is "FALSE";
    attribute CLKDV_DIVIDE of U_U_CLK_DLL : label is "2.0";
  begin
    U_U_CLK_DLL : CLKDLL
      -- synopsys synthesis_off
      generic map
      (
        DUTY_CYCLE_CORRECTION => FALSE,
        CLKDV_DIVIDE          => 2.0
      )
      -- synopsys synthesis_on
      port map
      (
        CLKIN   => Clock_In.U_Clk,
        CLKFB   => U_CLK_FB,
        RST     => U_CLK_RST,
        CLK0    => U_CLK_0,
        CLK90   => U_CLK_90,
        CLK180  => U_CLK_180,
        CLK270  => U_CLK_270,
        CLK2X   => U_CLK_2X,
        CLKDV   => U_CLK_DV,
        LOCKED  => User_In.U_Clk_Locked
      );
  end generate G_LF_U_DLL;

  G_HF_U_DLL : if ( U_CLK_DLL_TYPE = HIGH_FREQ ) generate
    attribute STARTUP_WAIT of U_U_CLK_DLL : label is "FALSE";
    attribute DUTY_CYCLE_CORRECTION of U_U_CLK_DLL : label is "FALSE";
    attribute CLKDV_DIVIDE of U_U_CLK_DLL : label is "2.0";
  begin
    U_U_CLK_DLL : CLKDLLHF
      -- synopsys synthesis_off
      generic map
      (
        DUTY_CYCLE_CORRECTION => FALSE,
        CLKDV_DIVIDE          => 2.0
      )
      -- synopsys synthesis_on
      port map
      (
        CLKIN   => Clock_In.U_Clk,
        CLKFB   => U_CLK_FB,
        RST     => U_CLK_RST,
        CLK0    => U_CLK_0,
        CLK180  => U_CLK_180,
        CLKDV   => U_CLK_DV,
        LOCKED  => User_In.U_Clk_Locked
      );
  end generate G_HF_U_DLL;

  ----------------------------------------------------------------------
  --
  --  Global clock buffers
  --
  ----------------------------------------------------------------------

  U_M_CLK : BUFG
    port map
    (
      I => M_CLK_0,
      O => M_CLK_FB
    );

  U_P_CLK : BUFG
    port map
    (
      I => P_CLK_0,
      O => P_CLK_FB
    );

  U_K_CLK : BUFG
    port map
    (
      I => K_CLK_0,
      O => K_CLK_FB
    );

  U_U_CLK : BUFG
    port map
    (
      I => U_CLK_0,
      O => U_CLK_FB
    );

end Standard;

