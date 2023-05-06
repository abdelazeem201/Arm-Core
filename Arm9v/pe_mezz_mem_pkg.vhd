------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Package       : PE_Mezz_Mem_Package
--
--  Library       : PEX_Lib
--
--  Filename      : pe_mezz_mem_pkg.vhd
--
--  Date          : 9/3/99
--
--  Description   : Package containing record, component, and procedure
--                  declarations for the PEX mezzanine memory card
--                  interface.
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;

--------------------------- Package Declaration ------------------------

package PE_Mezz_Mem_Package is

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Basic I/O Types, Components, and Procedures
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------
  --
  --  Type : Mezz_Mem_Basic_IO
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
  --  Addr_In                19     I     Address input
  --  Addr_Out               19     O     Address output
  --  Addr_OE_n              19     O     Address output enable
  --  Data_In                64     I     Data input
  --  Data_Out               64     O     Data output
  --  Data_OE_n              64     O     Data output enable
  --  Addr_CS_In_n            1     I     Address chip select input
  --  Addr_CS_Out_n           1     O     Address chip select output
  --  Addr_CS_OE_n            1     O     Address chip sel out enable
  --  Low_CS_In_n             1     I     Low Dword chip select input
  --  Low_CS_Out_n            1     O     Low Dword chip select output
  --  Low_CS_OE_n             1     O     Low Dword chip sel out enable
  --  High_CS_In_n            1     I     Hi Dword chip select input
  --  High_CS_Out_n           1     O     Hi Dword chip select output
  --  High_CS_En_n            1     O     Hi Dword chip sel out enable
  --  WE_In_n                 1     I     Write enable input
  --  WE_Out_n                1     O     Write enable output
  --  WE_OE_n                 1     O     Write enable output enable
  --  Xbar_Mode_In            2     I     Crossbar mode input
  --  Xbar_Mode_Out           2     O     Crossbar mode output
  --  Xbar_Mode_OE_n          2     O     Crossbar mode output enable
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type Mezz_Mem_Basic_IO_Type is record
    Addr_In         : std_logic_vector(18 downto 0);
    Addr_Out        : std_logic_vector(18 downto 0);
    Addr_OE_n       : std_logic_vector(18 downto 0);
    Data_In         : std_logic_vector(63 downto 0);
    Data_Out        : std_logic_vector(63 downto 0);
    Data_OE_n       : std_logic_vector(63 downto 0);
    Addr_CS_In_n    : std_logic;
    Addr_CS_Out_n   : std_logic;
    Addr_CS_OE_n    : std_logic;
    Low_CS_In_n     : std_logic;
    Low_CS_Out_n    : std_logic;
    Low_CS_OE_n     : std_logic;
    High_CS_In_n    : std_logic;
    High_CS_Out_n   : std_logic;
    High_CS_OE_n    : std_logic;
    WE_In_n         : std_logic;
    WE_Out_n        : std_logic;
    WE_OE_n         : std_logic;
    Xbar_Mode_In    : std_logic_vector(1 downto 0);
    Xbar_Mode_Out   : std_logic_vector(1 downto 0);
    Xbar_Mode_OE_n  : std_logic_vector(1 downto 0);
  end record;

  type Mezz_Mem_Basic_IO_In_Type is record
    Addr_In         : std_logic_vector(18 downto 0);
    Data_In         : std_logic_vector(63 downto 0);
    Addr_CS_In_n    : std_logic;
    Low_CS_In_n     : std_logic;
    High_CS_In_n    : std_logic;
    WE_In_n         : std_logic;
    Xbar_Mode_In    : std_logic_vector(1 downto 0);
  end record;

  type Mezz_Mem_Basic_IO_Out_Type is record
    Addr_Out        : std_logic_vector(18 downto 0);
    Addr_OE_n       : std_logic_vector(18 downto 0);
    Data_Out        : std_logic_vector(63 downto 0);
    Data_OE_n       : std_logic_vector(63 downto 0);
    Addr_CS_Out_n   : std_logic;
    Addr_CS_OE_n    : std_logic;
    Low_CS_Out_n    : std_logic;
    Low_CS_OE_n     : std_logic;
    High_CS_Out_n   : std_logic;
    High_CS_OE_n    : std_logic;
    WE_Out_n        : std_logic;
    WE_OE_n         : std_logic;
    Xbar_Mode_Out   : std_logic_vector(1 downto 0);
    Xbar_Mode_OE_n  : std_logic_vector(1 downto 0);
  end record;

  procedure Init_Mezz_Mem_Basic_IO
    (
      signal User : out Mezz_Mem_Basic_IO_Type
    );

  procedure Init_Mezz_Mem_Basic_IO
    (
      signal User : out Mezz_Mem_Basic_IO_In_Type
    );

  component Mezz_Mem_Basic_IO is
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
  end component;

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Standard Interface Types, Components, and Procedures
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------
  --
  --  Type : Mezz_Mem_Std_IF
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
  --  Addr                   20     O     Address output
  --  Data_In                64     I     Data input
  --  Data_Out               64     O     Data output
  --  Low_Valid_n             1     I     Low data input valid flag
  --  High_Valid_n            1     I     High data input valid flag
  --  Low_Strobe_n            1     O     Low Dword access strobe
  --  High_Strobe_n           1     O     Hi Dword access strobe
  --  Write_Sel_n             1     O     Write select
  --  Xbar_Mode_In            2     I     Crossbar mode input
  --  Xbar_Mode_Out           2     O     Crossbar mode output
  --  Xbar_Mode_OE_n          1     O     Crossbar mode output enable
  --  Shunt_In               54     I     Shunt input
  --  Shunt_Out              54     O     Shunt output
  --  Shunt_OE_n             54     O     Shunt output enable
  --
  --  * Direction 'O' means the user drives the signal, 'I' means the 
  --    pads drive the signal.
  --
  ----------------------------------------------------------------------
  type Mezz_Mem_Std_IF_Type is record
    Addr            : std_logic_vector(19 downto 0);
    Data_In         : std_logic_vector(63 downto 0);
    Data_Out        : std_logic_vector(63 downto 0);
    Low_Valid_n     : std_logic;
    High_Valid_n    : std_logic;
    Low_Strobe_n    : std_logic;
    High_Strobe_n   : std_logic;
    Write_Sel_n     : std_logic;
    Xbar_Mode_In    : std_logic_vector(1 downto 0);
    Xbar_Mode_Out   : std_logic_vector(1 downto 0);
    Xbar_Mode_OE_n  : std_logic;
    Shunt_In        : std_logic_vector(53 downto 0);
    Shunt_Out       : std_logic_vector(53 downto 0);
    Shunt_OE_n      : std_logic_vector(53 downto 0);
  end record;

  type Mezz_Mem_Std_IF_In_Type is record
    Data_In         : std_logic_vector(63 downto 0);
    Low_Valid_n     : std_logic;
    High_Valid_n    : std_logic;
    Xbar_Mode_In    : std_logic_vector(1 downto 0);
    Shunt_In        : std_logic_vector(53 downto 0);
  end record;

  type Mezz_Mem_Std_IF_Out_Type is record
    Addr            : std_logic_vector(19 downto 0);
    Data_Out        : std_logic_vector(63 downto 0);
    Low_Strobe_n    : std_logic;
    High_Strobe_n   : std_logic;
    Write_Sel_n     : std_logic;
    Xbar_Mode_Out   : std_logic_vector(1 downto 0);
    Xbar_Mode_OE_n  : std_logic;
    Shunt_Out       : std_logic_vector(53 downto 0);
    Shunt_OE_n      : std_logic_vector(53 downto 0);
  end record;

  procedure Init_Mezz_Mem_Std_IF 
    (
      signal User : out Mezz_Mem_Std_IF_Type
    );

  procedure Init_Mezz_Mem_Std_IF 
    (
      signal User : out Mezz_Mem_Std_IF_In_Type
    );

  component Mezz_Mem_Std_IF is
    generic
    (
      INFF_Delay    : INTEGER := NODELAY;
      OBUF_Drive    : INTEGER := SLOW_12mA
    );
    port
    (
      M_Clk         : in    std_logic;
      Global_Reset  : in    std_logic;
      Pads          : inout std_logic_vector(88 downto 0);
      User_In       :   out Mezz_Mem_Std_IF_In_Type;
      User_Out      : in    Mezz_Mem_Std_IF_Out_Type
    );
  end component;

