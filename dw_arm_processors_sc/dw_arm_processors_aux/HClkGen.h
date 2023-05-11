// HClkGen.h: header file

#ifndef __HClkGen_h
#define __HClkGen_h

#include <systemc.h>

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
    Clk("Clk") \
    , n_reset("n_reset") \
    , IBusHClk("IBusHClk") \
    , IBusHClkEn("IBusHClkEn") \
    , DBusHClk("DBusHClk") \
    , DBusHClkEn("DBusHClkEn")
#else
#define CCSS_INIT_MEMBERS 
#endif

class HClkGen
: public sc_module
{

public:
    // ports

    // System Clock to be divided
    sc_in_clk Clk;

    // Rest line.
    sc_in<bool> n_reset;

    // Instruction Bus Hclk
    sc_out<bool> IBusHClk;

    // Instruction Bus Hclk En
    sc_out<bool> IBusHClkEn;

    // Data Bus Hclk
    sc_out<bool> DBusHClk;

    // Data Bus HClk Enable
    sc_out<bool> DBusHClkEn;

    // initialize parameters
    virtual void InitParameters() {
    }

	SC_HAS_PROCESS(HClkGen);

	// default constructor
	HClkGen(sc_module_name name_,
			int DBusClkDivRatio = 1, 
			int IBusClkDivRatio = 1);

	void main_action();
	void reset();


private:	
    int _DBusClkDivRatio, _IBusClkDivRatio;
	int IBusHClkEnCnt;
	int DBusHClkEnCnt;
	bool dbus_divratio, ibus_divratio;
	bool ODD, EVEN;



}; // end module HClkGen
#undef CCSS_INIT_MEMBERS_PREFIX
#undef CCSS_INIT_MEMBERS

#endif
