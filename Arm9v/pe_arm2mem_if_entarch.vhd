------------------------------------------------------------------------
--
--  Entity        : ARM_To_Mem_Std_IF
--
--  Architecture  : Standard_256
--
--  Filename      : pe_arm2mem_if_entarch.vhd
--
--  Date          : 3/13/00
--
--  Description   : Models a pre-fetch/store buffer that when accessed
--                  from the ARM MM bus will perform memory access. During
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
--  MMD_Data_In            32      I    ARM Input Data Bus
--  MMD_Data_Out           32      O    ARM Output Data Bus
--  MMnWR                   1      I    ARM Read/Write Select
--  MM_CE                   1      I    ARM Memory Enable
--  MM_New_Line             1      I    ARM Start Memory Access
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

entity ARM_To_Mem_Std_IF is
  port
  (
    Global_Reset      : in    std_logic;
    Clocks_In         : in    Clock_Std_IF_In_Type;
    MMA		      : in    std_logic_vector(31 downto 0);
    MMD_Data_In	      : in    std_logic_vector(31 downto 0);
    MMD_Data_Out      :   out std_logic_vector(31 downto 0);
    MMnWR	      : in    std_logic;
    MM_CE	      : in    std_logic;
    MM_New_Line       : in    std_logic;
    Mem_Data_In       : in    std_logic_vector(31 downto 0);
    Mem_Data_Valid_n  : in    std_logic;
    Mem_Addr          :   out std_logic_vector (19 downto 0);
    Mem_Data_Out      :   out std_logic_vector(31 downto 0);
    Mem_Strobe_n      :   out std_logic;
    Mem_Write_Sel_n   :   out std_logic
  );
end ARM_To_Mem_Std_IF;

------------------------ Architecture Declaration ----------------------

architecture Standard_256 of ARM_To_Mem_Std_IF is

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

  signal U_Req : std_logic;
  signal U_Req_d : std_logic;
  signal U_Req_Pulse : std_logic;
  signal U_DPM_Offset : std_logic_vector(7 downto 0);
  signal U_Mem_Addr : std_logic_vector(19 downto 0);
  signal U_Mem_Write_Sel_n : std_logic;
  signal U_Count : std_logic_vector(8 downto 0);
  signal U_Done : std_logic;
  signal U_Ack : std_logic;
  signal U_Ack_d : std_logic;
  signal U_Ack_dd : std_logic;
  signal U_Ack_ddd : std_logic;
  signal U_Ack_Pulse : std_logic;
  signal U_DPM_Addr : std_logic_vector(7 downto 0);
  signal U_DPM_Data_In : std_logic_vector(31 downto 0);
  signal U_DPM_Data_Out : std_logic_vector(31 downto 0);
  signal U_DPM_WE : std_logic;
  signal U_DPM_CE : std_logic;
  signal P_CLK : std_logic;

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

  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  --
  --  U-clock side logic
  --
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  ----------------------------------------------------------------------
  --
  --  U-clocked process that is used to implement the ARM registers
  --  that are a part of this design.  The registers in this design
  --  are as follows:
  --
  --      Name          Description
  --      ----          ------------------------------------------------
  --      U_DPM_Addr	DPM Address (For Accessing the DPM)
  --      U_DPM_Offset  DPM Address (For Starting the M-Side)
  --      U_Mem_Addr    Mem Address (only use 19 bits, but is 20 long)
  --      U_Mem_Wr...   Write Select (write=0, read=1)
  --      U_Count       Words to Transfer (= cache line size (8))
  --      U_Req         Start Memory Transfer
  --
  ----------------------------------------------------------------------
  P_CLK <= Clocks_In.U_Clk;
  U_ARM_Regs : process ( Global_Reset, P_CLK )
  begin
    if ( Global_Reset = '1' ) then

      U_DPM_Addr <= (others => '0' );
      U_DPM_Offset <= ( others => '0' );
      U_Mem_Addr <= ( others => '0' );
      U_Mem_Write_Sel_n <= '1';
      U_Count <= ( others => '0' );
      U_Req <= '0';

    elsif ( rising_edge ( P_CLK ) ) then

      U_DPM_Addr <= MMA (9 downto 2);

      if ( ( MM_New_Line = '1' ) ) then
  
        U_Count <= "000001000";
        U_Req <= not U_Req;
	  U_Mem_Write_Sel_n <= MMnWR;
	  U_Mem_Addr <= MMA (21 downto 2);
	  U_DPM_Offset <= MMA (9 downto 2);

      end if;

    end if;

  end process;

  ----------------------------------------------------------------------
  --
  --  U-clocked process that is used to implement the DPM/memory
  --  transfer status.  The transfer is said to be "done" when an
  --  acknowledgement is received from the M_Clk-side.  The transfer
  --  is said to be "not done" when a new request is received from
  --  the host.  The done status bit starts off as "not done".
  --
  ----------------------------------------------------------------------
  U_Req_Pulse <= U_Req xor U_Req_d;
  U_Ack_Pulse <= U_Ack_dd xor U_Ack_ddd;

  U_Status : process ( Global_Reset, P_CLK )
  begin
    if ( Global_Reset = '1' ) then

      U_Req_d <= '0';

      U_Ack <= '0';
      U_Ack_d <= '0';
      U_Ack_dd <= '0';
      U_Ack_ddd <= '0';

      U_Done <= '0';

    elsif ( rising_edge ( P_CLK ) ) then

      U_Req_d <= U_Req;

      --
      --  NOTE: Three levels of registers are used
      --  to handle multi-clock meta-stability 
      --  design issues.
      --
      U_Ack <= M_Ack;
      U_Ack_d <= U_Ack;
      U_Ack_dd <= U_Ack_d;
      U_Ack_ddd <= U_Ack_dd;

      if ( U_Req_Pulse = '1' ) then
        U_Done <= '0';
      elsif ( U_Ack_Pulse = '1' ) then
        U_Done <= '1';
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
        M_Count <= U_Count;

        M_DPM_CE <= '0';
        M_DPM_Offset <= U_DPM_Offset;

        M_Mem_Write_Sel_n <= U_Mem_Write_Sel_n;
        M_Mem_Strobe_n <= '1';
        M_Mem_Addr <= U_Mem_Addr;

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
      M_Req <= U_Req;
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
  U_DPM_Data_In <= MMD_Data_In;
  U_DPM_WE <= not MMnWR;
  U_DPM_CE <= MM_CE;

  M_DPM_Addr <= M_DPM_Offset;
  M_DPM_Data_In <= M_Mem_Data_In;
  M_DPM_WE <= not M_Mem_Data_Valid_n;

  U_RAMB : RAMB_256x32_DP
    port map
    (
      addra => U_DPM_Addr,
      addrb => M_DPM_Addr,
      dia   => U_DPM_Data_In,
      dib   => M_DPM_Data_In,
      clka  => P_CLK,
      clkb  => M_CLK,
      wea   => U_DPM_WE,
      web   => M_DPM_WE,
      ena   => U_DPM_CE,
      enb   => M_DPM_CE,
      rsta  => Global_Reset,
      rstb  => Global_Reset,
      doa   => MMD_Data_Out,
      dob   => M_DPM_Data_Out
    );

end Standard_256;

