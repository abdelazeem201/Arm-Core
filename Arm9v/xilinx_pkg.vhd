------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Package       : Xilinx_Package
--
--  Library       : SYSTEM
--
--  Filename      : xilinx_pkg.vhd
--
--  Date          : 9/3/99
--
--  Description   : This is a package containing component declarations
--                  for Xilinx primitives and macros.  The attributes
--                  declared are specific to the Synplify VHDL 
--                  sunthesis tool, and are ignored by the VHDL 
--                  simulator.
--
--    The following components are included in this package:
--
--    BUF             : Buffer
--    BUFG            : Global Clock Buffer
--    BUFGDLL         : Clock Delay Locked Loop Buffer
--    CLKDLL          : Clock Delay Locked Loop
--    CLKDLLHF        : High Frequency Clock Delay Locked Loop
--    FD              : D Flip-Flop
--    FDC             : D Flip-Flop with Asynchronous Clear
--    FDC_1           : D Flip-Flop with Negative-Edge Clock and 
--                      Asynchronous Clear
--    FDCE            : D Flip-Flop with Clock Enable and 
--                      Asynchronous Clear
--    FDCE_1          : D Flip-Flop with Negative-Edge Clock, 
--                      Clock Enable, and Asynchronous Clear
--    FDP             : D Flip-Flop with Asynchronous Preset
--    FDP_1           : D Flip-Flop with Negative-Edge Clock and 
--                      Asynchronous Preset
--    FDPE            : D Flip-Flop with Clock Enable and 
--                      Asynchronous Preset
--    FDPE_1          : D Flip-Flop with Negative-Edge Clock, 
--                      Clock Enable, and Asynchronous Preset
--    FDR             : D Flip-Flop with Synchronous Reset
--    FDR_1           : D Flip-Flop with Negative-Edge Clock and 
--                      Synchronous Reset
--    FDRE            : D Flip-Flop with Clock Enable and 
--                      Synchronous Reset
--    FDRE_1          : D Flip-Flop with Negative-Edge Clock, 
--                      Clock Enable, and Synchronous Reset
--    FDS             : D Flip-Flop with Synchronous Set
--    FDS_1           : D Flip-Flop with Negative-Edge Clock and 
--                      Synchronous Set
--    FDSE            : D Flip-Flop with Clock Enable and 
--                      Synchronous Set
--    FDSE_1          : D Flip-Flop with Negative-Edge Clock, 
--                      Clock Enable, and Synchronous Set
--    IBUF            : Single Input Buffer (LVTTL)
--    IBUF_SSTL2_I    : Single Input Buffer (SSTL2_I)
--    IBUF_SSTL2_II   : Single Input Buffer (SSTL2_II)
--    IBUF_SSTL3_I    : Single Input Buffer (SSTL3_I)
--    IBUF_SSTL3_II   : Single Input Buffer (SSTL3_II)
--    IBUFG           : Dedicated Input Buffer (LVTTL)
--    IBUFG_SSTL2_I   : Dedicated Input Buffer (SSTL2_I)
--    IBUFG_SSTL2_II  : Dedicated Input Buffer (SSTL2_II)
--    IBUFG_SSTL3_I   : Dedicated Input Buffer (SSTL3_I)
--    IBUFG_SSTL3_II  : Dedicated Input Buffer (SSTL3_II)
--    IOB_FDC         : IOB D Flip-Flop with Asynchronous Clear
--    IOB_FDC_1       : IOB D Flip-Flop with Negative-Edge Clock and 
--                      Asynchronous Clear
--    IOB_FDCE        : IOB D Flip-Flop with Clock Enable and 
--                      Asynchronous Clear
--    IOB_FDCE_1      : IOB D Flip-Flop with Negative-Edge Clock, 
--                      Clock Enable, and Asynchronous Clear
--    IOB_FDP         : IOB D Flip-Flop with Asynchronous Preset
--    IOB_FDP_1       : IOB D Flip-Flop with Negative-Edge Clock and 
--                      Asynchronous Preset
--    IOB_FDPE        : IOB D Flip-Flop with Clock Enable and 
--                      Asynchronous Preset
--    IOB_FDPE_1      : IOB D Flip-Flop with Negative-Edge Clock, 
--                      Clock Enable, and Asynchronous Preset
--    IOB_FDR         : IOB D Flip-Flop with Synchronous Reset
--    IOB_FDR_1       : IOB D Flip-Flop with Negative-Edge Clock and 
--                      Synchronous Reset
--    IOB_FDRE        : IOB D Flip-Flop with Clock Enable and 
--                      Synchronous Reset
--    IOB_FDRE_1      : IOB D Flip-Flop with Negative-Edge Clock, 
--                      Clock Enable, and Synchronous Reset
--    IOB_FDS         : IOB D Flip-Flop with Synchronous Set
--    IOB_FDS_1       : IOB D Flip-Flop with Negative-Edge Clock and 
--                      Synchronous Set
--    IOB_FDSE        : IOB D Flip-Flop with Clock Enable and 
--                      Synchronous Set
--    IOB_FDSE_1      : IOB D Flip-Flop with Negative-Edge Clock, 
--                      Clock Enable, and Synchronous Set
--    MUXCY_L         : 2-to-1 Multiplexer for Carry Logic with 
--                      Local Output
--    OBUF            : Single Output Buffer (LVTTL)
--    OBUF_SSTL2_I    : Single Output Buffer (SSTL2_I)
--    OBUF_SSTL2_II   : Single Output Buffer (SSTL2_II)
--    OBUF_SSTL3_I    : Single Output Buffer (SSTL3_I)
--    OBUF_SSTL3_II   : Single Output Buffer (SSTL3_II)
--    OBUF_F_24       : Single Output Buffer (fast slew rate, 
--                      24 mA drive)
--    OBUF_S_24       : Single Output Buffer (slow slew rate, 
--                      24 mA drive)
--    OBUF_F_12       : Single Output Buffer (fast slew rate, 
--                      12 mA drive)
--    OBUF_S_12       : Single Output Buffer (slow slew rate, 
--                      12 mA drive)
--    OBUF_F_8        : Single Output Buffer (fast slew rate, 
--                      8 mA drive)
--    OBUF_S_8        : Single Output Buffer (slow slew rate, 
--                      8 mA drive)
--    OBUFT           : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (LVTTL)
--    OBUFT_SSTL2_I   : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (SSTL2_I)
--    OBUFT_SSTL2_II  : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (SSTL2_II)
--    OBUFT_SSTL3_I   : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (SSTL3_I)
--    OBUFT_SSTL3_II  : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (SSTL3_II)
--    OBUFT_F_24      : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (fast slew rate, 24 mA drive)
--    OBUFT_S_24      : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (slow slew rate, 24 mA drive)
--    OBUFT_F_12      : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (fast slew rate, 12 mA drive)
--    OBUFT_S_12      : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (slow slew rate, 12 mA drive)
--    OBUFT_F_8       : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (fast slew rate, 8 mA drive)
--    OBUFT_S_8       : Single 3-State Output Buffer with Active-Low 
--                      Output Enable (slow slew rate, 8 mA drive)
--    One_Shot        : Two-phase latch that generates a pulse 1 clock 
--                      cycle long when the input goes high.
--    PULLDOWN        : Resistor to GND for Input Pads
--    PULLUP          : Resistor to VCC for Input PADs, Open-Drain, 
--                      and 3-State Outputs
--    RAM32X1S        : 32-Deep by 1-Wide Static Synchronous RAM
--    RAMB_256x16_DP  : 256-Deep by 16-Wide Dual-Ported Block RAM
--    RAMB_256x32_DP  : 256-Deep by 32-Wide Dual-Ported Block RAM
--    STARTUP         : XC4000 user interface to global clock, reset, 
--                      and 3-state controls
--    STARTUP_VIRTEX  : Virtex User Interface to Global Clock, Reset, 
--                      and 3-State Controls
--    STARTUP_VIRTEX_ALL
--                    : Virtex User Interface to Global Clock, Reset, 
--                      and 3-State Controls
--    STARTUP_VIRTEX_GTS
--                    : Virtex User Interface to Global 3-State Controls
--    STARTUP_VIRTEX_GSR
--                    : Virtex User Interface to Global Reset
--    STARTUP_VIRTEX_CLK
--                    : Virtex User Interface to Global Clock
--
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


