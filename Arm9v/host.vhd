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
    --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    --
    -- This is the ARM Program.
    --
    --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    --Program Length (dwordCount = # of instructions)
    --If greater than 256 must repeat section from here to END REPEAT
    dwordCount := 209;
      memData(0) := 16#e2000000#;
      memData(1) := 16#e2011000#;
      memData(2) := 16#e2022000#;
      memData(3) := 16#e2033000#;
      memData(4) := 16#e3800001#;
      memData(5) := 16#e3801002#;
      memData(6) := 16#e0802001#;
      memData(7) := 16#e241100a#;
      memData(8) := 16#e2522001#;
      memData(9) := 16#1afffffc#;
      memData(10) := 16#eb000027#;
      memData(11) := 16#eb000042#;
      memData(12) := 16#e3a0dffa#;
      memData(13) := 16#eb000051#;
      memData(14) := 16#eb00006d#;
      memData(15) := 16#eb000039#;
      memData(16) := 16#eb000076#;
      memData(17) := 16#eb000003#;
      memData(18) := 16#e3a0dffa#;
      memData(19) := 16#eb00009e#;
      memData(20) := 16#eb0000a9#;
      memData(21) := 16#ebfffffe#;
      memData(22) := 16#e3a000ff#;
      memData(23) := 16#e3a01caa#;
      memData(24) := 16#e1800001#;
      memData(25) := 16#e3a01855#;
      memData(26) := 16#e1800001#;
      memData(27) := 16#e3a01801#;
      memData(28) := 16#e0c100b2#;
      memData(29) := 16#e5116002#;
      memData(30) := 16#e3866000#;
      memData(31) := 16#e0c160b2#;        
      memData(32) := 16#e5117004#;   
      memData(33) := 16#e15120b2#;   
      memData(34) := 16#e15130f2#;   
      memData(35) := 16#e15140d2#; 
      memData(36) := 16#e15150d1#; 
      memData(37) := 16#e2411004#; 
      memData(38) := 16#e5810000#; 
      memData(39) := 16#e2811001#; 
      memData(40) := 16#e5919000#; 
      memData(41) := 16#e2811001#;
      memData(42) := 16#e5919000#;
      memData(43) := 16#e2811001#;
      memData(44) := 16#e5919000#;
      memData(45) := 16#e2411002#;
      memData(46) := 16#e5810000#;
      memData(47) := 16#e5919000#;
      memData(48) := 16#e2411001#;
      memData(49) := 16#e5919000#;
      memData(50) := 16#e1a0f00e#;
      memData(51) := 16#e3f00000#;
      memData(52) := 16#e2900001#;
      memData(53) := 16#e2500001#;
      memData(54) := 16#e3b020ff#;
      memData(55) := 16#e0301002#;
      memData(56) := 16#e2700001#;
      memData(57) := 16#e0b00000#;
      memData(58) := 16#e0d00000#;
      memData(59) := 16#e0f02002#;
      memData(60) := 16#e2522001#;
      memData(61) := 16#e1911002#;
      memData(62) := 16#e3b00001#;
      memData(63) := 16#e1d03002#;   
      memData(64) := 16#e1901e21#;   
      memData(65) := 16#e2911001#; 
      memData(66) := 16#e2900801#; 
      memData(67) := 16#e02d1190#;
      memData(68) := 16#e0500113#;
      memData(69) := 16#e0100fe3#;
      memData(70) := 16#e09330c1#;
      memData(71) := 16#e2122000#;
      memData(72) := 16#e2111000#;
      memData(73) := 16#e1a0f00e#;
      memData(74) := 16#e3a00106#;
      memData(75) := 16#e3a01004#;
      memData(76) := 16#e0832091#;
      memData(77) := 16#e0c54091#;
      memData(78) := 16#e1a0f00e#;
      memData(79) := 16#e3a00000#;
      memData(80) := 16#e3a0100a#;
      memData(81) := 16#e3a02064#;
      memData(82) := 16#e3a03ffa#;
      memData(83) := 16#e3a04902#;   
      memData(84) := 16#e4a41008#;   
      memData(85) := 16#e4a42008#; 
      memData(86) := 16#e4a43008#; 
      memData(87) := 16#e7a43002#;
      memData(88) := 16#e6148002#;
      memData(89) := 16#e3a01000#;
      memData(90) := 16#e3a02000#;
      memData(91) := 16#e3a03000#;
      memData(92) := 16#e5341008#;
      memData(93) := 16#e5342008#;   
      memData(94) := 16#e5343008#;   
      memData(95) := 16#e1a0f00e#; 
      memData(96) := 16#e3a00000#; 
      memData(97) := 16#e3a01001#;
      memData(98) := 16#e3a02002#;
      memData(99) := 16#e3a03003#;
      memData(100) := 16#e3a04801#;
      memData(101) := 16#e3a05803#;
      memData(102) := 16#e3a06807#;
      memData(103) := 16#e3a0780f#;
      memData(104) := 16#e3a08902#;
      memData(105) := 16#e2888008#;
      memData(106) := 16#e3a09901#;
      memData(107) := 16#e8a800ff#;
      memData(108) := 16#e0ccd899#;
      memData(109) := 16#e89900ff#;
      memData(110) := 16#e93800ff#;
      memData(111) := 16#e9a800ff#;
      memData(112) := 16#e89900ff#;        
      memData(113) := 16#e83800ff#; 
      memData(114) := 16#e82800ff#; 
      memData(115) := 16#e89900ff#; 
      memData(116) := 16#e9b800ff#; 
      memData(117) := 16#e92800ff#;     
      memData(118) := 16#e89900ff#; 
      memData(119) := 16#e8b800ff#; 
      memData(120) := 16#e89900ff#; 
      memData(121) := 16#eef00f00#;
      memData(122) := 16#eef00f01#;
      memData(123) := 16#eeff0f0f#;
      memData(124) := 16#e1a0f00e#; 
      memData(125) := 16#e3a00000#;
      memData(126) := 16#e3a01001#;
      memData(127) := 16#e3a02002#;
      memData(128) := 16#e3a03903#;
      memData(129) := 16#e1030091#;
      memData(130) := 16#e1032092#;
      memData(131) := 16#e1032093#;
      memData(132) := 16#e1030090#;
      memData(133) := 16#e1430090#;
      memData(134) := 16#e1030090#;
      memData(135) := 16#e1a0f00e#;
      memData(136) := 16#e3a00010#;
      memData(137) := 16#e3a01011#;
      memData(138) := 16#e3a02012#;
      memData(139) := 16#e3a03013#;
      memData(140) := 16#e3a04017#;
      memData(141) := 16#e3a0501b#;
      memData(142) := 16#e3a0601f#;
      memData(143) := 16#e3a0720f#;
      memData(144) := 16#e3a08102#;
      memData(145) := 16#e129f001#;
      memData(146) := 16#e169f007#;
      memData(147) := 16#e14f8000#;
      memData(148) := 16#e14f9000#;
      memData(149) := 16#e14fa000#;
      memData(150) := 16#e14fb000#;
      memData(151) := 16#e14fc000#;
      memData(152) := 16#e14fd000#;
      memData(153) := 16#e14fe000#;
      memData(154) := 16#e129f002#;
      memData(155) := 16#e169f008#;
      memData(156) := 16#e14fd000#;
      memData(157) := 16#e14fe000#;
      memData(158) := 16#e129f003#;
      memData(159) := 16#e169f007#;
      memData(160) := 16#e14fa000#;
      memData(161) := 16#e1a0300e#;
      memData(162) := 16#e129f004#;
      memData(163) := 16#e169f008#;
      memData(164) := 16#e14fd000#;
      memData(165) := 16#e14fe000#;
      memData(166) := 16#e129f005#;
      memData(167) := 16#e169f007#;  
      memData(168) := 16#e14fd000#;  
      memData(169) := 16#e14fe000#;
      memData(170) := 16#e129f006#;
      memData(171) := 16#e10fd000#;
      memData(172) := 16#e1a0e003#;
      memData(173) := 16#e129f000#;
      memData(174) := 16#e129f007#;
      memData(175) := 16#e128f008#;  
      memData(176) := 16#e328f20a#;
      memData(177) := 16#e10f9000#;  
      memData(178) := 16#e1a0f00e#;
      memData(179) := 16#eea21103#;
      memData(180) := 16#0e521243#;
      memData(181) := 16#eeb53216#;
      memData(182) := 16#ee054616#;
      memData(183) := 16#0ef53356#;
      memData(184) := 16#edb53106#;
      memData(185) := 16#ed253106#;
      memData(186) := 16#ecb54206#;
      memData(187) := 16#ec254206#;
      memData(188) := 16#ec955306#;
      memData(189) := 16#ed855306#;
      memData(190) := 16#e1a0f00e#;
      memData(191) := 16#eef00f10#;
      memData(192) := 16#eef11f10#;
      memData(193) := 16#eef22f10#;
      memData(194) := 16#eef33f10#;
      memData(195) := 16#eef44f10#;
      memData(196) := 16#eef55f10#;
      memData(197) := 16#eef66f10#;
      memData(198) := 16#eef77f10#;
      memData(199) := 16#eef88f10#;
      memData(200) := 16#eef99f10#;
      memData(201) := 16#eefaaf10#;
      memData(202) := 16#e3a0ba01#;
      memData(203) := 16#e88b07ff#;
      memData(204) := 16#e3a0a000#;
      memData(205) := 16#ecea0f08#;
      memData(206) := 16#e35a0a02#;
      memData(207) := 16#1afffffc#;
      memData(208) := 16#e1a0f00e#;


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
    --Program Length = DWORD count (bits 8 downto 0)  
    --Easiest to just pick a value larger than the actual length 
    regData(0) := 16#00000100#; -- Write_Sel_n : bit 20          = 0
                                -- DWORD count : bits 8 downto 0 = 256
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

    --END REPEAT (for programs longer than 256 instructions)

    --------------------------------------------------------------------
    --
    --  Fill up the block RAM with data to be written to memory.
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000100#; -- Block RAM for Mem
    dwordCount := 8;
    for i in 0 to 7 loop
      memData(i) := 0;
    end loop;
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
    dwordCount := 1;
    regData(0) := 16#00000008#; -- Write_Sel_n : bit 20          = 0
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
    dwordCount := 1;
    memData(0) := 16#000000ff#;
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
    regData(0) := 16#00000001#; -- Write_Sel_n : bit 20          = 0
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
    regData(0) := 16#00003000#; -- Offset  : bits 31 downto 23 = 0x000
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

    --------------------------------------------------------------------
    --
    --  Read the status of the ARM Program
    --
    --------------------------------------------------------------------
    peNum := WS_PE1;
    dwordOffset := 16#00000A00#; -- Status register for ARM
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
          report "ARM Test Program has completed"
          severity NOTE;  
        Done := TRUE;
      end if;
      wait for 50 us;
    end loop;       

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

  wait; -- end of simulated host program
  end process;                       
end Mem_Copy;

