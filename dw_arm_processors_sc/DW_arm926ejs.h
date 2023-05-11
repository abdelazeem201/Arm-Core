// DW_arm926ejs.h: header file

#ifndef __DW_arm926ejs_h
#define __DW_arm926ejs_h

#include "ahb_types.h"

using namespace ahb_namespace;

#include <systemc.h>
#include <ccss_systemc.h>
#include "ahb_master_port.h"
#include "tcm_slave_if.h"

#ifndef SYNTHESIS
#include <ccss_systemc.h>
#endif


#ifdef CCSS_USE_SC_CTOR
#define CCSS_INIT_MEMBERS_PREFIX : 
#undef CCSS_USE_SC_CTOR
#else
#define CCSS_INIT_MEMBERS_PREFIX , 
#endif

#ifndef SYNTHESIS
#define CCSS_INIT_MEMBERS  CCSS_INIT_MEMBERS_PREFIX \
    nIRQ("nIRQ") \
    , nFIQ("nFIQ") \
    , nRESET("nRESET") \
    , IHClkEn("IHClkEn") \
    , DHClkEn("DHClkEn") \
    , clock("clock") \
    , VINITHI("VINITHI") \
    , INITRAM("INITRAM") \
    , itcm("itcm") \
    , dtcm("dtcm")
#else
#define CCSS_INIT_MEMBERS 
#endif

// This model of the ARM926EJ-S processor is based on an ARM Instruction Set
// Simulator (ISS).  This model is intended to be used as a transaction-level
// model of the ARM926EJ-S processor, not as a pin-level model.
// 
// SIGNALS:
// ========
// The model is connected to the interface of the AHB_bus models via its IBIU
// and DBIU master ports, and is connected to the interrupt outputs of the
// interrupt controller via the input signals nIRQ, nFIQ, VINITHI, and INITRAM.
// The model has a reset input signal, nRESET, which should be driven high
// througout simulation.
// 
// 
// CONSTRUCTOR PARAMETERS:
// =======================
// BigEndian  (boolean)
//   Purpose: To initialize the Arm debuggers to the proper byte order.
//   Values:  'False' implies that the byte order is Little Endian.
//            'True' implies that the byte order is Big Endian.
//            The default value is False.
//   Implications: The byte order of the processor model should match the
//                 byte order set for the memories.
// 
// Debugger   (string)
//   Purpose: To specify which ARM debugger will be invoked.
//   Values:  'adu', 'armsd', or an executable shell script.
//   Implications: Any string will be passed to the processor model.  The
//                 model locates that string via the $PATH environment variable.
//                 If the model cannot resolve the string, a warning will be
//                 issued and simulation will terminate.  If the string specifies
//                 a script file, then the script is responsible for invoking the
//                 debugger and consuming any parameters passed to it from the
//                 processor model.
// 
// ProgName    (string)
//    Purpose: To automatically load an ARM target program into the debugger.
//    Values:  the path to the .axf file.
//    Implications: If the Debugger cannot find the file, the Debugger
//                  will issue an error.
// 
// USAGE:
// ======
// When the processor model is elaborated, the ARM debugger will invoke.  The
// Arm debugger is the mechanism by which the software executable (.axf file)
// is loaded into program memory.
// 
//    For ARM's ADU debugger, the command sequence is:
//       File-&gt;LoadImage-&gt;
//          A file navigation dialog will be presented whereby the user can
//          navigate to, and load, the desired target program.
//    For ARM's armsd debugger, the command is simply:
//       armsd&gt; load "path to filename"
// 
// Once the target program is loaded, a breakpoint is automatically set
// at 'main' (if that symbol exists in the target program's symbol table).
// The user may specify additional breakpoints at this time, or interact
// with the ARM debugger in any way.
// 
// Pressing the ARM debugger's "go" button, or "step" button (or by typing the
// analagous commands in the ARM debugger's command window) will commence
// simulation.
class DW_arm926ejs// ARM926EJS Transaction Level Processor Model
: public sc_module
{

public:
    // parameters
    CCSS_PARAMETER(unsigned int, MasterIDibiu);
    CCSS_PARAMETER(unsigned int, MasterIDdbiu);

    // ports

    // Active low IRQ input signal
    sc_in<bool> nIRQ;

    // Active low FIQ input signal
    sc_in<bool> nFIQ;

    // Active low RESET input signal
    sc_in<bool> nRESET;

    // H Clock Enable input for running IBus at different frequence than system.
    sc_in<bool> IHClkEn;

    // H Clock enable input for running processor at different frequency than bus model.
    sc_in<bool> DHClkEn;

    // System Clock
    sc_in_clk clock;

    // The instruction bus interface is connected to this port.
    ahb_master_port ibiu;

    // The data bus interface is connected to this port.
    ahb_master_port dbiu;

    // High Vector Initialization input.
    sc_in<bool> VINITHI;

    // TCM enabling input.
    sc_in<bool> INITRAM;

    // Instruction TCM port.
    sc_port<tcm_slave_if> itcm;

    // Data TCM port.
    sc_port<tcm_slave_if> dtcm;

    // initialize parameters
    virtual void InitParameters() {
        unsigned int _tmp_MasterIDibiu = 1;
        MasterIDibiu.conditional_init(_tmp_MasterIDibiu);
        unsigned int _tmp_MasterIDdbiu = 0;
        MasterIDdbiu.conditional_init(_tmp_MasterIDdbiu);
    }

    // processes
	void main_action();
	SC_HAS_PROCESS(DW_arm926ejs);

	// constructor
	DW_arm926ejs(const sc_module_name& name_, 
	          int ibiu_priority = 1,  
			  bool ibiu_default_grant = true,
			  int dbiu_priority = 1,
			  bool dbiu_default_grant = true,
			  bool BigEndian = false,
			  const sc_string& program_name = "",
			  const sc_string& debugger = "axd");

	// destructor
	~DW_arm926ejs();

    void end_of_elaboration();
	// public data members.
	void *iss_ifc;


}; // end module DW_arm926ejs
#undef CCSS_INIT_MEMBERS_PREFIX
#undef CCSS_INIT_MEMBERS

#endif
