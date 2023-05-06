------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Package       : PE_Package
--
--  Library       : PEX_Lib
--
--  Filename      : pex_pkg.vhd
--
--  Date          : 9/3/99
--
--  Description   : Contains all record, procedure, and component
--                  declarations for basic I/O interfaces particular
--                  to PEX of WILDSTAR(tm) boards.
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE;
use IEEE.std_logic_1164.all;

--------------------------- Package Declaration ------------------------

package PE_Package is

  --
  --  Clock Delay Locked Loop (DLL) settings: none (below 25 MHz), 
  --  low frequency (25 to 90 MHz), or high frequency (60 to 180 MHz)
  --
--  type Clk_DLL_Type is ( NONE, LOW_FREQ, HIGH_FREQ );
  constant NONE : INTEGER := 0;
  constant LOW_FREQ : INTEGER := 1;
  constant HIGH_FREQ : INTEGER := 2;

  --
  --  Output buffer (OBUF) type can be of the following types:
  --  slow 12 mA, slow 8 mA, fast 12 mA, or fast 8 mA buffers.
  --
--  type OBUF_Drive_Type is ( SLOW_12mA, SLOW_8mA, FAST_12mA, FAST_8mA );
  constant SLOW_12mA : INTEGER := 0;
  constant SLOW_8mA : INTEGER := 1;
  constant FAST_12mA : INTEGER := 2;
  constant FAST_8mA : INTEGER := 3;
  --
  --  Input flip-flops (INFF) can either have their inputs
  --  directly from the input buffers or they can be delayed
  --  (normally no delay is needed if a DLL is used on the
  --  clock used to clock in the data, otherwise delay is used
  --  to compensate for clock skew).
  --  
