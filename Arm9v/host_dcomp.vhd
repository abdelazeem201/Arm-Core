------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : Host
--
--  Architecture  : Mem_Copy
--
--  Filename      : host_mem_copy_arch.vhd
--
--  Date          : 9/3/99
--
--  Description   : This host program is used to write/read values 
--                  to/from the PE1 on-board memories.
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
--  Cmd_Req                 1      O    Command request flag
--  Cmd_Ack                 1      I    Command acknowledge flag
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library SYSTEM;
use SYSTEM.Host_Package.all;

------------------------ Architecture Declaration ----------------------

architecture Mem_Copy of Host is

begin

  --------------------------------------------------------
  --
  --  Below is an example of how to use host "API"
  --  functions to send commands to the WILDSTAR(tm)
  --  board.  Copy this file to your project directory
  --  and modify it to simulate the behavior of the
  --  host portion of your application.
  --
  --------------------------------------------------------
  main : process
    --------------------------------------------------------------------
    --
    --  Below are variables used by the simulated host API functions.
    --  Simply uncomment the variable(s) that are needed by the API 
    --  functions.  All other unused variables may remain commented
    --  out.
    --
    --------------------------------------------------------------------
    variable board        : WS_BoardNum := 0;
    variable enable       : boolean := FALSE;
    variable memInitFile  : string ( 1 to 12 ) := "mem_init.dat";
    variable memDumpFile  : string ( 1 to 12 ) := "mem_dump.dat";
    variable memBank      : Mem_Bank_Type;
    variable mClkSource   : WS_CLOCK_SOURCE := PROG_OSCILLATOR;
    variable mClkFreq     : float := 50.0;
    variable pClkDivisor  : DWORD := 1;
    variable uClkSource   : WS_CLOCK_SOURCE := PROG_OSCILLATOR;
    variable uClkFreq     : float := 50.0;
    variable peNum        : DWORD;
    variable dwordOffset  : DWORD;
    variable dwordCount   : DWORD;
    variable memData      : DWORD_array ( 0 to 255 );
    variable regData      : DWORD_array ( 0 to 255 );
    variable Done         : boolean;
  begin

    --
    --  At first, deassert the command request signal
    --
    Cmd_Req <= FALSE;

    --------------------------------------------------------------------
    --
    --  Below are example simulated host API function calls. Simply
    --  uncomment the function(s) that are needed by the application.
    --  All other unused function calls may remain commented out.  Be
    --  sure to uncomment any variables used by the API functions.
    --
    --------------------------------------------------------------------
    --
    --  Print the version of the VHDL model
    --
    Debug_Print_Version( Cmd_Req,
                         Cmd_Ack );

    --
    --  We are using board 0
    --
    board := 0;

    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    --
    --  Step  1 : Initialize the simulated on-board memories.  Note
    --            that we use the shortcut "debug" functions to do this
    --            since it would take too long to do it over the LAD
    --            bus.
    --
    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    --
    --  Load memory banks from file, where memBank
    --  can be one of the following:
    --
    --    PE1_LEFT_MEM_BANK
    --    PE1_RIGHT_MEM_BANK
    --    PE1_LEFT_MEZZ_MEM0_BANK
    --    PE1_LEFT_MEZZ_MEM1_BANK
    --    PE1_RIGHT_MEZZ_MEM0_BANK
    --    PE1_RIGHT_MEZZ_MEM1_BANK
    --
    memBank := PE1_LEFT_MEM_BANK;
    Debug_Load_Mem_From_File ( Cmd_Req,
                               Cmd_Ack,
                               "mem_init.dat",
                               board,
                               memBank );

    memBank := PE1_RIGHT_MEM_BANK;
    Debug_Load_Mem_From_File ( Cmd_Req,
                               Cmd_Ack,
                               "mem_init.dat",
                               board,
                               memBank );

    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    --
    --  Step  2 : Configure the memory clock and processing element
    --            clock.
    --
    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    --
    --  Set up M_Clk and P_Clk, where mClkSource
    --  can be PROG_OSCILLATOR, EXT_IO_0, EXT_IO_1,
    --  or BACK_PLANE and pClkDivisor can be from 1 
    --  to 16.
    --
    mClkSource := PROG_OSCILLATOR;
    mClkFreq := 80.0;
    pClkDivisor := 8;
    uClkFreq := 5.0;
    uClkSource := PROG_OSCILLATOR;
    WS_MClkSetConfig ( Cmd_Req,
                       Cmd_Ack,
                       board,
                       mClkSource,
                       mClkFreq,
                       pClkDivisor );

    WS_UClkSetConfig ( Cmd_Req,
		       Cmd_Ack,
 		       board,
		       uClkSource,
		       uClkFreq );

    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    --
    --  Step  3 : Reset each of the PEs by writing to their reset
    --            registers that are mapped to LAD bus register space
    --            DWORD address 0x01000 in their respective PEs.
    --
    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    --
    --  Reset the PE1 device
    --
    peNum := WS_PE1;
    dwordOffset := 16#00000800#; -- Reset register
    dwordCount := 1;
    regData(0) := 1;
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    assert FALSE
      report "============ All PEs are now reset ============"
      severity NOTE;

    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    --
    --  Step  4 : Write 256 words to PE1's left on-board memory, 
    --            starting at address 0.  This is accomplished by 
    --            performing the following tasks:
    --
    --              1. Set the memory mux select to the host setting.
    --              2. Fill the block RAM buffer with the data that is
    --                 to be written to the memory.
    --              3. Send a set of control words to the buffer
    --                 control logic that sets the block RAM buffer
    --                 offset, memory address, write command, and
    --                 DWORD count.
    --              4. Check the status register to determine when
    --                 the write operation has completed.
    --
    --
    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    --------------------------------------------------------------------
    --
    --  Select the host to be connected to the memories
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000900#; -- Control register for PE1
    dwordCount := 1;
    regData(0) := 16#00000001#;  -- Bit 0 Host/App
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Fill up the block RAM with data to be written to memory.
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 5;
      memData(0) := 16#e3a0fa01#;
      memData(1) := 16#00000000#;
      memData(2) := 16#00000000#;
      memData(3) := 16#e3a0fd09#;
      memData(4) := 16#e3a0fc02#;

    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    memData );

    --------------------------------------------------------------------
    --
    --  Write the block RAM buffer offset and memory address
    --  to the first control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- First control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#; -- Offset  : bits 31 downto 23 = 0x000
                                -- Address : bits 22 downto  0 = 0x000
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Write the memory access type and DWORD count
    --  to the second control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000001#; -- Second control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000005#; -- Write_Sel_n : bit 20          = 0
                                -- DWORD count : bits 7 downto 0 = 256
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Trigger the memory write by writing to the third register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000003#; -- Third control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#;  -- Don't care
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Read the status of the memory write
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- Status register for Left Mem
    dwordCount := 1;
    Done := FALSE;
    while ( not Done ) loop
      WS_ReadPeReg ( Cmd_Req,
                     Cmd_Ack,
                     board,
                     peNum,
                     dwordOffset,
                     dwordCount,
                     regData );
      if ( regData(0) mod 2 = 1 ) then
        assert FALSE
          report "PE1 left mem bank write has completed"
          severity NOTE;
        Done := TRUE;
      end if;
      wait for 1 us;
    end loop;

    --------------------------------------------------------------------
    --
    --  Fill up the block RAM with data to be written to memory.
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 65;

      memData(0) := 16#e3a0da01#; 
      memData(1) := 16#e24dd004#; 
      memData(2) := 16#e92d0f8f#; 
      memData(3) := 16#e24ee004#; 
      memData(4) := 16#e3a0a806#; 
      memData(5) := 16#e3a0b902#; 
      memData(6) := 16#e3a07902#; 
      memData(7) := 16#ed2def01#; 
      memData(8) := 16#e49d8004#; 
      memData(9) := 16#e3c8801f#; 
      memData(10) := 16#ea00000c#; 
      memData(11) := 16#e1a00000#; 
      memData(12) := 16#e1a00000#; 
      memData(13) := 16#e1a00000#; 
      memData(14) := 16#e1a00000#; 
      memData(15) := 16#e1a00000#; 
      memData(16) := 16#e3a0da01#; 
      memData(17) := 16#e24dd004#; 
      memData(18) := 16#e92d0f8f#; 
      memData(19) := 16#e3a0a806#; 
      memData(20) := 16#e3a0b902#; 
      memData(21) := 16#e3a07902#; 
      memData(22) := 16#e24e8004#; 
      memData(23) := 16#e3c8801f#; 
      memData(24) := 16#e0489007#; 
      memData(25) := 16#e08b90a9#; 
      memData(26) := 16#e899000f#; 
      memData(27) := 16#e1a09800#; 
      memData(28) := 16#e08a7729#; 
      memData(29) := 16#ed977f00#; 
      memData(30) := 16#ece87f01#; 
      memData(31) := 16#e1a09820#; 
      memData(32) := 16#e08a7109#; 
      memData(33) := 16#ed977f00#; 
      memData(34) := 16#ece87f01#; 
      memData(35) := 16#e1a09801#; 
      memData(36) := 16#e08a7729#; 
      memData(37) := 16#ed977f00#; 
      memData(38) := 16#ece87f01#; 
      memData(39) := 16#e1a09821#; 
      memData(40) := 16#e08a7109#; 
      memData(41) := 16#ed977f00#; 
      memData(42) := 16#ece87f01#; 
      memData(43) := 16#e1a09802#;
      memData(44) := 16#e08a7729#; 
      memData(45) := 16#ed977f00#; 
      memData(46) := 16#ece87f01#; 
      memData(47) := 16#e1a09822#; 
      memData(48) := 16#e08a7109#; 
      memData(49) := 16#ed977f00#; 
      memData(50) := 16#ece87f01#; 
      memData(51) := 16#e1a09803#; 
      memData(52) := 16#e08a7729#; 
      memData(53) := 16#ed977f00#; 
      memData(54) := 16#ece87f01#; 
      memData(55) := 16#e1a09823#; 
      memData(56) := 16#e08a7109#; 
      memData(57) := 16#ed977f00#; 
      memData(58) := 16#ece87f01#; 
      memData(59) := 16#e8bd0f8f#; 
      memData(60) := 16#e25ef004#; 
      memData(61) := 16#ffffffff#; 
      memData(62) := 16#00000000#; 
      memData(63) := 16#ffffffff#; 
      memData(64) := 16#00000000#;

    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    memData );

    --------------------------------------------------------------------
    --
    --  Write the block RAM buffer offset and memory address
    --  to the first control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- First control register for Mem
    dwordCount := 1;
    regData(0) := 16#00000080#; -- Offset  : bits 31 downto 23 = 0x000
                                -- Address : bits 22 downto  0 = 0x000
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );
    
    --------------------------------------------------------------------
    --
    --  Write the memory access type and DWORD count
    --  to the second control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000001#; -- Second control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000041#; -- Write_Sel_n : bit 20          = 0
                                -- DWORD count : bits 7 downto 0 = 256
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );
    
    --------------------------------------------------------------------
    --
    --  Trigger the memory write by writing to the third register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000003#; -- Third control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#;  -- Don't care
    WS_WritePeReg ( Cmd_Req,   
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );
      
    --------------------------------------------------------------------
    --
    --  Read the status of the memory write
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- Status register for Left Mem
    dwordCount := 1;
    Done := FALSE;
    while ( not Done ) loop
      WS_ReadPeReg ( Cmd_Req,
                     Cmd_Ack,
                     board,
                     peNum,
                     dwordOffset,
                     dwordCount,
                     regData );
      if ( regData(0) mod 2 = 1 ) then
        assert FALSE
          report "PE1 Data Write to 0x1000 has completed"
          severity NOTE;
        Done := TRUE;
      end if;
      wait for 1 us;
    end loop;

    --------------------------------------------------------------------
    --
    --  Fill up the block RAM with data to be written to memory.
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 24;
      memData(0) := 16#e3a01040#; 
      memData(1) := 16#e3a02902#; 
      memData(2) := 16#e5812000#; 
      memData(3) := 16#ed912f00#; 
      memData(4) := 16#e3a02c02#; 
      memData(5) := 16#e3822003#; 
      memData(6) := 16#e5812000#; 
      memData(7) := 16#ed915f00#; 
      memData(8) := 16#ed811f00#; 
      memData(9) := 16#e5912000#; 
      memData(10) := 16#e3822a12#; 
      memData(11) := 16#e5812000#; 
      memData(12) := 16#ed911f00#; 
      memData(13) := 16#e10f2000#; 
      memData(14) := 16#e3c220ff#; 
      memData(15) := 16#e38220d0#; 
      memData(16) := 16#e129f002#; 
      memData(17) := 16#e3a0d806#; 
      memData(18) := 16#e24dd004#; 
      memData(19) := 16#e3a0f902#; 
      memData(20) := 16#ffffffff#; 
      memData(21) := 16#00000000#; 
      memData(22) := 16#ffffffff#; 
      memData(23) := 16#00000000#; 

    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    memData );

    --------------------------------------------------------------------
    --
    --  Write the memory access type and DWORD count
    --  to the second control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000001#; -- Second control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000018#; -- Write_Sel_n : bit 20          = 0
                                -- DWORD count : bits 7 downto 0 = 256
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Write the block RAM buffer offset and memory address
    --  to the first control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- First control register for Mem
    dwordCount := 1;
    regData(0) := 16#00000400#; -- Offset  : bits 31 downto 23 = 0x000
                                -- Address : bits 22 downto  0 = 0x000  
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Trigger the memory write by writing to the third register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000003#; -- Third control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#;  -- Don't care
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Read the status of the memory write
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- Status register for Left Mem
    dwordCount := 1;
    Done := FALSE;
    while ( not Done ) loop
      WS_ReadPeReg ( Cmd_Req,
                     Cmd_Ack,
                     board, 
                     peNum, 
                     dwordOffset,
                     dwordCount,
                     regData ); 
      if ( regData(0) mod 2 = 1 ) then
        assert FALSE
          report "PE1 Data write to 0x3000 has completed"
          severity NOTE;
        Done := TRUE;
      end if;
      wait for 1 us;
    end loop;

    --------------------------------------------------------------------
    --
    --  Fill up the block RAM with data to be written to memory.
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 10;
      memData(0) := 16#00010000#; 
      memData(1) := 16#00030002#;
      memData(2) := 16#00050004#; 
      memData(3) := 16#00070006#;
      memData(4) := 16#00090008#; 
      memData(5) := 16#000b000a#; 
      memData(6) := 16#000d000c#;
      memData(7) := 16#000f000e#;
      memData(8) := 16#000f0010#;
      memData(9) := 16#00000010#;

    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    memData );

    --------------------------------------------------------------------
    --
    --  Write the memory access type and DWORD count
    --  to the second control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000001#; -- Second control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#0000000a#; -- Write_Sel_n : bit 20          = 0
                                -- DWORD count : bits 7 downto 0 = 256
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Write the block RAM buffer offset and memory address
    --  to the first control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- First control register for Mem
    dwordCount := 1;
    regData(0) := 16#00002000#; -- Offset  : bits 31 downto 23 = 0x000
                                -- Address : bits 22 downto  0 = 0x000  
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Trigger the memory write by writing to the third register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000003#; -- Third control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#;  -- Don't care
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Read the status of the memory write
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- Status register for Left Mem
    dwordCount := 1;
    Done := FALSE;
    while ( not Done ) loop
      WS_ReadPeReg ( Cmd_Req,
                     Cmd_Ack,
                     board, 
                     peNum, 
                     dwordOffset,
                     dwordCount,
                     regData ); 
      if ( regData(0) mod 2 = 1 ) then
        assert FALSE
          report "PE1 Data write to 0x3000 has completed"
          severity NOTE;
        Done := TRUE;
      end if;
      wait for 1 us;
    end loop;

    --------------------------------------------------------------------
    --
    --  Fill up the block RAM with data to be written to memory.
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 17;
      memData(0) := 16#e1a0c00d#;
      memData(1) := 16#e92dd800#; 
      memData(2) := 16#e24cb004#;
      memData(3) := 16#e24dd00c#; 
      memData(4) := 16#e3a03005#; 
      memData(5) := 16#e50b3010#; 
      memData(6) := 16#e59f3014#;
      memData(7) := 16#e50b3014#; 
      memData(8) := 16#e51b3010#;
      memData(9) := 16#e51b2014#; 
      memData(10) := 16#e0833002#; 
      memData(11) := 16#e50b3018#;
      memData(12) := 16#ea000000#;
      memData(13) := 16#41b47fa5#;
      memData(14) := 16#391ba800#; 
      memData(15) := 16#ffffffff#;
      memData(16) := 16#00000000#;

    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    memData );

    --------------------------------------------------------------------
    --
    --  Write the memory access type and DWORD count
    --  to the second control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000001#; -- Second control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000011#; -- Write_Sel_n : bit 20          = 0
                                -- DWORD count : bits 7 downto 0 = 256
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Write the block RAM buffer offset and memory address
    --  to the first control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- First control register for Mem
    dwordCount := 1;
    regData(0) := 16#00018000#; -- Offset  : bits 31 downto 23 = 0x000
                                -- Address : bits 22 downto  0 = 0x000  
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Trigger the memory write by writing to the third register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000003#; -- Third control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#;  -- Don't care
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Read the status of the memory write
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- Status register for Left Mem
    dwordCount := 1;
    Done := FALSE;
    while ( not Done ) loop
      WS_ReadPeReg ( Cmd_Req,
                     Cmd_Ack,
                     board, 
                     peNum, 
                     dwordOffset,
                     dwordCount,
                     regData ); 
      if ( regData(0) mod 2 = 1 ) then
        assert FALSE
          report "PE1 Data write to 0x3000 has completed"
          severity NOTE;
        Done := TRUE;
      end if;
      wait for 1 us;
    end loop;

    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    --
    --  Step  6 : Reset each of the PEs by writing to their reset
    --            registers that are mapped to LAD bus register space
    --            DWORD address 0x01000 in their respective PEs.
    --
    --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                       
    --
    --  Reset the PE1 device
    --
    peNum := WS_PE1;
    dwordOffset := 16#00000800#; -- Reset register
    dwordCount := 1;
    regData(0) := 1;
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );
  
    assert FALSE       
      report "============ All PEs are now reset ============"
      severity NOTE;

    --Wait for the ARM program to run for a while
    wait for 1000 us;

    --------------------------------------------------------------------
    --            
    --  Select the host to be connected to the memories
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000900#; -- Control register for PE1
    dwordCount := 1;
    regData(0) := 16#00000001#;  -- Bit 0 Host/App
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,  
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Write the block RAM buffer offset and memory address
    --  to the first control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- First control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00002000#; -- Offset  : bits 31 downto 23 = 0x000
                                -- Address : bits 22 downto  0 = 0x000
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,   
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Write the memory access type and DWORD count
    --  to the second control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000001#; -- Second control register for Left Mem
    dwordCount  := 1;
    regData(0)  := 16#00100008#; -- Write_Sel_n : bit 20          = 1
                                 -- DWORD count : bits 7 downto 0 = 256
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );

    --------------------------------------------------------------------
    --
    --  Trigger the memory read by writing to the third register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000003#; -- Third control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#;  -- Don't care
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );


    --------------------------------------------------------------------
    --
    --  Read the status of the memory read
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- Status register for Left Mem
    dwordCount := 1;
    Done := FALSE;
    while ( not Done ) loop
      WS_ReadPeReg ( Cmd_Req,
                     Cmd_Ack,
                     board,
                     peNum,
                     dwordOffset,
                     dwordCount,
                     regData );
      if ( regData(0) mod 2 = 1 ) then
        assert FALSE
          report "PE1 Read from 0x2000 has completed"
          severity NOTE;
        Done := TRUE;
      end if;       
      wait for 1 us;
    end loop;

    --------------------------------------------------------------------
    --
    --  Read the memory data from the block RAM
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 8;
    WS_ReadPeReg ( Cmd_Req,
                   Cmd_Ack,
                   board,
                   peNum,
                   dwordOffset,
                   dwordCount,
                   memData );

    for i in 0 to 7 loop
      assert FALSE
        report "PE mem(200" & integer'image(i) & ") = " & integer'image(memData(i))
        severity NOTE;
    end loop;
    --------------------------------------------------------------------
    --
    --  Write the block RAM buffer offset and memory address
    --  to the first control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- First control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00001000#; -- Offset  : bits 31 downto 23 = 0x000
                                -- Address : bits 22 downto  0 = 0x000
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );
  
    --------------------------------------------------------------------
    --
    --  Write the memory access type and DWORD count
    --  to the second control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000001#; -- Second control register for Left Mem
    dwordCount  := 1;
    regData(0)  := 16#00100008#; -- Write_Sel_n : bit 20          = 1
                                 -- DWORD count : bits 7 downto 0 = 256
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board, 
                    peNum,   
                    dwordOffset,
                    dwordCount,
                    regData );
                     
    --------------------------------------------------------------------
    --
    --  Trigger the memory read by writing to the third register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000003#; -- Third control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#;  -- Don't care
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,  
                    peNum,
                    dwordOffset,
                    dwordCount, 
                    regData ); 
    
  
    --------------------------------------------------------------------
    --
    --  Read the status of the memory read
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- Status register for Left Mem
    dwordCount := 1;
    Done := FALSE;
    while ( not Done ) loop 
      WS_ReadPeReg ( Cmd_Req,
                     Cmd_Ack,
                     board,
                     peNum,
                     dwordOffset,
                     dwordCount,
                     regData );
      if ( regData(0) mod 2 = 1 ) then
        assert FALSE
          report "PE1 Read from 0x2000 has completed"
          severity NOTE;
        Done := TRUE;
      end if;
      wait for 1 us;
    end loop;
  
    --------------------------------------------------------------------
    --
    --  Read the memory data from the block RAM
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 8;
    WS_ReadPeReg ( Cmd_Req,
                   Cmd_Ack,
                   board,
                   peNum,
                   dwordOffset,
                   dwordCount,
                   memData );
  
    for i in 0 to 7 loop
      assert FALSE
        report "PE mem(100" & integer'image(i) & ") = " &integer'image(memData(i))
        severity NOTE;
    end loop;

    --------------------------------------------------------------------
    --
    --  Write the block RAM buffer offset and memory address
    --  to the first control register
    --  
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- First control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00001000#; -- Offset  : bits 31 downto 23 = 0x000
                                -- Address : bits 22 downto  0 = 0x000
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board,  
                    peNum, 
                    dwordOffset,
                    dwordCount, 
                    regData ); 
                    
    --------------------------------------------------------------------
    --
    --  Write the memory access type and DWORD count
    --  to the second control register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000001#; -- Second control register for Left Mem
    dwordCount  := 1;
    regData(0)  := 16#00100008#; -- Write_Sel_n : bit 20          = 1
                                 -- DWORD count : bits 7 downto 0 = 256
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack,
                    board, 
                    peNum,
                    dwordOffset,
                    dwordCount,
                    regData );
  
    --------------------------------------------------------------------
    --
    --  Trigger the memory read by writing to the third register
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000003#; -- Third control register for Left Mem
    dwordCount := 1;
    regData(0) := 16#00000000#;  -- Don't care
    WS_WritePeReg ( Cmd_Req,
                    Cmd_Ack, 
                    board,   
                    peNum, 
                    dwordOffset,
                    dwordCount,  
                    regData );  
                     
      
    --------------------------------------------------------------------
    --
    --  Read the status of the memory read
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000000#; -- Status register for Left Mem
    dwordCount := 1;
    Done := FALSE;
    while ( not Done ) loop
      WS_ReadPeReg ( Cmd_Req,
                     Cmd_Ack,
                     board,
                     peNum,
                     dwordOffset,
                     dwordCount,
                     regData );
      if ( regData(0) mod 2 = 1 ) then
        assert FALSE
          report "PE1 Read from 0x2000 has completed"
          severity NOTE;
        Done := TRUE;
      end if;
      wait for 1 us;
    end loop;
      
    --------------------------------------------------------------------
    --
    --  Read the memory data from the block RAM
    --              
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 8;
    WS_ReadPeReg ( Cmd_Req,
                   Cmd_Ack,
                   board,
                   peNum,
                   dwordOffset,
                   dwordCount,
                   memData );
    
    for i in 0 to 7 loop
      assert FALSE
        report "PE mem(000" & integer'image(i) & ") = " &integer'image(memData(i))
        severity NOTE;
    end loop;



  wait; -- end of simulated host program
  end process;                       
end Mem_Copy;

