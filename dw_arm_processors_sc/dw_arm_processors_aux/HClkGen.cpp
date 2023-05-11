// HClkGen.cpp: source file

#include "HClkGen.h"

HClkGen::HClkGen(sc_module_name name_,
		         int DBusClkDivRatio, 
		         int IBusClkDivRatio)
	: sc_module(name_)
{
	if ((DBusClkDivRatio < 1) || (IBusClkDivRatio < 1)){
		cout << "DbusClkDivRatio and IBusClkDivRatio must be 1 or greater" << endl;
	}
	//InitParameters();

	IBusHClkEnCnt = IBusClkDivRatio;
	DBusHClkEnCnt = DBusClkDivRatio;
	ODD = 1;
	EVEN = 0;
	dbus_divratio = DBusClkDivRatio % 2;
	ibus_divratio = IBusClkDivRatio % 2; 
	_IBusClkDivRatio = IBusClkDivRatio;
	_DBusClkDivRatio = DBusClkDivRatio;

	SC_METHOD( main_action );
	sensitive << Clk;

    SC_METHOD( reset );
	sensitive << n_reset.neg();
}

void
HClkGen::main_action()
{
	if (_IBusClkDivRatio > 1){
		// Generate a divided Hclock and clock enables for the IBus.
		if (Clk){
			// Generate Dbus Hclk
			if (IBusHClkEnCnt == _IBusClkDivRatio){
				IBusHClk = 1;
			}
			
			// IBus Hclk falling edge for even division ratio.
			// Insures a 50% duty cycle for IBus Hclk.
			if (ibus_divratio == EVEN){
				if (IBusHClkEnCnt <= _IBusClkDivRatio / 2){
					IBusHClk = 0;
				}
			}
 		} else { // Falling edge of Clk.
			// Generate IBusHClkEn
			IBusHClkEnCnt--;

			// If division ratio is odd, generate the Ibus Hclk falling edge.
			// Insure a 50% duty cycle for IBus Hclk if odd division ratio.
			if (ibus_divratio == ODD){
				if (IBusHClkEnCnt <= _IBusClkDivRatio/2){
					IBusHClk = 0;
				    IBusHClkEn = 1;
                }
			}

			// Generate IBus HClock Enable
			if (IBusHClkEnCnt == 0){
				IBusHClkEnCnt = _IBusClkDivRatio;
				IBusHClkEn = 1;
			} else {
				IBusHClkEn = 0;
			}
  		}
	} else { // No Division necessary
		IBusHClk = Clk;
		IBusHClkEn = 1;
	}

	if (_DBusClkDivRatio > 1){
		// Generate a divided Hclock and clock enables for the Data Bus

		if (Clk){
			// Generate IBus Hclk rising edge.
			if (DBusHClkEnCnt == _DBusClkDivRatio){
				DBusHClk = 1;
			}

			// Attempt a 50% duty cycle for  DBus Hclk
			// DBus Hclk falling edge for even division ratio.
			if (dbus_divratio == EVEN){
				if (DBusHClkEnCnt <= _DBusClkDivRatio / 2){
					DBusHClk = 0;
				}
		    } 
 		} else { // falling edge of system clock.
			// Generate DBusHclkEn.
			DBusHClkEnCnt--;

			// If division ratio is odd, generate the Dbus Hclk falling edge.
			if (dbus_divratio == ODD){
				if (DBusHClkEnCnt <= _DBusClkDivRatio/2){
					DBusHClk = 0;
				}
			}

			// Generate DBus HClock Enable
			if (DBusHClkEnCnt == 0){
				DBusHClkEnCnt = _DBusClkDivRatio;
				DBusHClkEn = 1;
			} else{
				DBusHClkEn = 0;
			}

  		}
	} else { // No Division necessary
		DBusHClk = Clk;
		DBusHClkEn = 1;
	}
}

void
HClkGen::reset()
{

	// Reset IBus Clocking.
	if (_IBusClkDivRatio >1 ){
		IBusHClkEn = 0;
		IBusHClk   = 0;
		IBusHClkEnCnt = _IBusClkDivRatio;
	}else{
		IBusHClkEn = 1;
		IBusHClk   = Clk;
		IBusHClkEnCnt = 1;
	}

	// Reste DBus Clocking.
	if (_DBusClkDivRatio >1 ){
		DBusHClkEn = 0;
		DBusHClk   = 0;
		DBusHClkEnCnt = _DBusClkDivRatio;
	}else{
		DBusHClkEn = 1;
		DBusHClk   = Clk;
		DBusHClkEnCnt = 1;
	}
}