package Xilinx_Package is

  ----------------------- Attribute Declarations -----------------------

  --
  --  Synplicity supported attributes for Xilinx FPGAs
  --
  attribute xc_alias            : string;
  attribute black_box           : boolean;
  attribute black_box_pad_pin   : string;
  attribute black_box_tri_pins  : string;
  attribute syn_noprune         : boolean;

  -- attribute black_box of Xilinx_Package : package is true;

  ----------------------- Constant Declarations ------------------------
  constant tInDelay : time := 1 ns;
  constant tFastOutDelay : time := 1 ns;
  constant tSlowOutDelay : time := 2 ns;

  ----------------------- Component Declarations -----------------------

  component BUF
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute black_box of BUF : component is true;

  component BUFG
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute black_box of BUFG : component is true;

  component BUFGDLL
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of BUFGDLL : component is TRUE;
  attribute black_box of BUFGDLL : component is true;
  attribute black_box_pad_pin of BUFGDLL : component is "I";

  component CLKDLL is
    -- synopsys synthesis_off
    generic 
    (
      DUTY_CYCLE_CORRECTION : boolean := TRUE;
      CLKDV_DIVIDE : real := 2.0
    );
    -- synopsys synthesis_on
    port
    (
      CLKIN   : in    std_ulogic := '0';
      CLKFB   : in    std_ulogic := '0';
      RST     : in    std_ulogic := '0';
      CLK0    :   out std_ulogic := '0';
      CLK90   :   out std_ulogic := '0';
      CLK180  :   out std_ulogic := '0';
      CLK270  :   out std_ulogic := '0';
      CLK2X   :   out std_ulogic := '0';
      CLKDV   :   out std_ulogic := '0';
      LOCKED  :   out std_ulogic := '0'
    );
  end component;
  attribute black_box of CLKDLL : component is TRUE;

  component CLKDLLHF is
    -- synopsys synthesis_off
    generic
    (
      DUTY_CYCLE_CORRECTION : boolean := TRUE;
      CLKDV_DIVIDE : real := 2.0
    );
    -- synopsys synthesis_on
    port
    (
      CLKIN  : in  std_ulogic := '0';
      CLKFB  : in  std_ulogic := '0';
      RST    : in  std_ulogic := '0';
      CLK0   : out std_ulogic := '0';
      CLK180 : out std_ulogic := '0';
      CLKDV  : out std_ulogic := '0';
      LOCKED : out std_ulogic := '0'
    );
  end component;
  attribute black_box of CLKDLLHF : component is TRUE;

  component FD is
    port
    (
      C   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FD : component is TRUE;

  component FDC is
    port
    (
      C   : in    std_logic;
      CLR : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDC : component is TRUE;

  component FDC_1 is
    port
    (
      C   : in    std_logic;
      CLR : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDC_1 : component is TRUE;

  component FDCE is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      CLR : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDCE : component is TRUE;

  component FDCE_1 is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      CLR : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDCE_1 : component is TRUE;

  component FDP is
    port
    (
      C   : in    std_logic;
      PRE : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDP : component is TRUE;

  component FDP_1 is
    port
    (
      C   : in    std_logic;
      PRE : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDP_1 : component is TRUE;

  component FDPE is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      PRE : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDPE : component is TRUE;

  component FDPE_1 is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      PRE : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDPE_1 : component is TRUE;

  component FDR is
    port
    (
      C   : in    std_logic;
      R   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDR : component is TRUE;

  component FDR_1 is
    port
    (
      C   : in    std_logic;
      R   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDR_1 : component is TRUE;

  component FDRE is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      R   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDRE : component is TRUE;

  component FDRE_1 is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      R   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDRE_1 : component is TRUE;

  component FDS is
    port
    (
      C   : in    std_logic;
      S   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDS : component is TRUE;

  component FDS_1 is
    port
    (
      C   : in    std_logic;
      S   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDS_1 : component is TRUE;

  component FDSE is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      S   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDSE : component is TRUE;

  component FDSE_1 is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      S   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of FDSE_1 : component is TRUE;

  component IBUF
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUF : component is TRUE;
  attribute black_box of IBUF : component is true;
  attribute black_box_pad_pin of IBUF : component is "I";

  component IBUF_SSTL2_I
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUF_SSTL2_I : component is TRUE;
  attribute black_box of IBUF_SSTL2_I : component is true;
  attribute black_box_pad_pin of IBUF_SSTL2_I : component is "I";

  component IBUF_SSTL2_II
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUF_SSTL2_II : component is TRUE;
  attribute black_box of IBUF_SSTL2_II : component is true;
  attribute black_box_pad_pin of IBUF_SSTL2_II : component is "I";

  component IBUF_SSTL3_I
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUF_SSTL3_I : component is TRUE;
  attribute black_box of IBUF_SSTL3_I : component is true;
  attribute black_box_pad_pin of IBUF_SSTL3_I : component is "I";

  component IBUF_SSTL3_II
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUF_SSTL3_II : component is TRUE;
  attribute black_box of IBUF_SSTL3_II : component is true;
  attribute black_box_pad_pin of IBUF_SSTL3_II : component is "I";

  component IBUFG
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUFG : component is TRUE;
  attribute black_box of IBUFG : component is true;
  attribute black_box_pad_pin of IBUFG : component is "I";

  component IBUFG_SSTL2_I
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUFG_SSTL2_I : component is TRUE;
  attribute black_box of IBUFG_SSTL2_I : component is true;
  attribute black_box_pad_pin of IBUFG_SSTL2_I : component is "I";

  component IBUFG_SSTL2_II
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUFG_SSTL2_II : component is TRUE;
  attribute black_box of IBUFG_SSTL2_II : component is true;
  attribute black_box_pad_pin of IBUFG_SSTL2_II : component is "I";

  component IBUFG_SSTL3_I
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUFG_SSTL3_I : component is TRUE;
  attribute black_box of IBUFG_SSTL3_I : component is true;
  attribute black_box_pad_pin of IBUFG_SSTL3_I : component is "I";

  component IBUFG_SSTL3_II
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of IBUFG_SSTL3_II : component is TRUE;
  attribute black_box of IBUFG_SSTL3_II : component is true;
  attribute black_box_pad_pin of IBUFG_SSTL3_II : component is "I";

  component IOB_FDC is
    port
    (
      C   : in    std_logic;
      CLR : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDC : component is TRUE;

  component IOB_FDC_1 is
    port
    (
      C   : in    std_logic;
      CLR : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDC_1 : component is TRUE;

  component IOB_FDCE is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      CLR : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDCE : component is TRUE;

  component IOB_FDCE_1 is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      CLR : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDCE_1 : component is TRUE;

  component IOB_FDP is
    port
    (
      C   : in    std_logic;
      PRE : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDP : component is TRUE;

  component IOB_FDP_1 is
    port
    (
      C   : in    std_logic;
      PRE : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDP_1 : component is TRUE;

  component IOB_FDPE is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      PRE : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDPE : component is TRUE;

  component IOB_FDPE_1 is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      PRE : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDPE_1 : component is TRUE;

  component IOB_FDR is
    port
    (
      C   : in    std_logic;
      R   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDR : component is TRUE;

  component IOB_FDR_1 is
    port
    (
      C   : in    std_logic;
      R   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDR_1 : component is TRUE;

  component IOB_FDRE is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      R   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDRE : component is TRUE;

  component IOB_FDRE_1 is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      R   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDRE_1 : component is TRUE;

  component IOB_FDS is
    port
    (
      C   : in    std_logic;
      S   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDS : component is TRUE;

  component IOB_FDS_1 is
    port
    (
      C   : in    std_logic;
      S   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDS_1 : component is TRUE;

  component IOB_FDSE is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      S   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDSE : component is TRUE;

  component IOB_FDSE_1 is
    port
    (
      C   : in    std_logic;
      CE  : in    std_logic;
      S   : in    std_logic;
      D   : in    std_logic;
      Q   :   out std_logic
    );
  end component;
  attribute black_box of IOB_FDSE_1 : component is TRUE;

  component MUXCY_L
    port 
    (
      DI : in std_logic;
      CI : in std_logic;
      S  : in std_logic;
      LO : out std_logic
    );
  end component;
  attribute black_box of MUXCY_L : component is TRUE;

  component OBUF
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF : component is TRUE;
  attribute black_box of OBUF : component is true;
  attribute black_box_pad_pin of OBUF : component is "O";

  component OBUF_SSTL2_I
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_SSTL2_I : component is TRUE;
  attribute black_box of OBUF_SSTL2_I : component is true;
  attribute black_box_pad_pin of OBUF_SSTL2_I : component is "O";

  component OBUF_SSTL2_II
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_SSTL2_II : component is TRUE;
  attribute black_box of OBUF_SSTL2_II : component is true;
  attribute black_box_pad_pin of OBUF_SSTL2_II : component is "O";

  component OBUF_SSTL3_I
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_SSTL3_I : component is TRUE;
  attribute black_box of OBUF_SSTL3_I : component is true;
  attribute black_box_pad_pin of OBUF_SSTL3_I : component is "O";

  component OBUF_SSTL3_II
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_SSTL3_II : component is TRUE;
  attribute black_box of OBUF_SSTL3_II : component is true;
  attribute black_box_pad_pin of OBUF_SSTL3_II : component is "O";

  component OBUF_F_24
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_F_24 : component is TRUE;
  attribute black_box of OBUF_F_24 : component is true;
  attribute black_box_pad_pin of OBUF_F_24 : component is "O";

  component OBUF_S_24
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_S_24 : component is TRUE;
  attribute black_box of OBUF_S_24 : component is true;
  attribute black_box_pad_pin of OBUF_S_24 : component is "O";

  component OBUF_F_12
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_F_12 : component is TRUE;
  attribute black_box of OBUF_F_12 : component is true;
  attribute black_box_pad_pin of OBUF_F_12 : component is "O";

  component OBUF_S_12
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_S_12 : component is TRUE;
  attribute black_box of OBUF_S_12 : component is true;
  attribute black_box_pad_pin of OBUF_S_12 : component is "O";

  component OBUF_F_8
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_F_8 : component is TRUE;
  attribute black_box of OBUF_F_8 : component is true;
  attribute black_box_pad_pin of OBUF_F_8 : component is "O";

  component OBUF_S_8
    port
    (
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUF_S_8 : component is TRUE;
  attribute black_box of OBUF_S_8 : component is true;
  attribute black_box_pad_pin of OBUF_S_8 : component is "O";

  component OBUFT
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT : component is TRUE;
  attribute black_box of OBUFT : component is true;
  attribute black_box_pad_pin of OBUFT : component is "O";
  attribute black_box_tri_pins of OBUFT : component is "O";

  component OBUFT_SSTL2_I
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_SSTL2_I : component is TRUE;
  attribute black_box of OBUFT_SSTL2_I : component is true;
  attribute black_box_pad_pin of OBUFT_SSTL2_I : component is "O";
  attribute black_box_tri_pins of OBUFT_SSTL2_I : component is "O";

  component OBUFT_SSTL2_II
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_SSTL2_II : component is TRUE;
  attribute black_box of OBUFT_SSTL2_II : component is true;
  attribute black_box_pad_pin of OBUFT_SSTL2_II : component is "O";
  attribute black_box_tri_pins of OBUFT_SSTL2_II : component is "O";

  component OBUFT_SSTL3_I
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_SSTL3_I : component is TRUE;
  attribute black_box of OBUFT_SSTL3_I : component is true;
  attribute black_box_pad_pin of OBUFT_SSTL3_I : component is "O";
  attribute black_box_tri_pins of OBUFT_SSTL3_I : component is "O";

  component OBUFT_SSTL3_II
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_SSTL3_II : component is TRUE;
  attribute black_box of OBUFT_SSTL3_II : component is true;
  attribute black_box_pad_pin of OBUFT_SSTL3_II : component is "O";
  attribute black_box_tri_pins of OBUFT_SSTL3_II : component is "O";

  component OBUFT_F_24
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_F_24 : component is TRUE;
  attribute black_box of OBUFT_F_24 : component is true;
  attribute black_box_pad_pin of OBUFT_F_24 : component is "O";
  attribute black_box_tri_pins of OBUFT_F_24 : component is "O";

  component OBUFT_S_24
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_S_24 : component is TRUE;
  attribute black_box of OBUFT_S_24 : component is true;
  attribute black_box_pad_pin of OBUFT_S_24 : component is "O";
  attribute black_box_tri_pins of OBUFT_S_24 : component is "O";

  component OBUFT_F_12
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_F_12 : component is TRUE;
  attribute black_box of OBUFT_F_12 : component is true;
  attribute black_box_pad_pin of OBUFT_F_12 : component is "O";
  attribute black_box_tri_pins of OBUFT_F_12 : component is "O";

  component OBUFT_S_12
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_S_12 : component is TRUE;
  attribute black_box of OBUFT_S_12 : component is true;
  attribute black_box_pad_pin of OBUFT_S_12 : component is "O";
  attribute black_box_tri_pins of OBUFT_S_12 : component is "O";

  component OBUFT_F_8
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_F_8 : component is TRUE;
  attribute black_box of OBUFT_F_8 : component is true;
  attribute black_box_pad_pin of OBUFT_F_8 : component is "O";
  attribute black_box_tri_pins of OBUFT_F_8 : component is "O";

  component OBUFT_S_8
    port
    (
      T : in std_logic;
      I : in std_logic;
      O : out std_logic
    );
  end component;
  attribute syn_noprune  of OBUFT_S_8 : component is TRUE;
  attribute black_box of OBUFT_S_8 : component is true;
  attribute black_box_pad_pin of OBUFT_S_8 : component is "O";
  attribute black_box_tri_pins of OBUFT_S_8 : component is "O";

  component One_Shot
    port
    (
      Clk  : in std_logic;
      I   : in std_logic;
      O : out std_logic
    );
  end component;
  attribute black_box of One_Shot : component is true;

  component PULLDOWN
    port ( O : out std_logic );
  end component;
  attribute black_box of PULLDOWN : component is true;
  attribute black_box_pad_pin of PULLDOWN : component is "O";

  component PULLUP
    port ( O : out std_logic );
  end component;
  attribute black_box of PULLUP : component is true;
  attribute black_box_pad_pin of PULLUP : component is "O";

  component RAM32X1S
    port
    (
      O    : out std_logic;
      A0   : in std_logic;
      A1   : in std_logic;
      A2   : in std_logic;
      A3   : in std_logic;
      A4   : in std_logic;
      D    : in std_logic;
      WCLK : in std_logic;
      WE   : in std_logic
    );
  end component;
  attribute black_box of RAM32X1S : component is true;

  component RAMB_256x32_DP is
-- synopsys synthesis_off
---    generic
---    (
---      INIT_FILE_NAME : string := "RAMB_256x32_DP.mif"
---    );
-- synopsys synthesis_on
    port
    (
      addra : in    std_logic_vector(7 DOWNTO 0);
      addrb : in    std_logic_vector(7 DOWNTO 0);
      dia   : in    std_logic_vector(31 DOWNTO 0);
      dib   : in    std_logic_vector(31 DOWNTO 0);
      clka  : in    std_logic;
      clkb  : in    std_logic;
      wea   : in    std_logic;
      web   : in    std_logic;
      ena   : in    std_logic;
      enb   : in    std_logic;
      rsta  : in    std_logic;
      rstb  : in    std_logic;
      doa   :   out std_logic_vector(31 DOWNTO 0);
      dob   :   out std_logic_vector(31 DOWNTO 0)
    );
  end component;
  attribute black_box of RAMB_256x32_DP : component is true;
  
  component RAMB_256x16_DP is
-- synopsys synthesis_off
---    generic
---    (
---      INIT_FILE_NAME : string := "RAMB_256x16_DP.mif"
---    );
-- synopsys synthesis_on
    port
    (
      addra : in    std_logic_vector(7 DOWNTO 0);
      addrb : in    std_logic_vector(7 DOWNTO 0);
      dia   : in    std_logic_vector(15 DOWNTO 0);
      dib   : in    std_logic_vector(15 DOWNTO 0);
      clka  : in    std_logic;
      clkb  : in    std_logic;
      wea   : in    std_logic;
      web   : in    std_logic;
      ena   : in    std_logic;
      enb   : in    std_logic;
      rsta  : in    std_logic;
      rstb  : in    std_logic;
      doa   :   out std_logic_vector(15 DOWNTO 0);
      dob   :   out std_logic_vector(15 DOWNTO 0)
    );
  end component;
  attribute black_box of RAMB_256x16_DP : component is true;

  component STARTUP
    port (
      GSR : in std_logic;
      GTS : in std_logic;
      CLK : in std_logic
    );
  end component;
  attribute syn_noprune of STARTUP : component is true;
  attribute black_box of STARTUP : component is true;

  component STARTUP_VIRTEX
    port
    (
      GSR : in std_logic;
      GTS : in std_logic;
      CLK : in std_logic
    );
  end component;
  attribute syn_noprune of STARTUP_VIRTEX : component is true;
  attribute black_box of STARTUP_VIRTEX : component is true;

  component STARTUP_VIRTEX_ALL
    port
    (
      GSR : in std_logic;
      GTS : in std_logic;
      CLK : in std_logic
    );
  end component;
  attribute syn_noprune of STARTUP_VIRTEX_ALL : component is true;
  attribute black_box of STARTUP_VIRTEX_ALL : component is true;
  attribute xc_alias of STARTUP_VIRTEX_ALL: component is "STARTUP_VIRTEX";

  component STARTUP_VIRTEX_GTS
    port
    (
      GTS : in std_logic
    );
  end component;
  attribute syn_noprune of STARTUP_VIRTEX_GTS : component is true;
  attribute black_box of STARTUP_VIRTEX_GTS : component is true;
  attribute xc_alias of STARTUP_VIRTEX_GTS: component is "STARTUP_VIRTEX";

  component STARTUP_VIRTEX_GSR
    port
    (
      GSR : in std_logic
    );
  end component;
  attribute syn_noprune of STARTUP_VIRTEX_GSR : component is true;
  attribute black_box of STARTUP_VIRTEX_GSR : component is true;
  attribute xc_alias of STARTUP_VIRTEX_GSR: component is "STARTUP_VIRTEX";

  component STARTUP_VIRTEX_CLK
    port
    (
      CLK : in std_logic
    );
  end component;
  attribute syn_noprune of STARTUP_VIRTEX_CLK : component is true;
  attribute black_box of STARTUP_VIRTEX_CLK : component is true;
  attribute xc_alias of STARTUP_VIRTEX_CLK: component is "STARTUP_VIRTEX";

end Xilinx_Package;

