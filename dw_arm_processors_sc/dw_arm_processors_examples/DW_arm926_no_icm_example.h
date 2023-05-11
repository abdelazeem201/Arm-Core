#ifndef __DW_arm926_no_icm_example_h
#define __DW_arm926_no_icm_example_h

#include <systemc.h>

#ifndef SYNTHESIS
#include <ccss_systemc.h>
#endif

#include "ahb_types.h"

using namespace ahb_namespace;

#include "DW_ahb_tlm.h"

#define CCSS_USE_SC_CTOR
#include "ahb_slave_if.h"
#include "ahb_bus_if.h"


// forward declarations
class DW_AHB_Monitor;
template<class SIF > class DW_AHB_Memory;
template<class T > class ConstGen;
template<class MIF, class SIF > class DW_ahb_tlm;
class DW_AHB_Arbiter;
class DW_arm926ejs;
class DW_AHB_Decoder;
class DW_TCMemory;
template<class SIF > class DW_IntrGen;

#ifdef CCSS_USE_SC_CTOR
#define CCSS_INIT_CHANNELS_PREFIX : 
#undef CCSS_USE_SC_CTOR
#else
#define CCSS_INIT_CHANNELS_PREFIX , 
#endif

#ifndef SYNTHESIS
#define CCSS_INIT_CHANNELS  CCSS_INIT_CHANNELS_PREFIX \
    C173("C173") \
    , C175("C175") \
    , C189("C189") \
    , High("High") \
    , INITRAM("INITRAM") \
    , Low1("Low1") \
    , VINITHI("VINITHI") \
    , clock("clock") \
    , nFIQ("nFIQ") \
    , nIRQ("nIRQ") \
    , nRESET("nRESET")
#else
#define CCSS_INIT_CHANNELS 
#endif

