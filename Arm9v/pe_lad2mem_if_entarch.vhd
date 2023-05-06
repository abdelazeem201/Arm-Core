------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : LAD_To_Mem_Std_IF
--
--  Architecture  : Standard_256
--
--  Filename      : pe_lad2mem_if_entarch.vhd
--
--  Date          : 6/23/99
--
--  Description   : Models a pre-fetch/store buffer that when accessed
--                  from the LAD bus will perform memory access. During
--                  a write to memory, the data is read from the DPM 
--                  buffer and written to memory.  During a read from 
--                  memory, the data is read from the memory and written
--                  to the DPM buffer.  The host then reads from the
--                  DPM buffer.
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
--  Generic Name          Description
--  ====================  ==============================================
--  LAD_ADDR_BASE         LAD bus address base used to select device
--  LAD_ADDR_MASK         LAD bus address mask used to select device
--
--  Port Name             Width   Dir   Description
--  ====================  =====   ===   ================================
--  Global_Reset            1      I    Global reset signal
--  Clocks_In.M_Clk         1      I    Memory clock
--  Clocks_In.P_Clk         1      I    Processor clock
--  Clocks_In.K_Clk         1      I    LAD-bus clock
--  Clocks_In.U_Clk         1      I    User clock
--  Clocks_In.M_Clk_Locked  1      I    M_Clk CLKDLL locked flag
--  Clocks_In.P_Clk_Locked  1      I    P_Clk CLKDLL locked flag
--  Clocks_In.K_Clk_Locked  1      I    K_Clk CLKDLL locked flag
--  Clocks_In.U_Clk_Locked  1      I    U_Clk CLKDLL locked flag
--  LAD_Bus_In.Addr        23      I    LAD bus address bus input
--  LAD_Bus_In.Data_In     32      I    LAD bus data bus input
--  LAD_Bus_In.Reg_Strobe_n 1      I    LAD bus register access strobe
--  LAD_Bus_In.Mem_Strobe_n 1      I    LAD bus memory access strobe
--  LAD_Bus_In.Write_Sel_n  1      I    LAD bus write select
--  LAD_Bus_In.DMA_Chan     2      I    LAD bus DMA channel number
--  LAD_Bus_Out.Data_Out   32      O    LAD bus data bus output
--  LAD_Bus_In.Int_Req_n    1      O    LAD bus interrupt request
--  LAD_Bus_Out.DMA_Stat    2      O    LAD bus DMA channel status flags
--  LAD_Data_OE_n           1      O    LAD bus data bus output enable
--  Mem_Data_In            32      I    Memory input data bus
--  Mem_Data_Valid_n        1      I    Memory data input valid flag
--  Mem_Addr               20      O    Memory address bus
--  Mem_Data_Out           32      O    Memory output data bus
--  Mem_Strobe_n            1      O    Memory access strobe
--  Mem_Write_Sel_n         1      O    Memory write select
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, SYSTEM;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use WORK.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity LAD_To_Mem_Std_IF is
  port
  (
    Global_Reset      : in    std_logic;
    Clocks_In         : in    Clock_Std_IF_In_Type;
    LAD_Bus_In        : in    LAD_Bus_Std_IF_In_Type;
    LAD_Bus_Out       :   out LAD_Bus_Std_IF_Out_Type;
    LAD_Bus_OE_n      :   out std_logic;
    Mem_Data_In       : in    std_logic_vector(31 downto 0);
    Mem_Data_Valid_n  : in    std_logic;
    Mem_Addr          :   out std_logic_vector (19 downto 0);
    Mem_Data_Out      :   out std_logic_vector(31 downto 0);
    Mem_Strobe_n      :   out std_logic;
    Mem_Write_Sel_n   :   out std_logic
  );
  constant ADDR_MASK : std_logic_vector (11 downto 8) := x"F";
  constant DPM_ADDR_BASE : std_logic_vector (11 downto 8) := x"1";
  constant REG_ADDR_BASE : std_logic_vector (11 downto 8) := x"0";
