// ============================================================================
//  Description : Slave interface for the TCM
//      Project : Abstract Bus Model
//       Author : Gordon Battaile
//         Date : 04/5/2002
//
//  Copyright (c) 2002 by Synopsys, Inc.
// ============================================================================


#ifndef TCM_SLAVE_IF_H
#define TCM_SLAVE_IF_H

#include "tcm_types.h"
#include "systemc.h"


// ----------------------------------------------------------------------------
//  INTERFACE : tcm_slave_if
//
//  Slave interface for the TCM interface.
// ----------------------------------------------------------------------------

class tcm_slave_if :
  public sc_interface
{
public:

	// Submit a read request with corresponding address to the slave.
	// The slave has to respond to this request at the next cycle.
	virtual void
	read(ahb_addr_t,                          // the address
	     int) = 0;                            // number of bytes

	// Submit a write request with corresponding address to the slave.
	// The slave has to respond to this request at the next cycle.
	virtual void
	write(ahb_addr_t,                         // the address
	      int) = 0;                           // number of bytes

	// Set the pointer to the location where the slave should write
	// the requested data. This is only allowed if the transaction 
	// of the last cycle has finished (no wait state). This method 
	// must only be called once per request.
	virtual void
	set_read_data(unsigned int*) = 0;         // pointer to data

	// Set the pointer to the location from which the slave should 
	// read the data.  This is only allowed if the transaction of the
	// last cycle has finished (no wait state). This method must
	// only be called once per request.
	virtual void
	set_write_data(unsigned int*) = 0;        // pointer to data

	// Query the ready response of the slave.  For a read request
    // this will apply to the request initiated on the previous cycle,
    // and for a write request it will apply to the request initiated
    // on the current cycle.
	virtual bool
	response(ahb_hresp&) = 0;                // status response

    // debug read access
    virtual bool
    direct_read(ahb_addr_t,ahb_data_t, int) = 0;

    // debug write access
    virtual bool
    direct_write(ahb_addr_t,ahb_data_t, int) = 0;

};

#endif
