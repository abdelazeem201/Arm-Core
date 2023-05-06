------------------------------------------------------------------------
--
--  Entity        : PEX
--
--  Architecture  : Mem_Control
--
--  Filename      : pex.vhd
--
--  Date          : 3/13/00
--
--  Description   : Provides a host-to-memory and ARM-to-memory for 
--                  each of the memory devices.  There are 4 memory
--		    ports.  To save resources, only one may be 
--		    accessed at a time, although it is possible to 
--		    access all simultaneously with more hardware.
--
--		Ports: 2 32-bit wide and 2 64-bit wide
--			Each 32-bit port addresses 2MB of memory
--			Each 64-bit port addresses 8MB of memory
--
--		Note:  I'm only using 32 of the 64-bit ports at 
--			a time to simplify the interfaces.
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
--  Port Name                      Dir  Description
--  ============================   ===  ================================
--  Pads.Clock.M_Clk                I   Memory clock
--  Pads.Clock.P_Clk                I   Processor clock
--  Pads.Clock.K_Clk                I   LAD-bus clock
--  Pads.Clock.U_Clk                I   User clock
--  Pads.LAD_Bus.Addr_Data          B   LAD-bus shared address/data bus
--  Pads.LAD_Bus.AS_n               I   LAD-bus address strobe
--  Pads.LAD_Bus.DS_n               I   LAD-bus data strobe
--  Pads.LAD_Bus.Ack_n              O   LAD-bus acknowledge strobe
--  Pads.LAD_Bus.Reg_n              I   LAD-bus register select
--  Pads.LAD_Bus.WR_n               I   LAD-bus write select
--  Pads.LAD_Bus.CS_n               I   LAD-bus chip select
--  Pads.LAD_Bus.Int_Req_n          O   LAD-bus interrupt request
--  Pads.LAD_Bus.FIFO_Stat          O   FIFO status flags
--  Pads.Left_Mem.Addr              O   Left memory address bus
--  Pads.Left_Mem.Data              B   Left memory data bus
--  Pads.Left_Mem.Addr_CS_n         O   Left memory address chip select
--  Pads.Left_Mem.CS_n              O   Left memory chip select
--  Pads.Left_Mem.WE_n              O   Left memory write enable
--  Pads.Right_Mem.Addr             O   Left memory address bus
--  Pads.Right_Mem.Data             B   Left memory data bus
--  Pads.Right_Mem.Addr_CS_n        O   Left memory address chip select
--  Pads.Right_Mem.CS_n             O   Left memory chip select
--  Pads.Right_Mem.WE_n             O   Left memory write enable
--  Pads.Left_Sys                   B   Left systolic bus
--  Pads.Right_Sys                  B   Right systolic bus
--  Pads.Mezz.Left                  B   Left mezzanine connector
--  Pads.Mezz.Right                 B   Right mezzanine connector
--  Pads.LEDs.Red_n                 O   Red light emitting diode
--  Pads.LEDs.Green_n               O   Green light emitting diode
--  Pads.PE0_Bus                    B   PE0 bus
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM, ARM;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use PEX_Lib.PE_Package.all;
use PEX_Lib.PE_Mezz_Mem_Package.all;
use SYSTEM.Xilinx_Package.all;
use ARM.arm9;

------------------------ Architecture Declaration ----------------------