end LAD_To_Mem_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Standard_256 of LAD_To_Mem_Std_IF is

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
  --  Name                          Description
  --  =========================     ======================================
  --
  ----------------------------------------------------------------------

  signal Reg_Base_Addr_Sel : std_logic;
  signal DPM_Base_Addr_Sel : std_logic;

  signal K_Req : std_logic;
  signal K_Req_d : std_logic;
  signal K_Req_Pulse : std_logic;
  signal K_DPM_Offset : std_logic_vector(7 downto 0);
  signal K_Mem_Addr : std_logic_vector(19 downto 0);
  signal K_Mem_Write_Sel_n : std_logic;
  signal K_Count : std_logic_vector(8 downto 0);
  signal K_Reg_Read : std_logic;
  signal K_Read : std_logic;
  signal K_Done : std_logic;
  signal K_Ack : std_logic;
  signal K_Ack_d : std_logic;
  signal K_Ack_dd : std_logic;
  signal K_Ack_ddd : std_logic;
  signal K_Ack_Pulse : std_logic;
  signal K_DPM_Addr : std_logic_vector(7 downto 0);
  signal K_DPM_Data_In : std_logic_vector(31 downto 0);
  signal K_DPM_Data_Out : std_logic_vector(31 downto 0);
  signal K_DPM_WE : std_logic;
  signal K_DPM_CE : std_logic;
  signal K_CLK : std_logic;

  signal M_Req : std_logic;
  signal M_Req_d : std_logic;
  signal M_Req_dd : std_logic;
  signal M_Req_ddd : std_logic;
  signal M_Req_Pulse : std_logic;
  signal M_DPM_Offset : std_logic_vector(7 downto 0);
  signal M_Count : std_logic_vector(8 downto 0);
  signal M_Ack : std_logic;
  signal M_Busy : std_logic;
  signal M_Busy_d : std_logic;
  signal M_Busy_dd : std_logic;
  signal M_DPM_Addr : std_logic_vector(7 downto 0);
  signal M_DPM_Data_In : std_logic_vector(31 downto 0);
  signal M_DPM_Data_Out : std_logic_vector(31 downto 0);
  signal M_DPM_WE : std_logic;
  signal M_DPM_CE : std_logic;
  signal M_Mem_Data_In : std_logic_vector(31 downto 0);
  signal M_Mem_Data_Valid_n : std_logic;
  signal M_Mem_Addr : std_logic_vector(19 downto 0);
  signal M_Mem_Strobe_n : std_logic;
  signal M_Mem_Write_Sel_n : std_logic;
  signal M_CLK : std_logic;

