------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Model Technology ModelSim(tm) Compilation Macro File
--
--  Follow the itemized instructions below in order to customize
--  the STARFIRE(tm) simulation model compilation script to meet
--  your application needs.
--
--  To execute this macro file from the ModelSim(tm) VHDL simulator:
--
--    Using the "File->Execute Macro" menu option select this 
--    file in the browser window and click on "Open".
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  1. Change the PROJECT_BASE and STARFIRE_BASE variables to your
--     project directory and STARFIRE(tm)/VME installation directory,
--     respectively:
--
------------------------------------------------------------------------
--set PROJECT_BASE c:/wildstar/VHDL/starfire/examples/mem_copy/vhdl/sim
--set STARFIRE_BASE c:/wildstar/VHDL/starfire
set PROJECT_BASE ./
set STARFIRE_BASE ../../../../STARFIRE/vhdl/starfire

vlib arm
vmap arm arm

vlog -work arm $PROJECT_BASE/pardef.v
vlog -work arm $PROJECT_BASE/alu.v
vlog -work arm $PROJECT_BASE/align.v
vlog -work arm $PROJECT_BASE/arm9.v
vlog -work arm $PROJECT_BASE/comp42_2.v
vlog -work arm $PROJECT_BASE/comp42_n40.v
vlog -work arm $PROJECT_BASE/comp42_n64.v
vlog -work arm $PROJECT_BASE/control.v
vlog -work arm $PROJECT_BASE/counters.v
vlog -work arm $PROJECT_BASE/dcache.v
vlog -work arm $PROJECT_BASE/decode.v
vlog -work arm $PROJECT_BASE/ex.v
vlog -work arm $PROJECT_BASE/icache.v
vlog -work arm $PROJECT_BASE/id.v
vlog -work arm $PROJECT_BASE/ifetch.v
vlog -work arm $PROJECT_BASE/interlock.v
vlog -work arm $PROJECT_BASE/mapreg.v
vlog -work arm $PROJECT_BASE/mapspsr.v
vlog -work arm $PROJECT_BASE/me.v
vlog -work arm $PROJECT_BASE/miniram.v
vlog -work arm $PROJECT_BASE/mmu_new.v
vlog -work arm $PROJECT_BASE/mult.v
vlog -work arm $PROJECT_BASE/multacc.v
vlog -work arm $PROJECT_BASE/pipe.v
vlog -work arm $PROJECT_BASE/ppselect.v
vlog -work arm $PROJECT_BASE/ram1p.v
vlog -work arm $PROJECT_BASE/ram2p.v
vlog -work arm $PROJECT_BASE/itag.v
vlog -work arm $PROJECT_BASE/dtag.v
vlog -work arm $PROJECT_BASE/regfile.v
vlog -work arm $PROJECT_BASE/shifter.v
vlog -work arm $PROJECT_BASE/tag.v

--
--  Do not change these two lines!!
--
cd $PROJECT_BASE
do $STARFIRE_BASE/src/system_vcom.do

--Adding this Line to place the RAMB_256xxx_DP cells into the arm library
vcom -93 -explicit -work arm $STARFIRE_BASE/src/xilinx/xilinx_entarch.vhd
------------------------------------------------------------------------
--
--  2. If you are using a specific mezzanine card (e.g., a mezzanine
--     memory card) or a specific I/O card (e.g., a FPDP I/O card)
--     add the appropriate macro execution and/or compilation 
--     statement(s) here:
--
------------------------------------------------------------------------
--
--   If you are using the mezzanine memory card, you should uncomment 
--   and/or modify the following 2 lines:
--
do $STARFIRE_BASE/src/mezz_card/mezz_mem_card/mezz_mem_card_vcom.do
vcom -93 -explicit -work system $PROJECT_BASE/mezz_mem_card_cfg.vhd

------------------------------------------------------------------------
--
--  3. Add your project's PE1 architecture VHDL file here, as 
--     well as any VHDL files on which your PE1 design depends:
--
------------------------------------------------------------------------
vcom -93 -explicit -work PEX_Lib $PROJECT_BASE/pe_lad2mem_if_entarch.vhd
vcom -93 -explicit -work PEX_Lib $PROJECT_BASE/pe_arm2mem_if_entarch.vhd
vcom -93 -explicit -work PEX_Lib $PROJECT_BASE/pex.vhd


------------------------------------------------------------------------
--
--  4. Add your project's host architecture VHDL file here, as 
--     well as any VHDL files on which your host design depends:
--
------------------------------------------------------------------------
vcom -93 -explicit -work system $PROJECT_BASE/host.vhd


------------------------------------------------------------------------
--
--  5. Add your project's system configuration VHDL file here:
--
------------------------------------------------------------------------
vcom -93 -explicit -work system $PROJECT_BASE/system_cfg.vhd