// This is the example test design for the ARM926 DesignWare Processor Model
// using no Interconnect Matrix.
// 
// This example shows how to design the ARM926 processor model into your design
// without using an Interconnect Matrix. Although this proves an Interconnect
// Matrix module is not required, it's inclusion results in a faster simulation
// due to less arbitration requirements on the two buses.
// 
// This example design supports 8, 16, and 32 bit reads and 
// writes, and nIRQ, nFIQ, and nRESET interrupts. It contains
// the following modules:
//  
//      Instance Name       Purpose
// 	 =============       =======
// 	 arm926       -      Processor Model.
//      ahb_bus             Processor data and instruction bus.
// 	 ProgMem      -      Program Memory - memory that holds. 
// 	                     the ARM target code. Target code is copied
// 						 to and read from this location via the ARM 
// 						 debugger and CCM. Address range 0x0 - 0x1ffff.
//      StackMem     -      Stack Memory - memory the arm926 processor
// 	                     needs for stack read and writes. Address range
// 						 0x10000000 - 0x1000ffff.
//      DataMem      -      Data Memory - Memory location for testing basic
// 	                     reads and writes.  Address range 
// 						 0x90000000 - 0x900003ff
//      IntrGen      -      Interrupt Generator - Target code writes to this
// 	  					 module when testing interrupts. Address range
// 						 0xb0000000 - 0xb00003ff. See module description
// 						 for bit assignments.
//      Itcm         -      Instruction Tightly Coupled Memory - Memory for 
// 	                     Instruction TCM. Address range is 4K starting at
// 						 address 0xff000.
//      Dtcm         -      Data Tightly Coupled Memory - Memory for Data TCM. 
// 	                     Address range is 4K starting at address 0x20000.
// 							 
// 
// A configuration control file (examples.scf) is located at 
// dw_arm_processors_sc/dw_arm_processors_examples. It can
// be used to modify all design parameters from their default
// design values.  These include changing which of several ARM debuggers to
// use, the endianism of the design (big or little),
// to preload a target program file into program memory, to 
// set wait states on memory modules, and to turn on and off 
// System Studio monitor tracing.
// 
// 
// Example pre-compiled ARM target code, named "examples.axf",  
// is located at:
// 
//     dw_arm_processors_sc/dw_arm_processors_examples/arm926_target
// 
// This target code performs basic read/writes and asserts the
// nIRQ, nFIQ, and nRESET interrupts.
// 
// To load and run the software:
// 
// 1) Start the simulation from the simulation control panel, in
//    either -pause mode or non-pause mode. If -pause mode is used
//    you will have to continue simulation with the pause/continue
//    simulation button at the appropriate time.
//    
// 2) When the simulation is correctly launched, the ARM debugger 
//    will appear. When the ARM debugger is fully launched (the ARM
//    debugger's "Execution Window" 
//    shows memory locations starting from 0x0), load the 
//    arm926_target/examples.axf image via the following  pull 
//    down window of the ARM debugger:
// 
//         File->Load Image
// 
//    You will have to navigate to the target binary location to load it.
// 
// 3) Once the target code is loaded into the ARM debugger, breakpoints can be set at 
//    different locations in this target code. To run or continue the
//    the target program simply type "go" at the "Debug:" prompt in the 
//    "Command Window" of the ARM debugger, or by using the "Go" button on the
//    ARM debugger's toolbar.
// 
//    Below is a list of function names where break points can be set:
//       main       - main function of program
//       ram8test   - test for 8 bit memory accesses
//       ram16test  - test for 16 bit memory accesses.
//       ram32test  - test for 32 bit memory accesses.
//       irqtest    - nIRQ interrupt test. Program will jump to the 
// 	               irq_hndlr when an IRQ interrupt occurs.
//       fiqtest    - nFIQ interrupt test. Program will jump to the 
// 	               fiq_hndlr when an FIQ interrupt occurs.
//       irq_hndlr  - nIRQ interrupt handler. Program execution will 
// 	               jump to this handler when an IRQ interrupt occurs 
// 				   (part of irqtest).
//       fiq_hndlr  - nFIQ interrupt handler. Program execution will jump 
// 	               to this handler when an FIQ interrupt occurs 
// 				   (part of fiqtest).
//       dataaborttest - test for data abort handling (program will jump 
// 	                  to the DABORTHandler() when a data abort occurs).
//       DABORTHandler - Data Abort interrupt handler (program execution 
// 	                  will jump to this handler when a data abort occurs 
// 					  (part of the dataaborttest). NOTE: The debugger will
// 					  issue a data abort error message in the Command Window
// 					  when a Data Abort occurs.  Just continue of step through
// 					  the program to get through the data abort interrupt handler.
//       resettest     - test for reset. The target program will jump to 
// 	                  the RESETHandler when a reset is detected.
//       RESETHandler  - nRESET interrupt handler. Program execution jumps 
// 	                  to this handler when a reset is detected. Currently a reset
// 					  handler is not implemented. Continuing to step through the
// 					  code will show that the RESETHandler was hit.
// 
// 
// 4) Once a breakpoint is hit, you can step through the code by either typing
//    "step" or "s" at the "Debug:" prompt in the Command Window, or using the 
//     ARM debugger's step buttons.
// 
// For more information about running the ARM debugger and running the simulation, 
// please see the supplied documentation at dw_arm_processors_sc/doc
class DW_arm926_no_icm_example// Arm926 Basic Test Design With No Interconnect Matrix
: public sc_module
{

public:
    // parameters

    // Low address of program memory address range.
    CCSS_PARAMETER(unsigned int, ProgMemStartAddr);

    // High address of program memory adddress range
    CCSS_PARAMETER(unsigned int, ProgMemEndAddr);

    // File name for initialization of memory
    CCSS_PARAMETER(sc_string, ProgMemImageFile);

    // ProgName is the name of the Arm-compiled target application
    CCSS_PARAMETER(sc_string, ProgName);

    // BigEndian==true will invoke armsd in big endian byte order.
    CCSS_PARAMETER(bool, BigEndian);

    // Select armsd, axd, or a user-created script to launch an Arm debugger
    CCSS_PARAMETER(sc_string, Debugger);
    CCSS_PARAMETER(bool, DoTrace);

    // This parameter specifies the number of data cycle wait
    // states to complete a data transfer.
    CCSS_PARAMETER(int, ProgMemReadWaitStates);

    // This parameter specifies the number of data cycle wait
    // states to complete a data transfer.
    CCSS_PARAMETER(int, ProgMemWriteWaitStates);

    // Low address for processor stack memory
    CCSS_PARAMETER(unsigned int, StackMemStartAddr);

    // High address for processor stack memory
    CCSS_PARAMETER(unsigned int, StackMemEndAddr);

    // This parameter specifies the number of data cycle wait
    // states to complete a data transfer.
    CCSS_PARAMETER(int, StackMemReadWaitStates);

    // This parameter specifies the number of data cycle wait
    // states to complete a data transfer.
    CCSS_PARAMETER(int, StackMemWriteWaitStates);

    // Low address for data memory - arm target code reads and writes to this memory.
    CCSS_PARAMETER(unsigned int, DataMemStartAddr);

    // High address for data memory - arm target code reads and writes to this memory
    CCSS_PARAMETER(unsigned int, DataMemEndAddr);

    // This parameter specifies the number of data cycle wait
    // states to complete a data transfer.
    CCSS_PARAMETER(int, DataMemReadWaitStates);

    // This parameter specifies the number of data cycle wait
    // states to complete a data transfer.
    CCSS_PARAMETER(int, DataMemWriteWaitStates);

    // Address for the Interrupt Generator to enable and disable interrupts
    CCSS_PARAMETER(unsigned int, IntrGenStartAddr);

    // High address of Interrupt Generator.
    CCSS_PARAMETER(unsigned int, IntrGenEndAddr);

    // Start time of the file trace.
    CCSS_PARAMETER(double, TraceStartTime);

    // End time of the file trace. To disable the trace end time enter
    // a value less than zero.
    CCSS_PARAMETER(double, TraceEndTime);

    // channels
    sc_signal<bool> C173;
    sc_signal<bool> C175;
    sc_signal<sc_bv<NUM_MASTERS> > C189;
    sc_signal<bool> High;
    sc_signal<bool> INITRAM;
    sc_signal<bool> Low1;
    sc_signal<bool> VINITHI;
    sc_clock clock;
    sc_signal<bool> nFIQ;
    sc_signal<bool> nIRQ;
    sc_signal<bool> nRESET;

    // module instances
    DW_AHB_Monitor *AHBMonitor;
    DW_AHB_Memory<ahb_slave_if > *DataMem;
    ConstGen<bool > *FalseGen;
    DW_AHB_Memory<ahb_slave_if > *ProgMem;
    ConstGen<bool > *ResetGen;
    DW_AHB_Memory<ahb_slave_if > *StackMem;
    DW_ahb_tlm<ahb_bus_if, ahb_slave_if > *ahb_bus;
    DW_AHB_Arbiter *arbiter;
    DW_arm926ejs *arm926;
    DW_AHB_Decoder *decoder;
    DW_TCMemory *dtcm;
    DW_IntrGen<ahb_slave_if > *intr_gen;
    DW_TCMemory *itcm;

    // initialize parameters
    virtual void InitParameters() {
        unsigned int _tmp_ProgMemStartAddr = 0x0;
        ProgMemStartAddr.conditional_init(_tmp_ProgMemStartAddr);
        unsigned int _tmp_ProgMemEndAddr = 0x1ffff;
        ProgMemEndAddr.conditional_init(_tmp_ProgMemEndAddr);
        sc_string _tmp_ProgMemImageFile = "";
        ProgMemImageFile.conditional_init(_tmp_ProgMemImageFile);
        sc_string _tmp_ProgName = "";
        ProgName.conditional_init(_tmp_ProgName);
        bool _tmp_BigEndian = false;
        BigEndian.conditional_init(_tmp_BigEndian);
        sc_string _tmp_Debugger = "axd";
        Debugger.conditional_init(_tmp_Debugger);
        bool _tmp_DoTrace = false;
        DoTrace.conditional_init(_tmp_DoTrace);
        int _tmp_ProgMemReadWaitStates = 0;
        ProgMemReadWaitStates.conditional_init(_tmp_ProgMemReadWaitStates);
        int _tmp_ProgMemWriteWaitStates = 0;
        ProgMemWriteWaitStates.conditional_init(_tmp_ProgMemWriteWaitStates);
        unsigned int _tmp_StackMemStartAddr = 0x10000000;
        StackMemStartAddr.conditional_init(_tmp_StackMemStartAddr);
        unsigned int _tmp_StackMemEndAddr = 0x1000ffff;
        StackMemEndAddr.conditional_init(_tmp_StackMemEndAddr);
        int _tmp_StackMemReadWaitStates = 0;
        StackMemReadWaitStates.conditional_init(_tmp_StackMemReadWaitStates);
        int _tmp_StackMemWriteWaitStates = 0;
        StackMemWriteWaitStates.conditional_init(_tmp_StackMemWriteWaitStates);
        unsigned int _tmp_DataMemStartAddr = 0x90000000;
        DataMemStartAddr.conditional_init(_tmp_DataMemStartAddr);
        unsigned int _tmp_DataMemEndAddr = 0x900003ff;
        DataMemEndAddr.conditional_init(_tmp_DataMemEndAddr);
        int _tmp_DataMemReadWaitStates = 0;
        DataMemReadWaitStates.conditional_init(_tmp_DataMemReadWaitStates);
        int _tmp_DataMemWriteWaitStates = 0;
        DataMemWriteWaitStates.conditional_init(_tmp_DataMemWriteWaitStates);
        unsigned int _tmp_IntrGenStartAddr = 0xb0000000;
        IntrGenStartAddr.conditional_init(_tmp_IntrGenStartAddr);
        unsigned int _tmp_IntrGenEndAddr = 0xb00003ff;
        IntrGenEndAddr.conditional_init(_tmp_IntrGenEndAddr);
        double _tmp_TraceStartTime = 0.0;
        TraceStartTime.conditional_init(_tmp_TraceStartTime);
        double _tmp_TraceEndTime = 0.0;
        TraceEndTime.conditional_init(_tmp_TraceEndTime);
    }
    // create the schematic
    virtual void InitInstances();

    // delete the schematic
    virtual void DeleteInstances();

#ifndef SYNTHESIS
	SC_HAS_PROCESS(DW_arm926_no_icm_example);
#endif

	// default constructor
	DW_arm926_no_icm_example(sc_module_name name_)
	  CCSS_INIT_CHANNELS
	{
		InitParameters();

		// process declarations

		InitInstances();

	}

#ifndef SYNTHESIS
	// destructor
	~DW_arm926_no_icm_example()
	{
		DeleteInstances();
	}
#endif

}; // end module DW_arm926_no_icm_example
#undef CCSS_INIT_CHANNELS_PREFIX
#undef CCSS_INIT_CHANNELS

#endif
