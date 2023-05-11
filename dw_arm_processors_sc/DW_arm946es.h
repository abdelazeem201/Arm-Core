// DW_arm946es.h: header file

#ifndef __DW_arm946es_h
#define __DW_arm946es_h

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
    , VINITHI("VINITHI") \
    , INITRAM("INITRAM") \
    , DHClkEn("DHClkEn") \
    , clock("clock") \
    , itcm("itcm") \
    , dtcm("dtcm")
#else
#define CCSS_INIT_MEMBERS 
#endif

// This model of the ARM946ES processor is based on an ARM Instruction Set
// Simulator (ISS).  This model is intended to be used as a transaction-level
// model of the ARM946ES processor, not as a pin-level model.
// 
// SIGNALS:
// ========
// The model is connected to the interface of the AHB_bus model via its BIU
// master port, and is connected to the interrupt outputs of the interrupt 
// controller via the input signals nIRQ, nFIQ, VINITHI, and INITRAM.
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
// 
class DW_arm946es// ARM946ES Transaction Level Processor Model 
: public sc_module
{

public:
    // parameters
    CCSS_PARAMETER(unsigned  int, MasterIDbiu);

    // ports

    // Active low IRQ input signal 
    sc_in<bool> nIRQ;

    // Active low FIQ input signal 
    sc_in<bool> nFIQ;

    // Active low RESET input signal 
    sc_in<bool> nRESET;

    // The bus interface is connected to this port. 
    ahb_master_port biu;

    // High Vector Initialization input. 
    sc_in<bool> VINITHI;

    // TCM enabling input. 
    sc_in<bool> INITRAM;

    // H Clock enable input for running processor at different frequency than data bus. 
    sc_in<bool> DHClkEn;

    // System Clock 
    sc_in_clk clock;

    // Instruction TCM port. 
    sc_port<tcm_slave_if, 1> itcm;

    // Data TCM port. 
    sc_port<tcm_slave_if, 1> dtcm;

    // initialize parameters
    virtual void InitParameters() {
        unsigned  int _tmp_MasterIDbiu = 1 ;
        MasterIDbiu.conditional_init(_tmp_MasterIDbiu);
    }

   // processes
	void main_action();
	SC_HAS_PROCESS(DW_arm946es);

	// constructor
	DW_arm946es(const sc_module_name& name_, 
	         int priority = 1, 
			 bool default_grant = true,
			 bool BigEndian = false,
			 const sc_string& program_name = "",
			 const sc_string& debugger = "axd");

	// destructor
	~DW_arm946es();

    void end_of_elaboration();
	// public data members.
	void *iss_ifc;

}; // end module DW_arm946es
#undef CCSS_INIT_MEMBERS_PREFIX
#undef CCSS_INIT_MEMBERS

#endif
