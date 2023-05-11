#ifndef __DW_TCMemory_h
#define __DW_TCMemory_h


#include <systemc.h>
#include <ccss_systemc.h>

#include "tcm_slave_if.h"


#ifdef CCSS_USE_SC_CTOR
#undef CCSS_USE_SC_CTOR
#endif

#define CCSS_INIT_MEMBERS 

// The DW_TCMemory module is a memory that implements the transaction-level
// interface defined in tcm_slave_if.h. An instance should be connected to
// each of the TCM ports on the processor model.
// 
// The constructor has the following arguments:
// 
//   sc_module_name name_                  // name of the module
//   tcm_mem_size_t tcm_mem_size           // size of the memory
//   ahb_addr_t start_address              // start address of the memory
//   bool big_endian = false               // little endian memory addressing
// 
// The memory size is configurable from 4KBytes to 1MBytes.  The tcm_mem_size_t
// type is defined in tcm_types.h. The start address must be aligned to the 
// specified memory size.
// 
// The memory is initialized to zero values.
// 
// If warnings are enabled via the WarningEnable parameter, the module will
// issue a warning if the processor attempts to access an address in the TCM 
// that is outside the specified range.  Note that the processor model 
// sometimes generates speculative fetches that are directed to the wrong 
// memory interface.  Although the TCM module will flag these accesses, they
// are harmless because the processor model internally discards the results.
class DW_TCMemory// Tightly-Coupled Memory Module
	: public sc_module
	, public tcm_slave_if
{

public:
    // parameters

    // This identifier for the slave is used by the Inter
    // Connection Matrix (ICM) to identify the slave.
    CCSS_PARAMETER(int, SlaveID);

    // This parameter specifies the number of data cycle wait
    // states to complete a data transfer.
    CCSS_PARAMETER(int, ReadWaitStates);

    // This parameter specifies the number of data cycle wait
    // states to complete a data transfer.
    CCSS_PARAMETER(int, WriteWaitStates);

    // Parameter to enable the read only mode (Read Only Memory)
    CCSS_PARAMETER(bool, ReadOnly);

    // This flag enables monitoring features if compiled with debug option.
    CCSS_PARAMETER(bool, DoTrace);
    CCSS_PARAMETER(bool, WarningEnable);

    // ports

    // initialize parameters
    virtual void InitParameters() {
        int _tmp_SlaveID = 0;
        SlaveID.conditional_init(_tmp_SlaveID);
        int _tmp_ReadWaitStates = 0;
        ReadWaitStates.conditional_init(_tmp_ReadWaitStates);
        int _tmp_WriteWaitStates = 0;
        WriteWaitStates.conditional_init(_tmp_WriteWaitStates);
        bool _tmp_ReadOnly = false;
        ReadOnly.conditional_init(_tmp_ReadOnly);
        bool _tmp_DoTrace = false;
        DoTrace.conditional_init(_tmp_DoTrace);
        bool _tmp_WarningEnable = false;
        WarningEnable.conditional_init(_tmp_WarningEnable);
    }

	SC_HAS_PROCESS(DW_TCMemory);

	// constructor 1
    DW_TCMemory(sc_module_name   name_,             // name of the module
               tcm_mem_size_t tcm_mem_size,        // memory size (enumerated type)
               ahb_addr_t start_address,           // start address of the memory in normal mode
               bool big_endian = false);           // memory encoding (little endian default)

	~DW_TCMemory();

	// interface methods

	// Register a port, make sure that only one port
	// is connected to the interface.
	void
	register_port(sc_port_base&,
	              const char*);

	// Query the status response of the transaction.
	bool
	response(ahb_hresp&);

	// Initiate a read transaction from the slave.
	void
	read(ahb_addr_t,           // address
	     int);                 // number of bytes

	// Write data to the slave.
	void
	write(ahb_addr_t,          // address
	      int);                // number of bytes

	// Set the data pointer where the data shoud be
	// written from for a read transaction
	void
	set_read_data(unsigned int*);   // pointer to the data


	// Set the data pointer where the data shoud be
	// read from for a write transaction
	void
	set_write_data(unsigned int*);   // pointer to the data


	// Read the memory from a file
	//void
	//read_from_file(const sc_string&);

	// Write the memory contents to a file
	//virtual void
	//write_to_file(const sc_string&);

	// Direct read from the memory for debugging purposes
	bool
	direct_read(ahb_addr_t,    // address
	            ahb_data_t,    // data
	            int = 4 );     // number of bytes

	// Direct write to the memory for debugging purposes
	bool
	direct_write(ahb_addr_t,   // address
	             ahb_data_t,   // data
	             int = 4);     // number of bytes

private:

	// Clear the memory contrents to zero
	void
	_clear_mem();

	unsigned int*       _mem;
	unsigned int        _mem_length;
	unsigned int        _size_mask;

    ahb_addr_t          _start_address;

	bool                _big_endian;

	ahb_addr_t          _read_address_queue[2]; //queue of read addresses, pushed at read(), poped at set_read_data()
	int                 _read_number_of_bytes_queue[2];
	int                 _num_read_addresses;
	ahb_addr_t          _write_address;
	int                 _write_number_of_bytes;

	ahb_addr_t          _last_address;
	int                 _last_number_of_bytes;

	unsigned int        _data;
	unsigned int*       _bus_data;

	int                 _waitstates;
	bool                _ready;
	bool                _pending_okay;

	const unsigned int* mask_8b;
	const unsigned int* mask_16b;

	sc_port_base*       _slave_port;

}; // end module DW_TCMemory
#undef CCSS_INIT_MEMBERS

#endif