--  type INFF_Delay_Type is ( NODELAY, DELAY );
  constant NODELAY : INTEGER := 0;
  constant DELAY : INTEGER := 1;

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Pads Types, Components, and Procedures
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------
  --
  --  Clock_Pads_Type
  --
  --  Name Key:
  --  =========
  --  _AS       : Address Strobe
  --  _CB       : CardBus
  --  _CE       : Clock Enable
  --  _CS       : Chip Select
  --  _DS       : Data Strobe
  --  _EN       : Enable
  --  _OE       : Output Enable
  --  _PE       : Processing Element
  --  _RD       : Read Select
  --  _WE       : Write Enable
  --  _WR       : Write Select
  --  _d[d...]  : Delayed (registered) signal (each 'd' denotes one 
  --              level of delay)
  --  _n        : Active low signals (must be last part of name)
  --
  --  Pad Name              Width  Description
  --  ====================  =====  =====================================
  --  M_Clk                   1    Memory clock
  --  P_Clk                   1    Processing element clock
  --  K_Clk                   1    LAD-bus clock
  --  U_Clk                   1    User clock
  --
  ----------------------------------------------------------------------
  type Clock_Pads_Type is record
    M_Clk               : std_logic;
    P_Clk               : std_logic;
    K_Clk               : std_logic;
    U_Clk               : std_logic;
  end record;

  procedure Init_Clock_Pads
    (
      signal Pads : out Clock_Pads_Type 
    );

  ----------------------------------------------------------------------
  --
  --  LAD_Bus_Pads_Type
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
  --  Name                  Width  Description
  --  ====================  =====  =====================================
  --  Addr_Data              32    Shared address/data bus
  --  DS_n                    1    Data strobe
  --  Reg_n                   1    Register mode select
  --  WR_n                    1    Write select
  --  CS_n                    1    PE chip select
  --  Int_Req_n               1    Interrupt request
  --  DMA_Chan                2    DMA channel number indicator
  --  DMA_Stat                2    DMA channel status flags
  --
  ----------------------------------------------------------------------
  type LAD_Bus_Pads_Type is record
    DS_n	  : std_logic;
    Addr_Data : std_logic_vector ( 31 downto 0 );
    Reg_n     : std_logic;
    WR_n      : std_logic;
    CS_n      : std_logic;
    Int_Req_n : std_logic;
    DMA_Chan  : std_logic_vector ( 1 downto 0 );
    DMA_Stat  : std_logic_vector ( 1 downto 0 );
  end record;

  procedure Init_LAD_Bus_Pads
    (
      signal Pads : out LAD_Bus_Pads_Type
    );

  ----------------------------------------------------------------------
  --
  --  LED_Pads_Type
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
  --  Name                  Width  Description
  --  ====================  =====  =====================================
  --  Red_n                   1    Red light emitting diode output pad
  --  Green_n                 1    Green light emitting diode output pad
  --
  ----------------------------------------------------------------------
  type LED_Pads_Type is record
    Red_n   : std_logic;
    Green_n : std_logic;
  end record;

  procedure Init_LED_Pads
    (
      signal Pads : out LED_Pads_Type
    );

  ----------------------------------------------------------------------
  --
  --  Mem_Pads_Type
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
  --  Name                  Width  Description
  --  ====================  =====  =====================================
  --  Addr                   19    Address bus pads
  --  Data                   32    Data bus pads
  --  Addr_CS_n               1    Address chip select (extra addr line)
  --  CS_n                    1    Chip select
  --  WE_n                    1    Write enable
  --
  ----------------------------------------------------------------------
  type Mem_Pads_Type is record
    Addr      : std_logic_vector ( 18 downto 0 );
    Data      : std_logic_vector ( 31 downto 0 );
    Addr_CS_n : std_logic;
    CS_n      : std_logic;
    WE_n      : std_logic;
  end record;

  procedure Init_Mem_Pads
    (
      signal Pads : out Mem_Pads_Type
    );

  ----------------------------------------------------------------------
  --
  --  Mezz_Conn_Pads_Type
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
  --  Name                  Width  Description
  --  ====================  =====  =====================================
  --  Left                   89    Left mezzanine connector pads
  --  Right                  89    Right mezzanine connector pads
  --
  ----------------------------------------------------------------------
  type Mezz_Conn_Pads_Type is record
    Left  : std_logic_vector ( 88 downto 0 );
    Right : std_logic_vector ( 88 downto 0 );
  end record;

  procedure Init_Mezz_Conn_Pads
    (
      signal Pads : out Mezz_Conn_Pads_Type
    );

  ----------------------------------------------------------------------
  --
  --  PE0_Bus_Pads_Type
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
  --  Name                  Width  Description
  --  ====================  =====  =====================================
  --  N/A                     2    PE0 bus pads
  --
  ----------------------------------------------------------------------
  subtype PE0_Bus_Pads_Type is std_logic_vector ( 1 downto 0 );

  procedure Init_PE0_Bus_Pads
    (
      signal Pads : out PE0_Bus_Pads_Type
    );

  ----------------------------------------------------------------------
  --
  --  Reset_Pads_Type
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
  --  Name                  Width  Description
  --  ====================  =====  =====================================
  --  N/A                     1    Reset pad
  --
  ----------------------------------------------------------------------
  subtype Reset_Pads_Type is std_logic;

  procedure Init_Reset_Pads
    (
      signal Pads : out Reset_Pads_Type
    );

  ----------------------------------------------------------------------
  --
  --  Systolic_Pads_Type
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
  --  Name                  Width  Description
  --  ====================  =====  =====================================
  --  N/A                    36    Systolic bus data pads
  --
  ----------------------------------------------------------------------
  subtype Systolic_Pads_Type is std_logic_vector ( 35 downto 0 );

  procedure Init_Systolic_Pads
    (
      signal Pads : out Systolic_Pads_Type
    );

  ----------------------------------------------------------------------
  --
  --  PEX_Pads_Type
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
  --  Name                  Description
  --  ====================  ============================================
  --  Clocks                Clock signal pads
  --  LAD_Bus               Local address/data bus signal pads
  --  Left_Mem              Left memory pads
  --  Right_Mem             Right memory pads
  --  Bot_Sys               Bottom systolic bus pads
  --  Top_Sys               Top systolic bus pads
  --  Mezz                  Mezzanine connector pads
  --  LEDs                  Light-emitting diode output pads
  --  PE0_Bus               PE0 bus pads
  --
  ----------------------------------------------------------------------
  type PEX_Pads_Type is record
    Clocks    : Clock_Pads_Type;
    Reset     : Reset_Pads_Type;
    LAD_Bus   : LAD_Bus_Pads_Type;
    Left_Mem  : Mem_Pads_Type;
    Right_Mem : Mem_Pads_Type;
    Top_Sys   : Systolic_Pads_Type;
    Bot_Sys   : Systolic_Pads_Type;
    Mezz      : Mezz_Conn_Pads_Type;
    LEDs      : LED_Pads_Type;
    PE0_Bus   : PE0_Bus_Pads_Type;
  end record;

  procedure Init_PEX_Pads
    (
      signal Pads : out PEX_Pads_Type
    );

  component PEX is
    generic
    (
      SYNTHESIS : boolean := TRUE
    );
    port
    (
      Pads : inout PEX_Pads_Type
    );
  end component;


  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Basic I/O Types, Components, and Procedures
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------
  --
  --  Clock_Basic_IO_Type
  --
  --  Name Key:
  --  =========
  --  _AS       : Address Strobe
  --  _CB       : CardBus
  --  _CE       : Clock Enable
  --  _CS       : Chip Select
  --  _DS       : Data Strobe
  --  _EN       : Enable
  --  _OE       : Output Enable
  --  _PE       : Processing Element
  --  _RD       : Read Select
  --  _WE       : Write Enable
  --  _WR       : Write Select
  --  _d[d...]  : Delayed (registered) signal (each 'd' denotes one 
  --              level of delay)
  --  _n        : Active low signals (must be last part of name)
  --
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  M_Clk                   1     I     Memory clock
  --  P_Clk                   1     I     Processing element clock
  --  K_Clk                   1     I     LAD-bus clock
  --  U_Clk                   1     I     User clock
  --  
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type Clock_Basic_IO_Type is record
    M_Clk : std_logic;
    P_Clk : std_logic;
    K_Clk : std_logic;
    U_Clk : std_logic;
  end record;

  type Clock_Basic_IO_In_Type is record
    M_Clk : std_logic;
    P_Clk : std_logic;
    K_Clk : std_logic;
    U_Clk : std_logic;
  end record;

  procedure Init_Clock_Basic_IO
    (
      signal User : out Clock_Basic_IO_Type
    );

  procedure Init_Clock_Basic_IO
    (
      signal User : out Clock_Basic_IO_In_Type
    );

  component Clock_Basic_IO is
    port
    (
      Pads      : inout Clock_Pads_Type;
      User_In   :   out Clock_Basic_IO_In_Type
    );
  end component;
  
  ----------------------------------------------------------------------
  --
  --  LAD_Bus_Basic_IO_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Addr_Data_In           32     I     Shared address/data bus input
  --  Addr_Data_Out          32     O     Shared address/data bus output
  --  Addr_Data_OE_n          1     O     Address/data bus output enable
  --  DS_n                    1     I     Data strobe
  --  Reg_n                   1     I     Register mode select
  --  WR_n                    1     I     Write select
  --  CS_n                    1     I     PE chip select
  --  Int_Req_n               1     O     Interrupt request
  --  DMA_Chan                2     I     DMA channel number indicator
  --  DMA_Stat                2     O     DMA channel status flags
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type LAD_Bus_Basic_IO_Type is record
    Addr_Data_In    : std_logic_vector ( 31 downto 0 );
    Addr_Data_Out   : std_logic_vector ( 31 downto 0 );
    Addr_Data_OE_n  : std_logic_vector ( 31 downto 0 );
    DS_n            : std_logic;
    Reg_n           : std_logic;
    WR_n            : std_logic;
    CS_n            : std_logic;
    Int_Req_n       : std_logic;
    DMA_Chan        : std_logic_vector ( 1 downto 0 );
    DMA_Stat        : std_logic_vector ( 1 downto 0 );
  end record;

  type LAD_Bus_Basic_IO_In_Type is record
    Addr_Data_In    : std_logic_vector ( 31 downto 0 );
    DS_n            : std_logic;
    Reg_n           : std_logic;
    WR_n            : std_logic;
    CS_n            : std_logic;
    DMA_Chan        : std_logic_vector ( 1 downto 0 );
  end record;

  type LAD_Bus_Basic_IO_Out_Type is record
    Addr_Data_Out   : std_logic_vector ( 31 downto 0 );
    Addr_Data_OE_n  : std_logic_vector ( 31 downto 0 );
    Int_Req_n       : std_logic;
    DMA_Stat        : std_logic_vector ( 1 downto 0 );
  end record;

  procedure Init_LAD_Bus_Basic_IO
    (
      signal User : out LAD_Bus_Basic_IO_Type
    );

  procedure Init_LAD_Bus_Basic_IO
    (
      signal User : out LAD_Bus_Basic_IO_In_Type
    );

  component LAD_Bus_Basic_IO is
    port
    (
      Pads      : inout LAD_Bus_Pads_Type;
      User_In   :   out LAD_Bus_Basic_IO_In_Type;
      User_Out  : in    LAD_Bus_Basic_IO_Out_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  LED_Basic_IO_Type
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
  --  Name                Width  Dir* Description
  --  ==================  =====  ==== ==================================
  --  Red_n                 1     O   Red light emitting diode output
  --  Green_n               1     O   Green light emitting diode output
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  --
  ----------------------------------------------------------------------
  type LED_Basic_IO_Type is record
    Red_n   : std_logic;
    Green_n : std_logic;
  end record;

  type LED_Basic_IO_Out_Type is record
    Red_n   : std_logic;
    Green_n : std_logic;
  end record;

  procedure Init_LED_Basic_IO
    (
      signal User : out LED_Basic_IO_Type
    );

  component LED_Basic_IO is
    port
    (
      Pads      : inout LED_Pads_Type;
      User_Out  : in    LED_Basic_IO_Out_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  Mem_Basic_IO_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Addr                   19     O     Address bus output
  --  Data_In                32     I     Data bus input
  --  Data_Out               32     O     Data bus output
  --  Data_OE_n              32     O     Data bus output enable
  --  Addr_CS_n               1     O     Address chip select (extra
  --                                      addr line)
  --  CS_n                    1     O     Chip select
  --  WE_n                    1     O     Write enable
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type Mem_Basic_IO_Type is record
    Addr      : std_logic_vector ( 18 downto 0 );
    Data_In   : std_logic_vector ( 31 downto 0 );
    Data_Out  : std_logic_vector ( 31 downto 0 );
    Data_OE_n : std_logic_vector ( 31 downto 0 );
    Addr_CS_n : std_logic;
    CS_n      : std_logic;
    WE_n      : std_logic;
  end record;

  type Mem_Basic_IO_In_Type is record
    Data_In   : std_logic_vector ( 31 downto 0 );
  end record;

  type Mem_Basic_IO_Out_Type is record
    Addr      : std_logic_vector ( 18 downto 0 );
    Data_Out  : std_logic_vector ( 31 downto 0 );
    Data_OE_n : std_logic_vector ( 31 downto 0 );
    Addr_CS_n : std_logic;
    CS_n      : std_logic;
    WE_n      : std_logic;
  end record;

  procedure Init_Mem_Basic_IO
    (
      signal User : out Mem_Basic_IO_Type
    );

  procedure Init_Mem_Basic_IO
    (
      signal User : out Mem_Basic_IO_In_Type
    );

  component Mem_Basic_IO is
    generic
    (
      INFF_Delay    : INTEGER := NODELAY;
      OBUF_Drive    : INTEGER := SLOW_12mA
    );
    port
    (
      Pads      : inout Mem_Pads_Type;
      User_In   :   out Mem_Basic_IO_In_Type;
      User_Out  : in    Mem_Basic_IO_Out_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  PE0_Bus_Basic_IO_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Data_In                 2     I     Data input
  --  Data_Out                2     O     Data output
  --  Data_OE_n               2     O     Data output enable
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type PE0_Bus_Basic_IO_Type is record
    Data_In   : std_logic_vector ( 1 downto 0 );
    Data_Out  : std_logic_vector ( 1 downto 0 );
    Data_OE_n : std_logic_vector ( 1 downto 0 );
  end record;

  type PE0_Bus_Basic_IO_In_Type is record
    Data_In   : std_logic_vector ( 1 downto 0 );
  end record;

  type PE0_Bus_Basic_IO_Out_Type is record
    Data_Out  : std_logic_vector ( 1 downto 0 );
    Data_OE_n : std_logic_vector ( 1 downto 0 );
  end record;

  procedure Init_PE0_Bus_Basic_IO
    (
      signal User : out PE0_Bus_Basic_IO_Type
    );

  procedure Init_PE0_Bus_Basic_IO
    (
      signal User : out PE0_Bus_Basic_IO_In_Type
    );

  component PE0_Bus_Basic_IO is
    generic
    (
      INFF_Delay    : INTEGER := NODELAY;
      OBUF_Drive    : INTEGER := FAST_8mA
    );
    port
    (
      Pads      : inout PE0_Bus_Pads_Type;
      User_In   :   out PE0_Bus_Basic_IO_In_Type;
      User_Out  : in    PE0_Bus_Basic_IO_Out_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  Systolic_Basic_IO_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Data_In                36     I     Data input
  --  Data_Out               36     O     Data output
  --  Data_OE_n              36     O     Data output enable
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type Systolic_Basic_IO_Type is record
    Data_In   : std_logic_vector ( 35 downto 0 );
    Data_Out  : std_logic_vector ( 35 downto 0 );
    Data_OE_n : std_logic_vector ( 35 downto 0 );
  end record;

  type Systolic_Basic_IO_In_Type is record
    Data_In   : std_logic_vector ( 35 downto 0 );
  end record;

  type Systolic_Basic_IO_Out_Type is record
    Data_Out  : std_logic_vector ( 35 downto 0 );
    Data_OE_n : std_logic_vector ( 35 downto 0 );
  end record;

  procedure Init_Systolic_Basic_IO
    (
      signal User : out Systolic_Basic_IO_Type
    );

  procedure Init_Systolic_Basic_IO
    (
      signal User : out Systolic_Basic_IO_In_Type
    );

  component Systolic_Basic_IO is
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
  end component;

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Standard Interface Types, Components, and Procedures
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------
  --
  --  Clock_Std_IF_Type
  --
  --  Name Key:
  --  =========
  --  _AS       : Address Strobe
  --  _CB       : CardBus
  --  _CE       : Clock Enable
  --  _CS       : Chip Select
  --  _DS       : Data Strobe
  --  _EN       : Enable
  --  _OE       : Output Enable
  --  _PE       : Processing Element
  --  _RD       : Read Select
  --  _WE       : Write Enable
  --  _WR       : Write Select
  --  _d[d...]  : Delayed (registered) signal (each 'd' denotes one 
  --              level of delay)
  --  _n        : Active low signals (must be last part of name)
  --
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  M_Clk                   1     I     Memory clock
  --  P_Clk                   1     I     Processing element clock
  --  K_Clk                   1     I     LAD-bus clock
  --  U_Clk                   1     I     User clock
  --  M_Clk_Locked            1     I     M_Clk CLKDLL locked flag
  --  P_Clk_Locked            1     I     P_Clk CLKDLL locked flag
  --  K_Clk_Locked            1     I     K_Clk CLKDLL locked flag
  --  U_Clk_Locked            1     I     U_Clk CLKDLL locked flag
  --  
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type Clock_Std_IF_Type is record
    M_Clk         : std_logic;
    P_Clk         : std_logic;
    K_Clk         : std_logic;
    U_Clk         : std_logic;
    M_Clk_Locked  : std_logic;
    P_Clk_Locked  : std_logic;
    K_Clk_Locked  : std_logic;
    U_Clk_Locked  : std_logic;
  end record;

  type Clock_Std_IF_In_Type is record
    M_Clk         : std_logic;
    P_Clk         : std_logic;
    K_Clk         : std_logic;
    U_Clk         : std_logic;
    M_Clk_Locked  : std_logic;
    P_Clk_Locked  : std_logic;
    K_Clk_Locked  : std_logic;
    U_Clk_Locked  : std_logic;
  end record;

  procedure Init_Clock_Std_IF
    (
      signal User : out Clock_Std_IF_Type
    );

  procedure Init_Clock_Std_IF
    (
      signal User : out Clock_Std_IF_In_Type
    );

  component Clock_Std_IF is
    generic
    (
      M_CLK_DLL_TYPE  : INTEGER := LOW_FREQ;
      P_CLK_DLL_TYPE  : INTEGER := LOW_FREQ;
      U_CLK_DLL_TYPE  : INTEGER := LOW_FREQ
    );
    port
    (
      Pads      : inout Clock_Pads_Type;
      User_In   :   out Clock_Std_IF_In_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  LAD_Bus_Std_IF_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Addr                   23     I     Address bus input (DWORD)
  --  Data_In                32     I     Data bus input
  --  Data_Out               32     O     Data bus output
  --  Reg_Strobe_n            1     I     Register access strobe
  --  Mem_Strobe_n            1     I     Memory access strobe
  --  Write_Sel_n             1     I     Write select
  --  Int_Req_n               1     O     Interrupt request
  --  DMA_Chan                2     I     DMA channel number indicator
  --  DMA_Stat                2     O     DMA channel status flags
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type LAD_Bus_Std_IF_Type is record
    Addr          : std_logic_vector ( 22 downto 0 );
    Data_In       : std_logic_vector ( 31 downto 0 );
    Data_Out      : std_logic_vector ( 31 downto 0 );
    Reg_Strobe_n  : std_logic;
    Mem_Strobe_n  : std_logic;
    Write_Sel_n   : std_logic;
    Int_Req_n     : std_logic;
    DMA_Chan      : std_logic_vector ( 1 downto 0 );
    DMA_Stat      : std_logic_vector ( 1 downto 0 );
  end record;

  type LAD_Bus_Std_IF_In_Type is record
    Addr          : std_logic_vector ( 22 downto 0 );
    Data_In       : std_logic_vector ( 31 downto 0 );
    Reg_Strobe_n  : std_logic;
    Mem_Strobe_n  : std_logic;
    Write_Sel_n   : std_logic;
    DMA_Chan      : std_logic_vector ( 1 downto 0 );
  end record;

  type LAD_Bus_Std_IF_Out_Type is record
    Data_Out      : std_logic_vector ( 31 downto 0 );
    Int_Req_n     : std_logic;
    DMA_Stat      : std_logic_vector ( 1 downto 0 );
  end record;

  procedure Init_LAD_Bus_Std_IF
    (
      signal User : out LAD_Bus_Std_IF_Type
    );

  procedure Init_LAD_Bus_Std_IF
    (
      signal User : out LAD_Bus_Std_IF_In_Type
    );

  component LAD_Bus_Std_IF is
    port
    (
      K_Clk         : in    std_logic;
      Global_Reset  : in    std_logic;
      Pads          : inout LAD_Bus_Pads_Type;
      User_In       :   out LAD_Bus_Std_IF_In_Type;
      User_Out      : in    LAD_Bus_Std_IF_Out_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  LED_Std_IF_Type
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
  --  Name                Width  Dir* Description
  --  ==================  =====  ==== ==================================
  --  Red_n                 1     O   Red light emitting diode output
  --  Green_n               1     O   Green light emitting diode output
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  --
  ----------------------------------------------------------------------
  type LED_Std_IF_Type is record
    Red_n   : std_logic;
    Green_n : std_logic;
  end record;

  type LED_Std_IF_Out_Type is record
    Red_n   : std_logic;
    Green_n : std_logic;
  end record;

  procedure Init_LED_Std_IF
    (
      signal User : out LED_Std_IF_Type
    );

  component LED_Std_IF is
    port
    (
      Pads      : inout LED_Pads_Type;
      User_Out  : in    LED_Std_IF_Out_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  Mem_Std_IF_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Addr                   20     O     Address bus (DWORD)
  --  Data_In                32     I     Input data bus
  --  Data_Out               32     O     Output data bus
  --  Data_Valid_n            1     I     Valid read data flag
  --  Strobe_n                1     O     Memory cycle strobe
  --  Write_Sel_n             1     O     Write cycle select
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type Mem_Std_IF_Type is record
    Addr          : std_logic_vector ( 19 downto 0 );
    Data_In       : std_logic_vector ( 31 downto 0 );
    Data_Out      : std_logic_vector ( 31 downto 0 );
    Data_Valid_n  : std_logic;
    Strobe_n      : std_logic;
    Write_Sel_n   : std_logic;
  end record;

  type Mem_Std_IF_In_Type is record
    Data_In       : std_logic_vector ( 31 downto 0 );
    Data_Valid_n  : std_logic;
  end record;

  type Mem_Std_IF_Out_Type is record
    Addr          : std_logic_vector ( 19 downto 0 );
    Data_Out      : std_logic_vector ( 31 downto 0 );
    Strobe_n      : std_logic;
    Write_Sel_n   : std_logic;
  end record;

  procedure Init_Mem_Std_IF
    (
      signal User : out Mem_Std_IF_Type
    );

  procedure Init_Mem_Std_IF
    (
      signal User : out Mem_Std_IF_In_Type
    );

  component Mem_Std_IF is
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
  end component;

  ----------------------------------------------------------------------
  --
  --  PE0_Bus_Std_IF_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Data_In                 2     I     Data input
  --  Data_Out                2     O     Data output
  --  Data_OE_n               2     O     Data output enable
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type PE0_Bus_Std_IF_Type is record
    Data_In   : std_logic_vector ( 1 downto 0 );
    Data_Out  : std_logic_vector ( 1 downto 0 );
    Data_OE_n : std_logic_vector ( 1 downto 0 );
  end record;

  type PE0_Bus_Std_IF_In_Type is record
    Data_In   : std_logic_vector ( 1 downto 0 );
  end record;

  type PE0_Bus_Std_IF_Out_Type is record
    Data_Out  : std_logic_vector ( 1 downto 0 );
    Data_OE_n : std_logic_vector ( 1 downto 0 );
  end record;

  procedure Init_PE0_Bus_Std_IF
    (
      signal User : out PE0_Bus_Std_IF_Type
    );

  procedure Init_PE0_Bus_Std_IF
    (
      signal User : out PE0_Bus_Std_IF_In_Type
    );

  component PE0_Bus_Std_IF is
    generic
    (
      INFF_Delay    : INTEGER := NODELAY;
      OBUF_Drive    : INTEGER := FAST_8mA
    );
    port
    (
      Clk           : in    std_logic;
      Global_Reset  : in    std_logic;
      Pads          : inout PE0_Bus_Pads_Type;
      User_In       :   out PE0_Bus_Std_IF_In_Type;
      User_Out      : in    PE0_Bus_Std_IF_Out_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  Systolic_Std_IF_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Data_In                36     I     Data input
  --  Data_Out               36     O     Data output
  --  Data_OE_n              36     O     Data output enable
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type Systolic_Std_IF_Type is record
    Data_In   : std_logic_vector ( 35 downto 0 );
    Data_Out  : std_logic_vector ( 35 downto 0 );
    Data_OE_n : std_logic_vector ( 35 downto 0 );
  end record;

  type Systolic_Std_IF_In_Type is record
    Data_In   : std_logic_vector ( 35 downto 0 );
  end record;

  type Systolic_Std_IF_Out_Type is record
    Data_Out  : std_logic_vector ( 35 downto 0 );
    Data_OE_n : std_logic_vector ( 35 downto 0 );
  end record;

  procedure Init_Systolic_Std_IF
    (
      signal User : out Systolic_Std_IF_Type
    );

  procedure Init_Systolic_Std_IF
    (
      signal User : out Systolic_Std_IF_In_Type
    );

  component Systolic_Std_IF is
    generic
    (
      INFF_Delay    : INTEGER := NODELAY;
      OBUF_Drive    : INTEGER := FAST_8mA
    );
    port
    (
      Clk           : in    std_logic;
      Global_Reset  : in    std_logic;
      Pads          : inout Systolic_Pads_Type;
      User_In       :   out Systolic_Std_IF_In_Type;
      User_Out      : in    Systolic_Std_IF_Out_Type
    );
  end component;

  ----------------------------------------------------------------------
  --
  --  IO_Conn_Std_IF_Type
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
  --  Name                  Width  Dir*   Description
  --  ====================  =====  ====   ==============================
  --  Data_In                66     I     Data input
  --  Data_Out               66     O     Data output
  --  Data_OE_n              66     O     Data output enable
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type IO_Conn_Std_IF_Type is record
    Data_In   : std_logic_vector ( 65 downto 0 );
    Data_Out  : std_logic_vector ( 65 downto 0 );
    Data_OE_n : std_logic_vector ( 65 downto 0 );
  end record;

  type IO_Conn_Std_IF_In_Type is record
    Data_In   : std_logic_vector ( 65 downto 0 );
  end record;

  type IO_Conn_Std_IF_Out_Type is record
    Data_Out  : std_logic_vector ( 65 downto 0 );
    Data_OE_n : std_logic_vector ( 65 downto 0 );
  end record;

  procedure Init_IO_Conn_Std_IF
    (
      signal User : out IO_Conn_Std_IF_Type
    );

  procedure Init_IO_Conn_Std_IF
    (
      signal User : out IO_Conn_Std_IF_In_Type
    );

  component IO_Conn_Std_IF is
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
  end component;

end package;

------------------------ Package Body Declaration ----------------------

package body PE_Package is

  ----------------------- Procedure Declarations -----------------------

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Pads Initialization Procedures
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------

  procedure Init_Clock_Pads
    (
      signal Pads : out Clock_Pads_Type 
    )
  is
  begin
    Pads.M_Clk <= 'Z';
    Pads.P_Clk <= 'Z';
    Pads.K_Clk <= 'Z';
    Pads.U_Clk <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_LAD_Bus_Pads
    (
      signal Pads : out LAD_Bus_Pads_Type
    )
  is
  begin
    Pads.Addr_Data  <= ( others => 'Z' );
    Pads.DS_n       <= 'Z';
    Pads.Reg_n      <= 'Z';
    Pads.WR_n       <= 'Z';
    Pads.CS_n       <= 'Z';
    Pads.Int_Req_n  <= 'Z';
    Pads.DMA_Chan   <= ( others => 'Z' );
    Pads.DMA_Stat   <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_LED_Pads
    (
      signal Pads : out LED_Pads_Type
    )
  is
  begin
    Pads.Red_n    <= 'Z';
    Pads.Green_n  <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Mem_Pads
    (
      signal Pads : out Mem_Pads_Type
    )
  is
  begin
    Pads.Addr       <= ( others => 'Z' );
    Pads.Data       <= ( others => 'Z' );
    Pads.Addr_CS_n  <= 'Z';
    Pads.CS_n       <= 'Z';
    Pads.WE_n       <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Mezz_Conn_Pads
    (
      signal Pads : out Mezz_Conn_Pads_Type
    )
  is
  begin
    Pads.Left   <= ( others => 'Z' );
    Pads.Right  <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_PE0_Bus_Pads
    (
      signal Pads : out PE0_Bus_Pads_Type
    )
  is
  begin
    Pads <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Reset_Pads
    (
      signal Pads : out Reset_Pads_Type
    )
  is
  begin
    Pads <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Systolic_Pads
    (
      signal Pads : out Systolic_Pads_Type
    )
  is
  begin
    Pads <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_PEX_Pads
    (
      signal Pads : out PEX_Pads_Type
    )
  is
  begin
    Init_Clock_Pads ( Pads.Clocks );
    Init_Reset_Pads ( Pads.Reset );
    Init_LAD_Bus_Pads ( Pads.LAD_Bus );
    Init_Mem_Pads ( Pads.Left_Mem );
    Init_Mem_Pads ( Pads.Right_Mem );
    Init_Systolic_Pads ( Pads.Bot_Sys );
    Init_Systolic_Pads ( Pads.Top_Sys );
    Init_Mezz_Conn_Pads ( Pads.Mezz );
    Init_LED_Pads ( Pads.LEDs );
    Init_PE0_Bus_Pads ( Pads.PE0_Bus );
  end procedure;

  ----------------------------------------------------------------------

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Basic I/O Initialization Procedures
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------

  procedure Init_Clock_Basic_IO
    (
      signal User : out Clock_Basic_IO_Type
    )
  is
  begin
    User.M_Clk <= 'Z';
    User.P_Clk <= 'Z';
    User.K_Clk <= 'Z';
    User.U_Clk <= 'Z';
  end procedure;

  procedure Init_Clock_Basic_IO
    (
      signal User : out Clock_Basic_IO_In_Type
    )
  is
  begin
    User.M_Clk <= 'Z';
    User.P_Clk <= 'Z';
    User.K_Clk <= 'Z';
    User.U_Clk <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_LAD_Bus_Basic_IO
    (
      signal User : out LAD_Bus_Basic_IO_Type
    )
  is
  begin
    User.Addr_Data_In   <= ( others => 'Z' );
    User.Addr_Data_Out  <= ( others => 'Z' );
    User.Addr_Data_OE_n <= ( others => 'Z' );
    User.DS_n           <= 'Z';
    User.Reg_n          <= 'Z';
    User.WR_n           <= 'Z';
    User.CS_n           <= 'Z';
    User.Int_Req_n      <= 'Z';
    User.DMA_Chan       <= ( others => 'Z' );
    User.DMA_Stat       <= ( others => 'Z' );
  end procedure;

  procedure Init_LAD_Bus_Basic_IO
    (
      signal User : out LAD_Bus_Basic_IO_In_Type
    )
  is
  begin
    User.Addr_Data_In   <= ( others => 'Z' );
    User.DS_n           <= 'Z';
    User.Reg_n          <= 'Z';
    User.WR_n           <= 'Z';
    User.CS_n           <= 'Z';
    User.DMA_Chan       <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_LED_Basic_IO
    (
      signal User : out LED_Basic_IO_Type
    )
  is
  begin
    User.Red_n    <= 'Z';
    User.Green_n  <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Mem_Basic_IO
    (
      signal User : out Mem_Basic_IO_Type
    )
  is
  begin
    User.Addr       <= ( others => 'Z' );
    User.Data_In    <= ( others => 'Z' );
    User.Data_Out   <= ( others => 'Z' );
    User.Data_OE_n  <= ( others => 'Z' );
    User.Addr_CS_n  <= 'Z';
    User.CS_n       <= 'Z';
    User.WE_n       <= 'Z';
  end procedure;

  procedure Init_Mem_Basic_IO
    (
      signal User : out Mem_Basic_IO_In_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_PE0_Bus_Basic_IO
    (
      signal User : out PE0_Bus_Basic_IO_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
    User.Data_Out   <= ( others => 'Z' );
    User.Data_OE_n  <= ( others => 'Z' );
  end procedure;

  procedure Init_PE0_Bus_Basic_IO
    (
      signal User : out PE0_Bus_Basic_IO_In_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Systolic_Basic_IO
    (
      signal User : out Systolic_Basic_IO_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
    User.Data_Out   <= ( others => 'Z' );
    User.Data_OE_n  <= ( others => 'Z' );
  end procedure;

  procedure Init_Systolic_Basic_IO
    (
      signal User : out Systolic_Basic_IO_In_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Standard Interface Initialization Procedures
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------

  procedure Init_Clock_Std_IF
    (
      signal User : out Clock_Std_IF_Type
    )
  is
  begin
    User.M_Clk          <= 'Z';
    User.P_Clk          <= 'Z';
    User.K_Clk          <= 'Z';
    User.U_Clk          <= 'Z';
    User.M_Clk_Locked   <= 'Z';
    User.P_Clk_Locked   <= 'Z';
    User.K_Clk_Locked   <= 'Z';
    User.U_Clk_Locked   <= 'Z';
  end procedure;

  procedure Init_Clock_Std_IF
    (
      signal User : out Clock_Std_IF_In_Type
    )
  is
  begin
    User.M_Clk          <= 'Z';
    User.P_Clk          <= 'Z';
    User.K_Clk          <= 'Z';
    User.U_Clk          <= 'Z';
    User.M_Clk_Locked   <= 'Z';
    User.P_Clk_Locked   <= 'Z';
    User.K_Clk_Locked   <= 'Z';
    User.U_Clk_Locked   <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_LAD_Bus_Std_IF
    (
      signal User : out LAD_Bus_Std_IF_Type
    )
  is
  begin
    User.Addr         <= ( others => 'Z' );
    User.Data_In      <= ( others => 'Z' );
    User.Data_Out     <= ( others => 'Z' );
    User.Reg_Strobe_n <= 'Z';
    User.Mem_Strobe_n <= 'Z';
    User.Write_Sel_n  <= 'Z';
    User.Int_Req_n    <= 'Z';
    User.DMA_Chan     <= ( others => 'Z' );
    User.DMA_Stat     <= ( others => 'Z' );
  end procedure;

  procedure Init_LAD_Bus_Std_IF
    (
      signal User : out LAD_Bus_Std_IF_In_Type
    )
  is
  begin
    User.Addr         <= ( others => 'Z' );
    User.Data_In      <= ( others => 'Z' );
    User.Reg_Strobe_n <= 'Z';
    User.Mem_Strobe_n <= 'Z';
    User.Write_Sel_n  <= 'Z';
    User.DMA_Chan     <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_LED_Std_IF
    (
      signal User : out LED_Std_IF_Type
    )
  is
  begin
    User.Red_n    <= 'Z';
    User.Green_n  <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Mem_Std_IF
    (
      signal User : out Mem_Std_IF_Type
    )
  is
  begin
    User.Addr         <= ( others => 'Z' );
    User.Data_In      <= ( others => 'Z' );
    User.Data_Out     <= ( others => 'Z' );
    User.Data_Valid_n <= 'Z';
    User.Strobe_n     <= 'Z';
    User.Write_Sel_n  <= 'Z';
  end procedure;

  procedure Init_Mem_Std_IF
    (
      signal User : out Mem_Std_IF_In_Type
    )
  is
  begin
    User.Data_In      <= ( others => 'Z' );
    User.Data_Valid_n <= 'Z';
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_PE0_Bus_Std_IF
    (
      signal User : out PE0_Bus_Std_IF_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
    User.Data_Out   <= ( others => 'Z' );
    User.Data_OE_n  <= ( others => 'Z' );
  end procedure;

  procedure Init_PE0_Bus_Std_IF
    (
      signal User : out PE0_Bus_Std_IF_In_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Systolic_Std_IF
    (
      signal User : out Systolic_Std_IF_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
    User.Data_Out   <= ( others => 'Z' );
    User.Data_OE_n  <= ( others => 'Z' );
  end procedure;

  procedure Init_Systolic_Std_IF
    (
      signal User : out Systolic_Std_IF_In_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_IO_Conn_Std_IF
    (
      signal User : out IO_Conn_Std_IF_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
    User.Data_Out   <= ( others => 'Z' );
    User.Data_OE_n  <= ( others => 'Z' );
  end procedure;

  procedure Init_IO_Conn_Std_IF
    (
      signal User : out IO_Conn_Std_IF_In_Type
    )
  is
  begin
    User.Data_In    <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

end package body;