architecture Mem_Copy of PEX is

  ------------------------------- Glossary -----------------------------
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
  --  Port Name                 Width Dir Description
  --  ========================= ===== === ================================
  --  GND                          1   -  Signal ground (logical '0')
  --  Global_Reset                 1   -  Global reset (or set) signal
  --  Reset_Register               1   -  LAD bus accessible reset 
  --                               O  register
  --  Clocks_In.M_Clk              1   I  Memory clock
  --  Clocks_In.P_Clk              1   I  Processor clock
  --  Clocks_In.K_Clk              1   I  LAD-bus clock
  --  Clocks_In.U_Clk              1   I  User clock
  --  Clocks_In.M_Clk_Locked       1   I  M_Clk CLKDLL locked flag
  --  Clocks_In.P_Clk_Locked       1   I  P_Clk CLKDLL locked flag
  --  Clocks_In.K_Clk_Locked       1   I  K_Clk CLKDLL locked flag
  --  Clocks_In.U_Clk_Locked       1   I  U_Clk CLKDLL locked flag
  --  LAD_Bus_In.Addr             24   I  LAD bus DWORD address bus input
  --  LAD_Bus_In.Data_In          32   I  LAD bus data bus input
  --  LAD_Bus_In.Reg_Strobe_n      1   I  LAD bus register access strobe
  --  LAD_Bus_In.Mem_Strobe_n      1   I  LAD bus memory access strobe
  --  LAD_Bus_In.Write_Sel_n       1   I  LAD bus write select
  --  LAD_Bus_In.DMA_Chan          2   I  LAD bus DMA channel number 
  --                                      indicator
  --  LAD_Bus_Out.Data_Out        32   O  LAD bus data bus output
  --  LAD_Bus_Out.Int_Req_n        1   O  LAD bus interrupt request
  --  LAD_Bus_Out.DMA_Stat         2   O  LAD bus DMA channel status 
  --                                      flags
  --  LEDs_Out.Red_n               1   O  Red LED output
  --  LEDs_Out.Green_n             1   O  Green LED output
  --  Left_Mem_In.Data_In         32   I  Left on-board memory input 
  --                                      data bus
  --  Left_Mem_In.Data_Valid_n     1   I  Left on-board memory valid 
  --                                      read flag
  --  Left_Mem_Out.Addr           20   O  Left on-board memory 
  --                                      address bus
  --  Left_Mem_Out.Data_Out       32   O  Left on-board memory output 
  --                                      data bus
  --  Left_Mem_Out.Strobe_n        1   O  Left on-board memory access 
  --                                      strobe
  --  Left_Mem_Out.Write_Sel_n     1   O  Left on-board memory write 
  --                                      select
  --  Right_Mem_In.Data_In        32   I  Right on-board memory input 
  --                                      data bus
  --  Right_Mem_In.Data_Valid_n    1   I  Right on-board memory valid 
  --                                      read flag
  --  Right_Mem_Out.Addr          20   O  Right on-board memory address 
  --                                      bus
  --  Right_Mem_Out.Data_Out      32   O  Right on-board memory output 
  --                                      data bus
  --  Right_Mem_Out.Strobe_n       1   O  Right on-board memory access 
  --                                      strobe
  --  Right_Mem_Out.Write_Sel_n    1   O  Right on-board memory write 
  --                                      select
  --  Left_Mezz_In.Data_In        64   I  Left mezz mem data input
  --  Left_Mezz_In.Low_Valid_n     1   I  Left mezz mem low data valid 
  --                                      flag
  --  Left_Mezz_In.High_Valid_n    1   I  Left mezz mem high data valid 
  --                                      flag
  --  Left_Mezz_In.Xbar_Mode_In    2   I  Left mezz mem xbar mode input
  --  Left_Mezz_In.Shunt_In       54   I  Left mezz mem shunt input
  --  Left_Mezz_Out.Addr          20   O  Left mezz mem address output
  --  Left_Mezz_Out.Data_Out      32   O  Left mezz mem data output
  --  Left_Mezz_Out.Low_Strobe_n   1   O  Left mezz mem low Dword access 
  --                                      strobe
  --  Left_Mezz_Out.High_Strobe_n  1   O  Left mezz mem hi Dword access 
  --                                      strobe
  --  Left_Mezz_Out.Write_Sel_n    1   O  Left mezz mem write select
  --  Left_Mezz_Out.Xbar_Mode_Out  2   O  Left mezz mem xbar mode output
  --  Left_Mezz_Out.Xbar_Mode_OE_n 1   O  Left mezz mem xbar mode output 
  --                                      enable
  --  Left_Mezz_Out.Shunt_Out     54   O  Left mezz mem shunt output
  --  Left_Mezz_Out.Shunt_OE_n    54   O  Left mezz mem shunt output 
  --                                      enable
  --  Right_Mezz_In.Data_In       64   I  Right mezz mem data input
  --  Right_Mezz_In.Low_Valid_n    1   I  Right mezz mem low data valid 
  --                                      flag
  --  Right_Mezz_In.High_Valid_n   1   I  Right mezz mem high data valid 
  --                                      flag
  --  Right_Mezz_In.Xbar_Mode_In   2   I  Right mezz mem xbar mode input
  --  Right_Mezz_In.Shunt_In      54   I  Right mezz mem shunt input
  --  Right_Mezz_Out.Addr         20   O  Right mezz mem address output
  --  Right_Mezz_Out.Data_Out     64   O  Right mezz mem data output
  --  Right_Mezz_Out.Low_Strobe_n  1   O  Right mezz mem low Dword access 
  --                                      strobe
  --  Right_Mezz_Out.High_Strobe_n 1   O  Right mezz mem hi Dword access 
  --                                      strobe
  --  Right_Mezz_Out.Write_Sel_n   1   O  Right mezz mem write select
  --  Right_Mezz_Out.Xbar_Mode_Out 2   O  Right mezz mem xbar mode output
  --  Right_Mezz_Out.Xbar_Mode_OE_n 1  O  Right mezz mem xbar mode output 
  --                                      enable
  --  Right_Mezz_Out.Shunt_Out    54   O  Right mezz mem shunt output
  --  Right_Mezz_Out.Shunt_OE_n   54   O  Right mezz mem shunt output 
  --                                      enable
  --  PE0_Bus_In.Data_In           2   I  PE0 bus data input
  --  PE0_Bus_Out.Data_Out         2   O  PE0 bus data output
  --  PE0_Bus_Out.Data_OE_n        2   O  PE0 bus data output enable
  --  Top_Sys_In.Data_In          36   I  Top systolic bus data input
  --  Top_Sys_Out.Data_Out        36   O  Top systolic bus data output
  --  Top_Sys_Out.Data_OE_n       36   O  Top systolic bus data output 
  --                                      enable
  --  Bot_Sys_In.Data_In          36   I  Bottom systolic bus data 
  --                                      input
  --  Bot_Sys_Out.Data_Out        36   O  Bottom systolic bus data 
  --                                      output
  --  Bot_Sys_Out.Data_OE_n       36   O  Bottom systolic bus data 
  --                                      output enable
  --
  ----------------------------------------------------------------------

  ----------------------------------------------------------------------
  --
  --  Below are all of the standard PE pad interface signals. Simply
  --  uncomment the signal(s) that are needed by the PE design.  All
  --  other unused signals may remain commented out.  Be sure to
  --  uncomment any component instances used by the interface.
  --
  ----------------------------------------------------------------------

  signal GND            : std_logic;
  signal Global_Reset   : std_logic;
  signal Reset_Register : std_logic;
  signal Clocks_In      : Clock_Std_IF_In_Type;
  signal LAD_Bus_In     : LAD_Bus_Std_IF_In_Type;
  signal LAD_Bus_Out    : LAD_Bus_Std_IF_Out_Type;
  signal LEDs_Out       : LED_Std_IF_Out_Type;
  signal Left_Mem_In    : Mem_Std_IF_In_Type;
  signal Left_Mem_Out   : Mem_Std_IF_Out_Type;
  signal Right_Mem_In   : Mem_Std_IF_In_Type;
  signal Right_Mem_Out  : Mem_Std_IF_Out_Type;
  signal Left_Mezz_In   : Mezz_Mem_Std_IF_In_Type;
  signal Left_Mezz_Out  : Mezz_Mem_Std_IF_Out_Type;
  signal Right_Mezz_In  : Mezz_Mem_Std_IF_In_Type;
  signal Right_Mezz_Out : Mezz_Mem_Std_IF_Out_Type;