end package;

------------------------ Package Body Declaration ----------------------

package body PE_Mezz_Mem_Package is

  ----------------------------------------------------------------------

  procedure Init_Mezz_Mem_Basic_IO
    (
      signal User : out Mezz_Mem_Basic_IO_Type
    ) 
  is
  begin
    User.Addr_In          <= ( others => 'Z' );
    User.Addr_Out         <= ( others => 'Z' );
    User.Addr_OE_n        <= ( others => 'Z' );
    User.Data_In          <= ( others => 'Z' );
    User.Data_Out         <= ( others => 'Z' );
    User.Data_OE_n        <= ( others => 'Z' );
    User.Addr_CS_In_n     <= 'Z';
    User.Addr_CS_Out_n    <= 'Z';
    User.Addr_CS_OE_n     <= 'Z';
    User.Low_CS_In_n      <= 'Z';
    User.Low_CS_Out_n     <= 'Z';
    User.Low_CS_OE_n      <= 'Z';
    User.High_CS_In_n     <= 'Z';
    User.High_CS_Out_n    <= 'Z';
    User.High_CS_OE_n     <= 'Z';
    User.WE_In_n          <= 'Z';
    User.WE_Out_n         <= 'Z';
    User.WE_OE_n          <= 'Z';
    User.Xbar_Mode_In     <= ( others => 'Z' );
    User.Xbar_Mode_Out    <= ( others => 'Z' );
    User.Xbar_Mode_OE_n   <= ( others => 'Z' );
  end procedure;

  procedure Init_Mezz_Mem_Basic_IO
    (
      signal User : out Mezz_Mem_Basic_IO_In_Type
    ) 
  is
  begin
    User.Addr_In          <= ( others => 'Z' );
    User.Data_In          <= ( others => 'Z' );
    User.Addr_CS_In_n     <= 'Z';
    User.Low_CS_In_n      <= 'Z';
    User.High_CS_In_n     <= 'Z';
    User.WE_In_n          <= 'Z';
    User.Xbar_Mode_In     <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

  procedure Init_Mezz_Mem_Std_IF
    (
      signal User : out Mezz_Mem_Std_IF_Type
    )
  is
  begin
    User.Addr           <= ( others => 'Z' );
    User.Data_In        <= ( others => 'Z' );
    User.Data_Out       <= ( others => 'Z' );
    User.Low_Valid_n    <= 'Z';
    User.High_Valid_n   <= 'Z';
    User.Low_Strobe_n   <= 'Z';
    User.High_Strobe_n  <= 'Z';
    User.Write_Sel_n    <= 'Z';
    User.Xbar_Mode_In   <= ( others => 'Z' );
    User.Xbar_Mode_Out  <= ( others => 'Z' );
    User.Xbar_Mode_OE_n <= 'Z';
    User.Shunt_In       <= ( others => 'Z' );
    User.Shunt_Out      <= ( others => 'Z' );
    User.Shunt_OE_n     <= ( others => 'Z' );
  end procedure;

  procedure Init_Mezz_Mem_Std_IF
    (
      signal User : out Mezz_Mem_Std_IF_In_Type
    )
  is
  begin
    User.Data_In        <= ( others => 'Z' );
    User.Low_Valid_n    <= 'Z';
    User.High_Valid_n   <= 'Z';
    User.Xbar_Mode_In   <= ( others => 'Z' );
    User.Shunt_In       <= ( others => 'Z' );
  end procedure;

  ----------------------------------------------------------------------

end package body;