begin
  -- Covert the Generics back to std_logic_vectors
  


  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  K-clock side logic
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------
  --
  --  LAD bus output signals
  --
  ----------------------------------------------------------------------
  LAD_Bus_Out.Data_Out <= 
    (0 => K_Done, others => '0') when ( K_Reg_Read = '1' )
    else K_DPM_Data_Out;

  LAD_Bus_Out.Int_Req_n <= '1';

  LAD_Bus_Out.DMA_Stat <= ( others => '0' );

  LAD_Bus_OE_n <= not K_Read;

  ----------------------------------------------------------------------
  --
  --  Decode the incoming LAD bus address to see if we are being 
  --  selected; drive the outgoing LAD data from the M_Clk-side
  --  status registers, otherwise use the block RAM output.
  --
  ----------------------------------------------------------------------

  Reg_Base_Addr_Sel <= '1' when ( ( LAD_Bus_In.Addr(ADDR_MASK'range) and 
                                    ADDR_MASK ) = REG_ADDR_BASE ) else '0';

  DPM_Base_Addr_Sel <= '1' when ( ( LAD_Bus_In.Addr(ADDR_MASK'range) and 
                                    ADDR_MASK ) = DPM_ADDR_BASE ) else '0';

  ----------------------------------------------------------------------
  --
  --  K-clocked process that is used to implement the LAD registers
  --  that are a part of this design.  The registers in this design
  --  are as follows:
  --
  --      Addr  Description
  --      ----  ------------------------------------------------------
  --        0   Contains starting dual-port memory (DPM) offset and
  --            memory address
  --        1   Contains read/write control bit and DWORD count
  --        2   Reserved
  --        3   "Start" bit control register: any write to this address
  --            will initiate a DPM/memory transfer
  --
  ----------------------------------------------------------------------
  K_CLK <= Clocks_In.K_Clk;
  K_LAD_Regs : process ( Global_Reset, K_CLK )
  begin
    if ( Global_Reset = '1' ) then

      K_DPM_Offset <= ( others => '0' );
      K_Mem_Addr <= ( others => '0' );
      K_Mem_Write_Sel_n <= '1';
      K_Count <= ( others => '0' );
      K_Req <= '0';

      K_Reg_Read <= '0';
      K_Read <= '0';

    elsif ( rising_edge ( K_CLK ) ) then

      K_Reg_Read <= '0';

      if ( ( LAD_Bus_In.Reg_Strobe_n = '0' ) and
           ( Reg_Base_Addr_Sel = '1' ) ) then
        if ( LAD_Bus_In.Write_Sel_n = '0' ) then
          case LAD_Bus_In.Addr(1 downto 0) is
            when "00" =>
              K_DPM_Offset <= LAD_Bus_In.Data_In(30 downto 23);
              K_Mem_Addr <= LAD_Bus_In.Data_In(19 downto 0);
            when "01" =>
              K_Mem_Write_Sel_n <= LAD_Bus_In.Data_In(20);
              K_Count <= LAD_Bus_In.Data_In(8 downto 0);
            when "11" =>
              K_Req <= not K_Req;
            when others =>
              NULL;
          end case;
        --
        --  If any read is performed to this register
        --  portion of this unit, set the K_Reg_Read
        --  status bit
        --
        elsif ( LAD_Bus_In.Write_Sel_n = '1' ) then
          K_Reg_Read <= '1';
        end if;
      end if;

      --
      --  If any read is performed to the register *or*
      --  DPM portion of this unit, set the K_Read 
      --  status bit
      --
      if ( ( ( LAD_Bus_In.Reg_Strobe_n = '0' ) and
             ( LAD_Bus_In.Write_Sel_n = '1' ) ) and
           ( ( Reg_Base_Addr_Sel = '1' ) or
             ( DPM_Base_Addr_Sel = '1' ) ) ) then
        K_Read <= '1';
      else
        K_Read <= '0';
      end if;

    end if;
  end process;

  ----------------------------------------------------------------------
  --
  --  K-clocked process that is used to implement the DPM/memory
  --  transfer status.  The transfer is said to be "done" when an
  --  acknowledgement is received from the M_Clk-side.  The transfer
  --  is said to be "not done" when a new request is received from
  --  the host.  The done status bit starts off as "not done".
  --
  ----------------------------------------------------------------------
  K_Req_Pulse <= K_Req xor K_Req_d;
  K_Ack_Pulse <= K_Ack_dd xor K_Ack_ddd;

  K_Status : process ( Global_Reset, K_CLK )
  begin
    if ( Global_Reset = '1' ) then

      K_Req_d <= '0';

      K_Ack <= '0';
      K_Ack_d <= '0';
      K_Ack_dd <= '0';
      K_Ack_ddd <= '0';

      K_Done <= '0';

    elsif ( rising_edge ( K_CLK ) ) then

      K_Req_d <= K_Req;

      --
      --  NOTE: Three levels of registers are used
      --  to handle multi-clock meta-stability 
      --  design issues.
      --
      K_Ack <= M_Ack;
      K_Ack_d <= K_Ack;
      K_Ack_dd <= K_Ack_d;
      K_Ack_ddd <= K_Ack_dd;

      if ( K_Req_Pulse = '1' ) then
        K_Done <= '0';
      elsif ( K_Ack_Pulse = '1' ) then
        K_Done <= '1';
      end if;

    end if;
  end process;



  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  M-clock side logic
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  M_Req_Pulse <= M_Req_dd xor M_Req_ddd;

  ----------------------------------------------------------------------
  --
  --  M-clocked process that handles the control of the DPM and memory
  --  interfaces.
  --
  ----------------------------------------------------------------------
  M_CLK <= Clocks_In.M_Clk;
  M_Control : process ( Global_Reset, M_CLK )
  begin
    if ( Global_Reset = '1' ) then

      M_Ack <= '0';

      M_Busy <= '0';
      M_Count <= ( others => '0' );

      M_DPM_CE <= '0';
      M_DPM_Offset <= ( others => '0' );

      M_Mem_Write_Sel_n <= '1';
      M_Mem_Strobe_n <= '1';
      M_Mem_Addr <= ( others => '0' );

    elsif ( rising_edge ( M_CLK ) ) then

      --
      --  Acknowledge the DPM/memory access when
      --  the M-clock side becomes "not busy"
      --
      if ( ( M_Busy_d = '0' ) and
           ( M_Busy_dd = '1' ) ) then
        M_Ack <= not M_Ack;
      end if;

      --
      --  If a request is received from the K-clocked
      --  side, load the DPM/memory control registers
      --
      if ( M_Req_Pulse = '1' ) then

        M_Busy <= '0';
        M_Count <= K_Count;

        M_DPM_CE <= '0';
        M_DPM_Offset <= K_DPM_Offset;

        M_Mem_Write_Sel_n <= K_Mem_Write_Sel_n;
        M_Mem_Strobe_n <= '1';
        M_Mem_Addr <= K_Mem_Addr;

      else

        --
        --  If the DWORD count is non-zero,
        --  then the control interface is said
        --  to be "busy", otherwise it is "not
        --  busy"
        --
        if ( M_Count /= "000000000" ) then
          M_Count <= M_Count - 1;
          M_Busy <= '1';
        else
          M_Busy <= '0';
        end if;

        --
        --  In the case of a memory write access,
        --  the data is first read out of the DPM,
        --  then it is written to the memory.
        --
        if ( M_Mem_Write_Sel_n = '0' ) then

          M_DPM_CE <= M_Busy;

          if ( M_Busy_d = '1' ) then
            M_DPM_Offset <= M_DPM_Offset + 1;
          end if;

          M_Mem_Strobe_n <= not M_Busy_d;

          if ( M_Busy_dd = '1' ) then
            M_Mem_Addr <= M_Mem_Addr + 1;
          end if;

        --
        --  In the case of a memory read access,
        --  the data is first read out of the 
        --  memory, then it is written to the DPM
        --  as it becomes available from the
        --  memory interface pipeline.
        --
        elsif ( M_Mem_Write_Sel_n = '1' ) then

          M_Mem_Strobe_n <= not M_Busy;

          if ( M_Busy_d = '1' ) then
            M_Mem_Addr <= M_Mem_Addr + 1;
          end if;

          M_DPM_CE <= not Mem_Data_Valid_n;

          if ( M_Mem_Data_Valid_n = '0' ) then
            M_DPM_Offset <= M_DPM_Offset + 1;
          end if;

        end if;

      end if;

    end if;
  end process;

  ----------------------------------------------------------------------
  --
  --  M-clocked process that handles the implementation of the
  --  necessary delay registers needed by the control interface.
  --
  ----------------------------------------------------------------------
  M_Delay : process ( Global_Reset, M_CLK )
  begin
    if ( Global_Reset = '1' ) then

      M_Req <= '0';
      M_Req_d <= '0';
      M_Req_dd <= '0';
      M_Req_ddd <= '0';

      M_Busy_d <= '0';
      M_Busy_dd <= '0';

      M_Mem_Data_In <= ( others => '0' );
      M_Mem_Data_Valid_n <= '1';

      Mem_Addr <= (  Mem_Addr'range => '0' );
      Mem_Data_Out <= ( others => '0' );
      Mem_Strobe_n <= '1';
      Mem_Write_Sel_n <= '1';

    elsif ( rising_edge ( M_CLK ) ) then

      --
      --  NOTE: Three levels of registers are used
      --  to handle multi-clock meta-stability 
      --  design issues.
      --
      M_Req <= K_Req;
      M_Req_d <= M_Req;
      M_Req_dd <= M_Req_d;
      M_Req_ddd <= M_Req_dd;

      M_Busy_d <= M_Busy;
      M_Busy_dd <= M_Busy_d;

      M_Mem_Data_In <= Mem_Data_In;
      M_Mem_Data_Valid_n <= Mem_Data_Valid_n;

      Mem_Addr <= M_Mem_Addr;
      Mem_Data_Out <= M_DPM_Data_Out;
      Mem_Strobe_n <= M_Mem_Strobe_n;
      Mem_Write_Sel_n <= M_Mem_Write_Sel_n;

    end if;
  end process;


  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  Dual-ported block RAM : Used to buffer incoming and outgoing data
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  K_DPM_Addr <= LAD_Bus_In.Addr(7 downto 0);
  K_DPM_Data_In <= LAD_Bus_In.Data_In;
  K_DPM_WE <= not LAD_Bus_In.Write_Sel_n;
  K_DPM_CE <= ( not LAD_Bus_In.Reg_Strobe_n ) and DPM_Base_Addr_Sel;

  M_DPM_Addr <= M_DPM_Offset;
  M_DPM_Data_In <= M_Mem_Data_In;
  M_DPM_WE <= not M_Mem_Data_Valid_n;

  U_RAMB : RAMB_256x32_DP
    port map
    (
      addra => K_DPM_Addr,
      addrb => M_DPM_Addr,
      dia   => K_DPM_Data_In,
      dib   => M_DPM_Data_In,
      clka  => K_CLK,
      clkb  => M_CLK,
      wea   => K_DPM_WE,
      web   => M_DPM_WE,
      ena   => K_DPM_CE,
      enb   => M_DPM_CE,
      rsta  => Global_Reset,
      rstb  => Global_Reset,
      doa   => K_DPM_Data_Out,
      dob   => M_DPM_Data_Out
    );

end Standard_256;