--  signal PE0_Bus_In     : PE0_Bus_Std_IF_In_Type;
--  signal PE0_Bus_Out    : PE0_Bus_Std_IF_Out_Type;
--  signal Top_Sys_In     : Systolic_Std_IF_In_Type;
--  signal Top_Sys_Out    : Systolic_Std_IF_Out_Type;
--  signal Bot_Sys_In     : Systolic_Std_IF_In_Type;
--  signal Bot_Sys_Out    : Systolic_Std_IF_Out_Type;


  signal Host_Mem_Addr            : std_logic_vector ( 24 downto 0 );
  signal Host_App_Sel		    : std_logic;
  signal Host_Left_Mem_Mux_Sel    : std_logic;
  signal Host_Right_Mem_Mux_Sel   : std_logic;
  signal Host_Left_Mezz0_Sel      : std_logic;
  signal Host_Left_Mezz1_Sel      : std_logic;
  signal Host_Left_Mezz_Mux_Sel   : std_logic;
  signal Host_Right_Mezz0_Sel     : std_logic;
  signal Host_Right_Mezz1_Sel     : std_logic;
  signal Host_Right_Mezz_Mux_Sel  : std_logic;
  signal Host_Mem_In              : Mem_Std_IF_In_Type;
  signal Host_Mem_Out             : Mem_Std_IF_Out_Type;
  signal Host_Right_Mem_In        : Mem_Std_IF_In_Type;
  signal Host_Right_Mem_Out       : Mem_Std_IF_Out_Type;
  signal Inactive_LAD_Bus_Out     : LAD_Bus_Std_IF_Out_Type;
  signal Host_Mem_LAD_Bus_Out     : LAD_Bus_Std_IF_Out_Type;
  signal Host_Mem_LAD_Bus_OE_n    : std_logic;
  signal Right_Mem_LAD_Bus_Out    : LAD_Bus_Std_IF_Out_Type;
  signal Right_Mem_LAD_Bus_OE_n   : std_logic;
  signal Stat_Reg_LAD_Bus_Out     : LAD_Bus_Std_IF_Out_Type;
  signal Stat_Reg_LAD_Bus_OE_n    : std_logic;
  signal K_CLK			    : std_logic;
  signal K_Done			    : std_logic;
  signal P_CLK			    : std_logic;

  signal ARM_Mem_Addr             : std_logic_vector (31 downto 0);
  signal ARM_Mem_In	  	    : Mem_Std_IF_In_Type;
  signal ARM_Mem_Out		    : Mem_Std_IF_Out_Type;
  signal ARM_Left_Mem_Mux_Sel     : std_logic;
  signal ARM_Right_Mem_Mux_Sel    : std_logic;
  signal ARM_Left_Mezz0_Sel       : std_logic;
  signal ARM_Left_Mezz1_Sel       : std_logic;
  signal ARM_Right_Mezz0_Sel      : std_logic;
  signal ARM_Right_Mezz1_Sel      : std_logic;
  signal ARM_Left_Mezz_Mux_Sel    : std_logic;
  signal ARM_Right_Mezz_Mux_Sel   : std_logic;
  signal ARM_STOP		  : std_logic;
  signal Inactive_Mem_In 	  : Mem_Std_IF_In_Type;
  signal Inactive_Mem_Out 	  : Mem_Std_IF_Out_Type;
  signal MMD_Data_In              : std_logic_vector (31 downto 0);
  signal MMD_Data_Out		  : std_logic_vector (31 downto 0);
  signal MMA         		  : std_logic_vector (31 downto 0);
  signal MMnWR			  : std_logic;
  signal MM_CE			  : std_logic;
  signal MM_New_Line		  : std_logic;
  signal ECLK			  : std_logic;
  signal nRESET			  : std_logic;
  signal nFIQ			  : std_logic;
  signal nIRQ 			  : std_logic;
  signal nWAIT			  : std_logic;
  signal ISYNC			  : std_logic;
  signal MMD_In			  : std_logic_vector (31 downto 0);
  signal MMD_Out		  : std_logic_vector (31 downto 0);

  constant SIM_ADDR_TOP_COUNT : std_logic_vector ( 19 downto 0 ) := x"0001F";
  constant SYN_ADDR_TOP_COUNT : std_logic_vector ( 19 downto 0 ) := x"FFFFF";
  
  ----------------------------------------------------------------------
  --   
  -- Signal declarations for the base address of each register used
  --
  ----------------------------------------------------------------------  
  constant BASE_MASK            : std_logic_vector ( 11 downto 8 ) := x"F"; -- 0xF00
  constant MEM_REG_BASE         : std_logic_vector ( 11 downto 8 ) := x"0"; -- 0x000
  constant MEM_DPM_BASE         : std_logic_vector ( 11 downto 8 ) := x"1"; -- 0x100
  constant RESET_BASE           : std_logic_vector ( 11 downto 8 ) := x"8"; -- 0x800
  constant CTRL_BASE            : std_logic_vector ( 11 downto 8 ) := x"9"; -- 0x900
  constant STAT_BASE            : std_logic_vector ( 11 downto 8 ) := x"A"; -- 0xA00
  constant LEFT_MEM_TAG         : std_logic_vector ( 31 downto 21 ) := b"00000000000";
  constant RIGHT_MEM_TAG	: std_logic_vector ( 31 downto 21 ) := b"00000000001";
  constant LEFT_MEZZ0_TAG	: std_logic_vector ( 31 downto 22 ) := b"0000000001";
  constant LEFT_MEZZ1_TAG       : std_logic_vector ( 31 downto 22 ) := b"0000000010";
  constant RIGHT_MEZZ0_TAG 	: std_logic_vector ( 31 downto 22 ) := b"0000000011";
  constant RIGHT_MEZZ1_TAG	: std_logic_vector ( 31 downto 22 ) := b"0000000100";

  ----------------------------------------------------------------------
  --   
  --  The LAD_To_Mem_Std_IF component is used for reads and writes 
  --  to/from the memories which reside both on the StarFire board
  --  and the Mezzanine Memory card.
  --
  ----------------------------------------------------------------------  

  component LAD_To_Mem_Std_IF is
    port
    (
      Global_Reset      : in    std_logic;
      Clocks_In         : in    Clock_Std_IF_In_Type;
      LAD_Bus_In        : in    LAD_Bus_Std_IF_In_Type;
      LAD_Bus_Out       :   out LAD_Bus_Std_IF_Out_Type;
      LAD_Bus_OE_n      :   out std_logic;
      Mem_Data_In       : in    std_logic_vector (31 downto 0);
      Mem_Data_Valid_n  : in    std_logic;
      Mem_Addr          :   out std_logic_vector (19 downto 0);
      Mem_Data_Out      :   out std_logic_vector (31 downto 0);
      Mem_Strobe_n      :   out std_logic;
      Mem_Write_Sel_n   :   out std_logic
    );
  end component;

  component ARM_To_Mem_Std_IF is
    port
    (
      Global_Reset      : in    std_logic;
      Clocks_In         : in    Clock_Std_IF_In_Type;
      MMD_Data_In       : in    std_logic_vector (31 downto 0);
      MMD_Data_Out      :   out std_logic_vector (31 downto 0);
      MMnWR             : in    std_logic;
      MM_CE             : in    std_logic;
      MM_New_Line       : in    std_logic;
      MMA		      : in 	  std_logic_vector (31 downto 0);
      Mem_Data_In       : in    std_logic_vector (31 downto 0);
      Mem_Data_Valid_n  : in    std_logic;
      Mem_Addr          :   out std_logic_vector (19 downto 0);
      Mem_Data_Out      :   out std_logic_vector (31 downto 0);
      Mem_Strobe_n      :   out std_logic;
      Mem_Write_Sel_n   :   out std_logic
    );
  end component;

  component arm9 is
    port
    (
      GCLK		: in	  std_logic;
      nRESET		: in 	  std_logic;
      nWAIT		:   out   std_logic;
      nFIQ		: in 	  std_logic;
      nIRQ		: in	  std_logic;
      ISYNC		: in	  std_logic;
      MMD_In		: in	  std_logic_vector (31 downto 0);
      MMD_Out		:   out std_logic_vector (31 downto 0);
      MMA		:   out std_logic_vector (31 downto 0);
      MMnWR		:   out std_logic;
      MM_CE             :   out std_logic;
      MM_New_Line       :   out std_logic;
      STOP		:   out std_logic
    );
  end component;

begin

  ----------------------------------------------------------------------
  --   
  --  The P_Reset process is used for the global reset.  When the host
  --  writes to address defined as RESET_BASE the global reset register
  --  will be high for one K_Clk pulse and return low.  
  --
  ----------------------------------------------------------------------  

  K_CLK <= Clocks_In.K_Clk;
  P_Reset : process ( Global_Reset, K_CLK )
  begin
    if ( Global_Reset = '1' ) then
      Reset_Register <= '0';
    elsif ( rising_edge ( K_CLK ) ) then
      if ( LAD_Bus_In.Reg_Strobe_n = '0' ) then
        if ( LAD_Bus_In.Write_Sel_n = '0' ) then
          if ( ( LAD_Bus_In.Addr ( RESET_BASE'range ) and BASE_MASK ) = 
                 RESET_BASE ) then
            Reset_Register <= '1';
          end if;
        end if;
      end if;
    end if;
  end process P_Reset;

  ----------------------------------------------------------------------
  --   
  --  The P_Ctrl process is used for the control register.
  --
  ----------------------------------------------------------------------  

  K_Ctrl : process ( Global_Reset, K_CLK )
  begin
    if ( Global_Reset = '1' ) then

      Host_App_Sel <= '0';

    elsif ( rising_edge ( K_CLK ) ) then
      if ( LAD_Bus_In.Reg_Strobe_n = '0' ) then
        if ( LAD_Bus_In.Write_Sel_n = '0' ) then
          if ( ( LAD_Bus_In.Addr ( CTRL_BASE'range ) and BASE_MASK ) = 
                 CTRL_BASE ) then

            Host_App_Sel <= LAD_Bus_In.Data_In(0);

          end if;
        end if;
      end if;
    end if;
  end process K_Ctrl;

  HostAddr_Reg : process ( Global_Reset, K_CLK )
  begin 
    if ( Global_Reset = '1' ) then
      Host_Mem_Addr <= (others => '0' );

    elsif ( rising_edge ( K_CLK ) ) then
      if ( LAD_Bus_In.Reg_Strobe_n = '0' ) then
	if ( ( LAD_Bus_In.Addr ( MEM_REG_BASE'range ) and BASE_MASK ) =
	       MEM_REG_BASE ) then
          if ( LAD_Bus_In.Write_Sel_n = '0' ) then
            if (LAD_Bus_In.Addr (1 downto 0) = "00") then

              Host_Mem_Addr <= Lad_Bus_In.Data_In(24 downto 0);

            end if; 
          end if;
        end if;
      end if;
    end if;
  end process HostAddr_Reg;

  ----------------------------------------------------------------------
  --
  --  The P_Stat process is used for the status register.
  --
  ----------------------------------------------------------------------

  Stat_Reg_LAD_Bus_Out.Int_Req_n <= '1';
  Stat_Reg_LAD_Bus_Out.DMA_Stat <= ( others => '0' );
  Stat_Reg_LAD_Bus_Out.Data_Out(31 downto 1) <= ( others => '0' );

  P_Stat : process ( Global_Reset, K_CLK )
  begin
    if ( Global_Reset = '1' ) then
      K_Done <= '0';
      Stat_Reg_LAD_Bus_Out.Data_Out(0) <= '0';
      Stat_Reg_LAD_Bus_OE_n <= '1';
    elsif ( rising_edge ( K_CLK ) ) then
      K_Done <= ARM_STOP;
      Stat_Reg_LAD_Bus_OE_n <= '1';
      if ( LAD_Bus_In.Reg_Strobe_n = '0' ) then
        if ( LAD_Bus_In.Write_Sel_n = '1' ) then
          if ( ( LAD_Bus_In.Addr ( STAT_BASE'range ) and BASE_MASK ) =
                 STAT_BASE ) then
            Stat_Reg_LAD_Bus_OE_n <= '0';
            Stat_Reg_LAD_Bus_Out.Data_Out(0) <= K_Done;
          end if;
        end if;
      end if;
    end if;
  end process P_Stat;


  ----------------------------------------------------------------------
  --   
  --  The Host_Mem_Buffer component controls memory access to/from
  --  the memory port from the LAD. 
  --
  ----------------------------------------------------------------------  
  Host_Mem_Buffer : LAD_To_Mem_Std_IF
    port map
    (
      Global_Reset      => Global_Reset,
      Clocks_In         => Clocks_In,
      LAD_Bus_In        => LAD_Bus_In,
      LAD_Bus_Out       => Host_Mem_LAD_Bus_Out,
      LAD_Bus_OE_n      => Host_Mem_LAD_Bus_OE_n,
      Mem_Data_In       => Host_Mem_In.Data_In,
      Mem_Data_Valid_n  => Host_Mem_In.Data_Valid_n,
      Mem_Addr          => Host_Mem_Out.Addr,
      Mem_Data_Out      => Host_Mem_Out.Data_Out,
      Mem_Strobe_n      => Host_Mem_Out.Strobe_n,
      Mem_Write_Sel_n   => Host_Mem_Out.Write_Sel_n
    );

  ----------------------------------------------------------------------
  --
  --  The ARM_Mem_Buffer component controls memory access to/from
  --  the memory port from the ARM CPU.
  --
  ----------------------------------------------------------------------
  ARM_Mem_Buffer : ARM_To_Mem_Std_IF
    port map
    (
      Global_Reset      => Global_Reset,
      Clocks_In         => Clocks_In,
      MMD_Data_In       => MMD_Data_In,
      MMD_Data_Out      => MMD_Data_Out,
      MMnWR             => MMnWR,
      MM_CE             => MM_CE,
      MM_New_Line       => MM_New_Line,
      MMA		=> MMA,
      Mem_Data_In       => ARM_Mem_In.Data_In,
      Mem_Data_Valid_n  => ARM_Mem_In.Data_Valid_n,
      Mem_Addr          => ARM_Mem_Out.Addr,
      Mem_Data_Out      => ARM_Mem_Out.Data_Out,
      Mem_Strobe_n      => ARM_Mem_Out.Strobe_n,
      Mem_Write_Sel_n   => ARM_Mem_Out.Write_Sel_n
    );

  ----------------------------------------------------------------------
  --
  --  The ARM Processor
  --  
  ----------------------------------------------------------------------

  nRESET <= not Global_Reset;
  nFIQ <= '1';
  nIRQ <= '1';
  ISYNC <= '1';

  ARM : arm9
    port map
    (
      GCLK              => P_CLK,
      nRESET            => nRESET,
      nWAIT		=> nWAIT,
      nFIQ              => nFIQ,
      nIRQ              => nIRQ,
      ISYNC             => ISYNC,
      MMD_In            => MMD_Data_Out,
      MMD_Out           => MMD_Data_In,
      MMA               => MMA,
      MMnWR             => MMnWR,
      MM_CE             => MM_CE,
      MM_New_Line       => MM_New_Line,
      STOP		=> ARM_STOP
    );

  ----------------------------------------------------------------------
  --
  -- ARM Control Register
  --
  ----------------------------------------------------------------------

  P_CLK <= Clocks_In.U_Clk;
  P_Ctrl : process ( Global_Reset, P_CLK )
  begin
    if ( Global_Reset = '1' ) then
      ARM_Mem_Addr <= ( others => '0' ); 
    elsif ( rising_edge ( P_CLK ) ) then
      if (MM_New_Line = '1') then
        ARM_Mem_Addr <= MMA;
      end if;
    end if;
  end process P_Ctrl;
      
  ----------------------------------------------------------------------
  -- 
  --  Multiplex the memory buffer lines.
  --
  ----------------------------------------------------------------------

  --Setup Inactive Busses to avoid excessive loads on busses in use
  Inactive_Mem_In.Data_In <= ( others => '0');
  Inactive_Mem_In.Data_Valid_n <= '0';
  Inactive_Mem_Out.Data_Out <= ( others => '0');
  Inactive_Mem_Out.Addr <= ( others => '0');
  Inactive_Mem_Out.Strobe_n <= '1';
  Inactive_Mem_Out.Write_Sel_n <= '1';

  --Decode the Memory Bank Needed and who has Access
  Host_Left_Mem_Mux_Sel <= '1' when ((("00000" & Host_Mem_Addr(24 downto 19)) = 
		LEFT_MEM_TAG) AND (Host_App_Sel = '1')) else '0';
  
  Host_Right_Mem_Mux_Sel <= '1' when ((("00000" & Host_Mem_Addr(24 downto 19)) = 
		RIGHT_MEM_TAG) AND (Host_App_Sel = '1')) else '0';

  Host_Left_Mezz0_Sel <= '1' when ((("00000" & Host_Mem_Addr(24 downto 20)) =
		LEFT_MEZZ0_TAG) AND (Host_App_Sel = '1')) else '0';

  Host_Left_Mezz1_Sel <= '1' when ((("00000" & Host_Mem_Addr(24 downto 20)) =
		LEFT_MEZZ1_TAG) AND (Host_App_Sel = '1')) else '0';

  Host_Left_Mezz_Mux_Sel <= '1' when ((Host_Left_Mezz0_Sel = '1') OR
                (Host_Left_Mezz1_Sel = '1')) else '0';

  Host_Right_Mezz0_Sel <= '1' when ((("00000" & Host_Mem_Addr(24 downto 20)) =
		RIGHT_MEZZ0_TAG) AND (Host_App_Sel = '1')) else '0';

  Host_Right_Mezz1_Sel <= '1' when ((("00000" & Host_Mem_Addr(24 downto 20)) =
                RIGHT_MEZZ1_TAG) AND (Host_App_Sel = '1')) else '0';

  Host_Right_Mezz_Mux_Sel <= '1' when ((Host_Right_Mezz0_Sel = '1') OR
                (Host_Right_Mezz1_Sel = '1')) else '0';

  ARM_Left_Mem_Mux_Sel <= '1' when ((ARM_Mem_Addr(31 downto 21) = 
		LEFT_MEM_TAG) AND (Host_App_Sel = '0')) else '0';

  ARM_Right_Mem_Mux_Sel <= '1' when ((ARM_Mem_Addr(31 downto 21) = 
		RIGHT_MEM_TAG) AND (Host_App_Sel = '0')) else '0';

  ARM_Left_Mezz0_Sel <= '1' when ((ARM_Mem_Addr(31 downto 22) =
                LEFT_MEZZ0_TAG) AND (Host_App_Sel = '0')) else '0';

  ARM_Left_Mezz1_Sel <= '1' when ((ARM_Mem_Addr(31 downto 22) =
                LEFT_MEZZ1_TAG) AND (Host_App_Sel = '0')) else '0';

  ARM_Left_Mezz_Mux_Sel <= '1' when ((ARM_Left_Mezz0_Sel = '1') OR
		(ARM_Left_Mezz1_Sel = '1')) else '0';

  ARM_Right_Mezz0_Sel <= '1' when ((ARM_Mem_Addr(31 downto 22) =
                RIGHT_MEZZ0_TAG) AND (Host_App_Sel = '0')) else '0';
  
  ARM_Right_Mezz1_Sel <= '1' when ((ARM_Mem_Addr(31 downto 22) =
                RIGHT_MEZZ1_TAG) AND (Host_App_Sel = '0')) else '0';

  ARM_Right_Mezz_Mux_Sel <= '1' when ((ARM_Right_Mezz0_Sel = '1') OR
                (ARM_Right_Mezz1_Sel = '1')) else '0';


  --Use the Bank Selectors to Mux the Output Busses
  Left_Mem_Out.Addr <= 
    ('0' & Host_Mem_Out.Addr (18 downto 0)) when ( Host_Left_Mem_Mux_Sel = '1')	else
    ('0' & ARM_Mem_Out.Addr (18 downto 0)) when ( ARM_Left_Mem_Mux_Sel = '1') else
    Inactive_Mem_Out.Addr;

  Left_Mem_Out.Data_Out <= 
    Host_Mem_Out.Data_Out when (Host_Left_Mem_Mux_Sel = '1') else
    ARM_Mem_Out.Data_Out when ( ARM_Left_Mem_Mux_Sel = '1') else
    Inactive_Mem_Out.Data_Out;

  Left_Mem_Out.Strobe_n <= 
    Host_Mem_Out.Strobe_n when (Host_Left_Mem_Mux_Sel = '1') else
    ARM_Mem_Out.Strobe_n when (ARM_Left_Mem_Mux_Sel = '1') else
    Inactive_Mem_Out.Strobe_n;

  Left_Mem_Out.Write_Sel_n <= 
    Host_Mem_Out.Write_Sel_n when (Host_Left_Mem_Mux_Sel = '1') else
    ARM_Mem_Out.Write_Sel_n when (ARM_Left_Mem_Mux_Sel = '1') else
    Inactive_Mem_Out.Write_Sel_n;

  Right_Mem_Out.Addr <=
    ('0' & Host_Mem_Out.Addr (18 downto 0)) when (Host_Right_Mem_Mux_Sel = '1') else
    ('0' & ARM_Mem_Out.Addr (18 downto 0)) when (ARM_Right_Mem_Mux_Sel = '1') else 
    Inactive_Mem_Out.Addr;
  
  Right_Mem_Out.Data_Out <=
    Host_Mem_Out.Data_Out when (Host_Right_Mem_Mux_Sel = '1') else
    ARM_Mem_Out.Data_Out when (ARM_Right_Mem_Mux_Sel = '1') else
    Inactive_Mem_Out.Data_Out;
  
  Right_Mem_Out.Strobe_n <=
    Host_Mem_Out.Strobe_n when (Host_Right_Mem_Mux_Sel = '1') else
    ARM_Mem_Out.Strobe_n when (ARM_Right_Mem_Mux_Sel = '1') else
    Inactive_Mem_Out.Strobe_n;
  
  Right_Mem_Out.Write_Sel_n <=
    Host_Mem_Out.Write_Sel_n when (Host_Right_Mem_Mux_Sel = '1') else
    ARM_Mem_Out.Write_Sel_n when (ARM_Right_Mem_Mux_Sel = '1') else
    Inactive_Mem_Out.Write_Sel_n;

  Left_Mezz_Out.Addr <=
    ('0' & Host_Mem_Out.Addr(19 downto 1)) when (Host_Left_Mezz_Mux_Sel = '1') else
    ('0' & ARM_Mem_Out.Addr(19 downto 1)) when (ARM_Left_Mezz_Mux_Sel = '1') else
    Inactive_Mem_Out.Addr;

  Left_Mezz_Out.Data_Out <=
    (Host_Mem_Out.Data_Out & Host_Mem_Out.Data_Out) when (Host_Left_Mezz_Mux_Sel = '1') else
    (ARM_Mem_Out.Data_Out & ARM_Mem_Out.Data_Out) when (ARM_Left_Mezz_Mux_Sel = '1') else
    (Inactive_Mem_Out.Data_Out & Inactive_Mem_Out.Data_Out);

  Left_Mezz_Out.Low_Strobe_n <=
    Host_Mem_Out.Strobe_n when (Host_Left_Mezz_Mux_Sel = '1' AND Host_Mem_Out.Addr(0) = '0') else
    ARM_Mem_Out.Strobe_n when (ARM_Left_Mezz_Mux_Sel = '1' AND ARM_Mem_Out.Addr(0) = '0') else
    Inactive_Mem_Out.Strobe_n;

  Left_Mezz_Out.High_Strobe_n <= 
    Host_Mem_Out.Strobe_n when (Host_Left_Mezz_Mux_Sel = '1' AND Host_Mem_Out.Addr(0) = '1') else
    ARM_Mem_Out.Strobe_n when (ARM_Left_Mezz_Mux_Sel = '1' AND ARM_Mem_Out.Addr(0) = '1') else
    Inactive_Mem_Out.Strobe_n;

  Left_Mezz_Out.Write_Sel_n <=
    Host_Mem_Out.Write_Sel_n when (Host_Left_Mezz_Mux_Sel = '1') else
    ARM_Mem_Out.Write_Sel_n when (ARM_Left_Mezz_Mux_Sel = '1') else
    Inactive_Mem_Out.Write_Sel_n;

  Left_Mezz_Out.Xbar_Mode_Out <= 
    "00" when (Host_Left_Mezz1_Sel = '1' OR ARM_Left_Mezz1_Sel = '1') else "01";

  Left_Mezz_Out.Xbar_Mode_OE_n <= '0';
--    '0' when (Host_Left_Mezz_Mux_Sel = '1' OR ARM_Left_Mezz_Mux_Sel = '1') else '1';

  Left_Mezz_Out.Shunt_Out <= (others => '0');
  Left_Mezz_Out.Shunt_OE_n <= (others => '1');

  Right_Mezz_Out.Addr <=
    ('0' & Host_Mem_Out.Addr(19 downto 1)) when (Host_Right_Mezz_Mux_Sel = '1') else
    ('0' & ARM_Mem_Out.Addr(19 downto 1)) when (ARM_Right_Mezz_Mux_Sel = '1') else
    Inactive_Mem_Out.Addr;
                
  Right_Mezz_Out.Data_Out <=
    (Host_Mem_Out.Data_Out & Host_Mem_Out.Data_Out) when (Host_Right_Mezz_Mux_Sel = '1') else
    (ARM_Mem_Out.Data_Out & ARM_Mem_Out.Data_Out) when (ARM_Right_Mezz_Mux_Sel = '1') else
    (Inactive_Mem_Out.Data_Out & Inactive_Mem_Out.Data_Out);
  
  Right_Mezz_Out.Low_Strobe_n <=
    Host_Mem_Out.Strobe_n when (Host_Right_Mezz_Mux_Sel = '1' AND Host_Mem_Out.Addr(0) = '0') else
    ARM_Mem_Out.Strobe_n when (ARM_Right_Mezz_Mux_Sel = '1' AND ARM_Mem_Out.Addr(0) = '0') else
    Inactive_Mem_Out.Strobe_n;
  
  Right_Mezz_Out.High_Strobe_n <=
    Host_Mem_Out.Strobe_n when (Host_Right_Mezz_Mux_Sel = '1' AND Host_Mem_Out.Addr(0) = '1') else
    ARM_Mem_Out.Strobe_n when (ARM_Right_Mezz_Mux_Sel = '1' AND ARM_Mem_Out.Addr(0) = '1') else
    Inactive_Mem_Out.Strobe_n;
  
  Right_Mezz_Out.Write_Sel_n <=
    Host_Mem_Out.Write_Sel_n when (Host_Right_Mezz_Mux_Sel = '1') else
    ARM_Mem_Out.Write_Sel_n when (ARM_Right_Mezz_Mux_Sel = '1') else
    Inactive_Mem_Out.Write_Sel_n;
  
  Right_Mezz_Out.Xbar_Mode_Out <=
    "00" when (Host_Right_Mezz1_Sel = '1' OR ARM_Right_Mezz1_Sel = '1') else "01";
           
  Right_Mezz_Out.Xbar_Mode_OE_n <= '0';
--    '0' when (Host_Right_Mezz_Mux_Sel = '1' OR ARM_Right_Mezz_Mux_Sel = '1') else '1';
  
  Right_Mezz_Out.Shunt_Out <= (others => '0');
  Right_Mezz_Out.Shunt_OE_n <= (others => '1');

  --Use the Bank Selectors to Mux the Input Busses
  Host_Mem_In.Data_In <= 
    Left_Mem_In.Data_In when ( Host_Left_Mem_Mux_Sel = '1' ) else
    Right_Mem_In.Data_In when ( Host_Right_Mem_Mux_Sel = '1' ) else
    Left_Mezz_In.Data_In(31 downto 0) when (Host_Left_Mezz_Mux_Sel = '1' AND Left_Mezz_In.Low_Valid_n = '0') else  
    Left_Mezz_In.Data_In(63 downto 32) when (Host_Left_Mezz_Mux_Sel = '1' AND Left_Mezz_In.High_Valid_n = '0') else
    Right_Mezz_In.Data_In(31 downto 0) when (Host_Right_Mezz_Mux_Sel = '1' AND Right_Mezz_In.Low_Valid_n = '0') else
    Right_Mezz_In.Data_In(63 downto 32) when (Host_Right_Mezz_Mux_Sel = '1' AND Right_Mezz_In.High_Valid_n = '0') else
    Inactive_Mem_In.Data_In;
  
  Host_Mem_In.Data_Valid_n <=
    Left_Mem_In.Data_Valid_n when (Host_Left_Mem_Mux_Sel = '1') else   
    Right_Mem_In.Data_Valid_n when (Host_Right_Mem_Mux_Sel = '1') else 
    (Left_Mezz_In.Low_Valid_n AND Left_Mezz_In.High_Valid_n) when (Host_Left_Mezz_Mux_Sel = '1') else  
    (Right_Mezz_In.Low_Valid_n AND Right_Mezz_In.High_Valid_n) when (Host_Right_Mezz_Mux_Sel = '1') else
    Inactive_Mem_In.Data_Valid_n;

  ARM_Mem_In.Data_In <=
    Left_Mem_In.Data_In when (ARM_Left_Mem_Mux_Sel = '1') else
    Right_Mem_In.Data_In when (ARM_Right_Mem_Mux_Sel = '1') else
    Left_Mezz_In.Data_In(31 downto 0) when (ARM_Left_Mezz_Mux_Sel = '1' AND Left_Mezz_In.Low_Valid_n = '0') else
    Left_Mezz_In.Data_In(63 downto 32) when (ARM_Left_Mezz_Mux_Sel = '1' AND Left_Mezz_In.High_Valid_n = '0') else
    Right_Mezz_In.Data_In(31 downto 0) when (ARM_Right_Mezz_Mux_Sel = '1' AND Right_Mezz_In.Low_Valid_n = '0') else
    Right_Mezz_In.Data_In(63 downto 32) when (ARM_Right_Mezz_Mux_Sel = '1' AND Right_Mezz_In.High_Valid_n = '0') else
    Inactive_Mem_In.Data_In;

  ARM_Mem_In.Data_Valid_n <=
    Left_Mem_In.Data_Valid_n when (ARM_Left_Mem_Mux_Sel = '1') else
    Right_Mem_In.Data_Valid_n when (ARM_Right_Mem_Mux_Sel = '1') else
    (Left_Mezz_In.Low_Valid_n AND Left_Mezz_In.High_Valid_n) when (ARM_Left_Mezz_Mux_Sel = '1') else
    (Right_Mezz_In.Low_Valid_n AND Right_Mezz_In.High_Valid_n) when (ARM_Right_Mezz_Mux_Sel = '1') else
    Inactive_Mem_In.Data_Valid_n;

  ----------------------------------------------------------------------
  -- 
  --  Multiplex the LAD data lines.
  --
  ----------------------------------------------------------------------

  Inactive_LAD_Bus_Out.Data_Out <= ( others => '0' );
  Inactive_LAD_Bus_Out.Int_Req_n <= '1';
  Inactive_LAD_Bus_Out.DMA_Stat <= ( others => '0' );

  LAD_Bus_Out <= 
    Host_Mem_LAD_Bus_Out when ( Host_Mem_LAD_Bus_OE_n = '0' ) else
    Stat_Reg_LAD_Bus_Out when ( Stat_Reg_LAD_Bus_OE_n = '0' ) else
    Inactive_LAD_Bus_Out;
                 

  ----------------------------------------------------------------------
  -- 
  --  Tie the left and right on-board memory strobe signals to the LEDs
  --
  ----------------------------------------------------------------------
  LEDs_Out.Red_n <= not nWAIT;
  LEDs_Out.Green_n <= not ARM_STOP;

  ----------------------------------------------------------------------
  --
  --  Below are all of the standard PE pad interface components. Simply
  --  uncomment the interface(s) that are needed by the PE design.  All
  --  other unused interfaces may remain commented out.  Be sure to
  --  uncomment any signal declarations used by the interface.
  --
  ----------------------------------------------------------------------

  U_Clocks : Clock_Std_IF
    generic map
    (
      M_CLK_DLL_TYPE  => LOW_FREQ,
      P_CLK_DLL_TYPE  => LOW_FREQ,
      U_CLK_DLL_TYPE  => NONE
    )
    port map
    (
      Pads    => Pads.Clocks,
      User_In => Clocks_In
    );

  U_LAD_Bus : LAD_Bus_Std_IF
    port map
    (
      K_Clk         => Clocks_In.K_Clk,
      Global_Reset  => Global_Reset,
      Pads          => Pads.LAD_Bus,
      User_In       => LAD_Bus_In,
      User_Out      => LAD_Bus_Out
    );

  U_LEDs : LED_Std_IF
    port map
    (
      Pads          => Pads.LEDs,
      User_Out      => LEDs_Out
    );

  U_Left_Mem : Mem_Std_IF
    generic map
    (
      INFF_Delay    => NODELAY,
      OBUF_Drive    => SLOW_12mA
    )
    port map
    (
      M_Clk         => Clocks_In.M_Clk,
      Global_Reset  => Global_Reset,
      Pads          => Pads.Left_Mem,
      User_In       => Left_Mem_In,
      User_Out      => Left_Mem_Out
    );

  U_Right_Mem : Mem_Std_IF
    generic map
    (
      INFF_Delay    => NODELAY,
      OBUF_Drive    => SLOW_12mA
    )
    port map
    (
      M_Clk         => Clocks_In.M_Clk,
      Global_Reset  => Global_Reset,
      Pads          => Pads.Right_Mem,
      User_In       => Right_Mem_In,
      User_Out      => Right_Mem_Out
    );

  U_Left_Mezz_Mem : Mezz_Mem_Std_IF
    generic map
    (
      INFF_Delay    => NODELAY,
      OBUF_Drive    => SLOW_12mA
    )
    port map
    (
      M_Clk         => Clocks_In.M_Clk,
      Global_Reset  => Global_Reset,
      Pads          => Pads.Mezz.Left,
      User_In       => Left_Mezz_In,
      User_Out      => Left_Mezz_Out
    );

  U_Right_Mezz_Mem : Mezz_Mem_Std_IF
    generic map
    (
      INFF_Delay    => NODELAY,
      OBUF_Drive    => SLOW_12mA
    )
    port map
    (
      M_Clk         => Clocks_In.M_Clk,
      Global_Reset  => Global_Reset,
      Pads          => Pads.Mezz.Right,
      User_In       => Right_Mezz_In,
      User_Out      => Right_Mezz_Out
    );

--  U_PE0_Bus : PE0_Bus_Std_IF
--    generic map
--    (
--      INFF_Delay    => NODELAY,
--      OBUF_Drive    => FAST_8mA
--    )
--    port map
--    (
--      Clk           => Clocks_In.M_Clk,
--      Global_Reset  => Global_Reset,
--      Pads          => Pads.PE0_Bus,
--      User_In       => PE0_Bus_In,
--      User_Out      => PE0_Bus_Out
--    );
--
--  U_Top_Sys : Systolic_Std_IF
--    generic map
--    (
--      INFF_Delay    => NODELAY,
--      OBUF_Drive    => FAST_8mA
--    )
--    port map
--    (
--      Clk           => Clocks_In.M_Clk,
--      Global_Reset  => Global_Reset,
--      Pads          => Pads.Top_Sys,
--      User_In       => Top_Sys_In,
--      User_Out      => Top_Sys_Out
--    );
--
--  U_Bot_Sys : Systolic_Std_IF
--    generic map
--    (
--      INFF_Delay    => NODELAY,
--      OBUF_Drive    => FAST_8mA
--    )
--    port map
--    (
--      Clk           => Clocks_In.M_Clk,
--      Global_Reset  => Global_Reset,
--      Pads          => Pads.Bot_Sys,
--      User_In       => Bot_Sys_In,
--      User_Out      => Bot_Sys_Out
--    );

  ----------------------------------------------------------------------
  --
  --  Global reset interface : Attach the Reset_Register signal to a
  --  register bit of a LAD bus accessible register.  This reset
  --  mechanism generates a one K_Clk cycle long pulse to the GSR line
  --  of the STARTUP block.  The STARTUP block is also synchronous to
  --  K_Clk.
  --
  ----------------------------------------------------------------------
  U_Reset_Pulse_Gen : One_Shot
    port map
    (
      Clk  => Clocks_In.K_Clk,
      I    => Reset_Register,
      O    => Global_Reset
    );

--   changing from STARTUP_VIRTEX_ALL
--  U_Startup : STARTUP_VIRTEX
--    port map
--    (
--      GSR => Global_Reset,
--      GTS => GND,
--      CLK => Clocks_In.K_Clk
--    );

  ----------------------------------------------------------------------
  --  NOTE :  The following line must remain in all designs
  --          to ensure that all of the PE pads are driven.
  ----------------------------------------------------------------------
  Init_PEX_Pads ( Pads );

end Mem_Copy;

