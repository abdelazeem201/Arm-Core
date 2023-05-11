#include "ahb_types.h"

using namespace ahb_namespace;

#include "DW_TCMemory.h"
#include "ahb_dw_misc.h"

static const unsigned int
big_endian_mask_8b[4] = {
	0xff000000, 0x00ff0000, 0x0000ff00, 0x000000ff
};

static const unsigned int
big_endian_mask_16b[4] = {
	0xffff0000, 0xdeadbeef, 0x0000ffff, 0xdeadbeef
};

static const unsigned int
little_endian_mask_8b[4] = {
	0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000
};

static const unsigned int
little_endian_mask_16b[4] = {
	0x0000ffff, 0xdeadbeef, 0xffff0000, 0xdeadbeef
};


#include <typeinfo>

#include <string.h>
#include <stdio.h>

DW_TCMemory::DW_TCMemory(sc_module_name   name_,
                       tcm_mem_size_t   tcm_mem_size,
                       ahb_addr_t       start_address,
                       bool             big_endian)
	: sc_module                     (name_)
    , _start_address                (start_address)
	, _big_endian                   (big_endian)
    , _write_address                (0)
	, _write_number_of_bytes        (0)
	, _data                         (0)
	, _bus_data                     (0)
	, _waitstates                   (0)
    , _ready                        (true)
    , _pending_okay                 (true)
	, _slave_port                   (0)
{
	_num_read_addresses = 0;

  // check alignment of the start address with the specified size
  switch(tcm_mem_size) {
  case TCM_4KB:
    _size_mask = 0xfff;
    break;
  case TCM_8KB:
    _size_mask = 0x1fff;
    break;
  case TCM_16KB:
    _size_mask = 0x3fff;
    break;
  case TCM_32KB:
    _size_mask = 0x7fff;
    break;
  case TCM_64KB:
    _size_mask = 0xffff;
    break;
  case TCM_128KB:
    _size_mask = 0x1ffff;
    break;
  case TCM_256KB:
    _size_mask = 0x3ffff;
    break;
  case TCM_512KB:
    _size_mask = 0x7ffff;
    break;
  case TCM_1MB:
    _size_mask = 0xfffff;
    break;
  default:
    cerr << " ERROR: invalid specification of TCM memory size passed to constructor. <" << name() << ">" << endl;
    sc_stop();
    break;
  }
  
  if(start_address&_size_mask) {
    cerr << " ERROR: start address must be aligned to memory size. <" << name() << ">" << endl;
    sc_stop();
  }
  
  // Although _mem_length and _size_mask are almost identical in value, their
  // purposes are different enough that separate variables seemed much clearer.
  _mem_length = _size_mask+1;
  
  _mem = new unsigned int [_mem_length/4];
  if(_mem == 0) {
    cerr << name() << " ERROR: unable to allocate " << _mem_length << " bytes." << endl;
    sc_stop();
  }
  
  // reset the DW_TCMemory contents to '0'
  _clear_mem();
  
  //  if(_file_name != "") {
  //    // read the initial DW_TCMemory from file
  //    read_from_file(_file_name);
  //  }
  
  if (_big_endian) {
    mask_16b = big_endian_mask_16b;
    mask_8b = big_endian_mask_8b;
  } else {
    mask_16b = little_endian_mask_16b;
    mask_8b = little_endian_mask_8b;
  }
}


// ----------------------------------------------------------------------------
//  Destructor : DW_TCMemory::~DW_TCMemory
// ----------------------------------------------------------------------------

DW_TCMemory::~DW_TCMemory()
{
	// free the allocated memory
	if(_mem != 0) {
		delete[] _mem;
		_mem = 0;
	}
}


// ----------------------------------------------------------------------------
//  Interface Method: DW_TCMemory::register_port
// ----------------------------------------------------------------------------
void
DW_TCMemory::register_port(sc_port_base& port_,
                          const         char*)
{
	if (typeid(sc_port<tcm_slave_if>) == typeid(port_)) {
		if(_slave_port != 0) {
			cout << "ERROR: TCM slave interface was already bound. <" << name() << ">" << endl;
			sc_stop();
		}
		_slave_port = &port_;
	}
}

// ----------------------------------------------------------------------------
//  Interface Method: DW_TCMemory::response
// ----------------------------------------------------------------------------
bool
DW_TCMemory::response(ahb_hresp& status_)
{
  // If a master is going to call the read() or write() method on a 
  // clock edge, it should do so after calling this method.

  // The order of calls from the master for a consecutive read-read-write-write-read
  // combination with no wait states should look like this:
  // 
  // -------------------------- ( == rising clock edge)
  // read(addr 1)                                      
  // --------------------------                     
  // response(addr 1)  
  // read(addr 2)                     
  // --------------------------             
  // response(addr 2) 
  // set_read_data(addr 1)           
  // write(addr 3)                 
  // --------------------------             
  // response(addr 3)    
  // set_read_data(addr 2)     << The fact that these two calls are made back to back for 
  // set_write_data(addr 3)    << different addresses precludes collapsing them into one method
  // write(addr 4)                      
  // --------------------------           
  // response(addr 4) 
  // set_write_data(addr 4)          
  // read(addr 5)                      
  // --------------------------            
  // response(addr 5)             
  // -------------------------- 
  // set_read_data(addr 5)
  // 
  // NOTE:  The ARM interface requires that the status associated with an
  // access launched by a Next call be returned by the Current call on that
  // same edge.  This requires running the simulation forward during that 
  // next call and collecting the status from the next simulation edge.  
  // The data for a read access is returned with the following Current call
  // unless there is a wait state.

  if (_waitstates == 0) {
#ifndef NDEBUG    
    cerr << sc_simulation_time() << ": TCM DBG: Response - ready  < " << name() << endl;
#endif
    
    if (_pending_okay) {
      status_ = OKAY;
    }
    else {
      status_ = ERROR;
      // reset the flag so it doesn't cause a subsequent abort in the case 
      // where there is not a subsequent read/write to reset it.
      _pending_okay = true;
    }
	return true;
  }
  else {
    _waitstates--;
#ifndef NDEBUG    
    cerr << sc_simulation_time() << ": TCM DBG: Response - not ready, remaining: "<< _waitstates << " < " << name() << endl;
#endif
  return false;
  }

}
// ----------------------------------------------------------------------------
//  Interface Method: DW_TCMemory::read
// ----------------------------------------------------------------------------
void
DW_TCMemory::read(ahb_addr_t address,
                 int        number_of_bytes)
{
#ifndef NDEBUG    
  cerr << sc_simulation_time() << ": TCM DBG  read  - addr:" << hex << address << " size: " << number_of_bytes << " <" << name() << endl;
#endif

  _pending_okay = true;

  if ( (address < _start_address) || 
       (address > (_start_address+_size_mask)) ) {
    if (WarningEnable) {
      cerr << sc_simulation_time() << "WARNING: Terminating read access address that is out of TCM address range: " << hex << address << " <" << name() << ">" << endl;
    }
    _pending_okay = false;
  }

  // retain only the portion of the address used to index into the memory.
  address         &= _size_mask;

  // The processor can generate unaligned accesses;  the memory interface is
  // supposed to align the address to match the size.  So for example a 4 byte
  // access to 0x300f would be aligned to 0x300c.
  switch (number_of_bytes) 
    {
    case 1:  // any addr ok
      break;
    case 2: 
      address &= ~0x1;
      break;
    case 4:
      address &= ~0x3;
      break;
    default:
      if (WarningEnable) {
        cerr << sc_simulation_time() << ": WARNING: Bad access size-- " << number_of_bytes << " bytes-- specified for TCM read access at " << hex << address << ".\n";
        cerr << "         Terminating access.  <" << name() << ">" << endl;
      }
      _pending_okay = false;
      break;
    }
  // push address, number_of_bytes on read_address_queue
  if (_num_read_addresses>1) {
        cerr << sc_simulation_time() << ": WARNING: read_address_queue overflow, max. 2 reads pending <" << name() << ">" << endl;
	    _pending_okay = false;
	} else {
		_read_address_queue[_num_read_addresses] = address;
		_read_number_of_bytes_queue[_num_read_addresses] = number_of_bytes;
		_num_read_addresses++;
	}	
  // if the access will terminate unsuccessfully, don't set up the wait states
  if (_pending_okay) {
	  	  // OSCH: was _pending_waitstates                           
    _waitstates = ReadWaitStates;
  }                     
  else {
	  	  // OSCH: was _pending_waitstates                           
    _waitstates = 0;
  }
}

// ----------------------------------------------------------------------------
//  Interface Method : DW_TCMemory::write
// ----------------------------------------------------------------------------
void
DW_TCMemory::write(ahb_addr_t address,
                  int number_of_bytes)
{
#ifndef NDEBUG    
  cerr << sc_simulation_time() << ": TCM DBG  write - addr:" << hex << address << " size: " << number_of_bytes << " <" << name() << endl;
#endif

  _pending_okay = true;

  if ( (address < _start_address) || 
       (address > (_start_address+_size_mask)) ) {
    if (WarningEnable) {
      cerr << sc_simulation_time() << ": WARNING: Terminating write access address that is out of TCM address range: " << hex << address << " <" << name() << ">" << endl;
    }
    _pending_okay = false;
  }
  
  // retain only the portion of the address used to index into the memory.
  _write_address         = (address & _size_mask);
  _write_number_of_bytes = number_of_bytes;
  
  // The processor can generate unaligned accesses;  the memory interface is
  // supposed to align the address to match the size.  So for example a 4 byte
  // access to 0x300f would be aligned to 0x300c.
  switch (number_of_bytes) 
    {
    case 1:  // any addr ok
      break;
    case 2: 
      _write_address &= ~0x1;
      break;
    case 4:
      _write_address &= ~0x3;
      break;
    default:
      if (WarningEnable) {
        cerr << sc_simulation_time() << ": WARNING: Bad access size-- " << number_of_bytes << " bytes-- specified for TCM write access at " << hex << address << ".\n";
        cerr << "         Terminating access.  <" << name() << ">" << endl;
      }
      _pending_okay = false;
      break;
    }
  
  // if the access will terminate unsuccessfully, don't set up the wait states
  if (_pending_okay) {
	  // OSCH: was _pending_waitstates                
    _waitstates = WriteWaitStates;
  }                     
  else {
	  // OSCH: was _pending_waitstates                
    _waitstates = 0;
  }
}


// ----------------------------------------------------------------------------
//  Interface Method : DW_TCMemory::set_read_data
// ----------------------------------------------------------------------------
void
DW_TCMemory::set_read_data(unsigned int* data)
{
  int index = _read_address_queue[0]/4;
  int offset = _read_address_queue[0]%4;
  
  if(_read_number_of_bytes_queue[0] == 4) {
      _data = _mem[index];
      *data = _data;
  } else if (_read_number_of_bytes_queue[0] == 2) {
      _data = *data&~mask_16b[offset];
      _data |= _mem[index]&mask_16b[offset];
      *data = _data;
  } else if (_read_number_of_bytes_queue[0] == 1) {
      _data = *data&~mask_8b[offset];
      _data |= _mem[index]&mask_8b[offset];
      *data = _data;
  }
#ifndef NDEBUG    
  cerr << sc_simulation_time() << ": TCM DBG  set_read_data - addr:" << hex << _read_address_queue[0]
       << " data: " << *data << " <" << name() << endl;
#endif

	// sanitiy check:
	if (_num_read_addresses<=0) {
        cerr << sc_simulation_time() << ": WARNING: read_address_queue underflow" << ".\n";
	} else {
		_num_read_addresses--;
		_read_address_queue[0] = _read_address_queue[1];
		_read_number_of_bytes_queue[0] = _read_number_of_bytes_queue[1];
	}	
}

// ----------------------------------------------------------------------------
//  Interface Method : DW_TCMemory::set_write_data
// ----------------------------------------------------------------------------
void
DW_TCMemory::set_write_data(unsigned int* data)
{
  int index = _write_address/4;
  int offset = _write_address%4;

#ifndef NDEBUG    
  cerr << sc_simulation_time() << ": TCM DBG  set_write_data - addr:" << hex << _write_address << " data: " << *data << " <" << name() << endl;
#endif

  if(_write_number_of_bytes == 4) {
    _mem[index] = *data;
  } 
  else if (_write_number_of_bytes == 2) {
    _mem[index] &= ~mask_16b[offset];
    _mem[index] |= (*data)&mask_16b[offset];
  } 
  else if (_write_number_of_bytes == 1) {
    _mem[index] &= ~mask_8b[offset];
    _mem[index] |= (*data)&mask_8b[offset];
  }
}

// ----------------------------------------------------------------------------
//  Interface Method : DW_TCMemory::direct_read
// ----------------------------------------------------------------------------

bool
DW_TCMemory::direct_read(ahb_addr_t  address,
                        ahb_data_t  data,
                        int         number_of_bytes)
{
  ahb_addr_t tmp_addr;
  
#ifndef NDEBUG    
  cerr << sc_simulation_time() << ": TCM DBG  direct read  - addr:" << hex << address << " size: " << number_of_bytes << " <" << name() << endl;
#endif

  if ( (address < _start_address) || 
       (address > (_start_address+_size_mask)) ) {
    //cerr << " ERROR: direct read access address out of memory range: " << address << " <" << name() << ">" << endl;
    return false;
  }
  
  // retain only the portion of the address used to index into the memory.
  tmp_addr = (address & _size_mask);
  assert ((tmp_addr>=0) && (tmp_addr<_mem_length));

  // The processor can generate unaligned accesses;  the memory interface is
  // supposed to align the address to match the size.  So for example a 4 byte
  // access to 0x300f would be aligned to 0x300c.
  switch (number_of_bytes) 
    {
    case 1:  // any addr ok
      break;
    case 2: 
      tmp_addr &= ~0x1;
      break;
    case 4:
      tmp_addr &= ~0x3;
      break;
    default:
      if (WarningEnable) {
        cerr << sc_simulation_time() << ": WARNING: Bad access size-- " << number_of_bytes << " bytes-- specified for TCM direct read access at " << hex << address << ".\n";
        cerr << "         Terminating access.  <" << name() << ">" << endl;
      }
      return false;
      break;
    }

  int index  = tmp_addr/4;
  int offset = tmp_addr%4;
  
  if(number_of_bytes == 4) {
    *data = _mem[index];
  } else if((number_of_bytes == 2)) {
    *data &= ~mask_16b[offset];
    *data |= _mem[index]&mask_16b[offset];
  } else { // 
    *data &= ~mask_8b[offset];
    *data |= _mem[index]&mask_8b[offset];
  }
  return true;
}

// ----------------------------------------------------------------------------
//  Interface Method : DW_TCMemory::direct_write
// ----------------------------------------------------------------------------

bool
DW_TCMemory::direct_write(ahb_addr_t  address,
                         ahb_data_t  data,
                         int         number_of_bytes)
{
  ahb_addr_t tmp_addr;
  
#ifndef NDEBUG    
  cerr << sc_simulation_time() << ": TCM DBG  direct write - addr:" << hex << address << " size: " << number_of_bytes << " <" << name() << endl;
#endif

  if ( (address < _start_address) || 
       (address > (_start_address+_size_mask)) ) {
    //cerr << " ERROR: direct read access address out of memory range: " << address << " <" << name() << ">" << endl;
    return false;
  }
 
  // error if writing to ReadOnly DW_TCMemory
  if (ReadOnly)
    return false;

  // retain only the portion of the address used to index into the memory.
  tmp_addr = (address & _size_mask);
  assert ((tmp_addr>=0) && (tmp_addr<_mem_length));
 
  // The processor can generate unaligned accesses;  the memory interface is
  // supposed to align the address to match the size.  So for example a 4 byte
  // access to 0x300f would be aligned to 0x300c.
  switch (number_of_bytes) 
    {
    case 1:  // any addr ok
      break;
    case 2: 
      tmp_addr &= ~0x1;
      break;
    case 4:
      tmp_addr &= ~0x3;
      break;
    default:
      if (WarningEnable) {
        cerr << sc_simulation_time() << ": WARNING: Bad access size-- " << number_of_bytes << " bytes-- specified for TCM write access at " << hex << address << ".\n";
        cerr << "         Terminating access.  <" << name() << ">" << endl;
      }
      return false;
      break;
    }
  
  int index  = tmp_addr/4;
  int offset = tmp_addr%4;

  if(number_of_bytes == 4) {
    _mem[index] = *data;
  } else if ((number_of_bytes == 2)) {
    _mem[index] &= ~mask_16b[offset];
    _mem[index] |= (*data)&mask_16b[offset];
  } else { // number_of_bytes == 1
    _mem[index] &= ~mask_8b[offset];
    _mem[index] |= (*data)&mask_8b[offset];
  }
  
  return true;
}

// ----------------------------------------------------------------------------
//  Local Method : DW_TCMemory::_clear_mem
// ----------------------------------------------------------------------------
void
DW_TCMemory::_clear_mem()
{
	memset(_mem, 0, _mem_length);
    // temp initialization to match ARM verification testbench
    // _mem[0] = 0xffffffff;
    // _mem[1] = 0xffffffff;
    // _mem[2] = 0x11112222;
    // _mem[3] = 0x33445566;
}

// ----------------------------------------------------------------------------
//  Interface Method : DW_TCMemory::read_from_file
// ----------------------------------------------------------------------------
//void
//DW_TCMemory::read_from_file(const sc_string& fn)
//{
//	FILE *stream;
//	int status;
//	unsigned int i = 0;
//	unsigned int buffer;
//
//	stream = fopen(expand(fn), "r");
//	if(stream == 0) {
//		cout << "ERROR: the data file: " << fn;
//		cout << " can not be opened for reading. <" << name() << ">" << endl;
//		sc_stop();
//	}
//
//	if (_big_endian) {
//		while ((status=fscanf(stream, "%02X", &buffer)) && (i < _mem_length)) {
//			if(status == EOF)
//				break;
//			_mem[i>>2] |= buffer<<((3-(i%4))*8);
//			i++;
//		}
//	} else {
//		while ((status=fscanf(stream, "%02X", &buffer)) && (i < _mem_length)) {
//			if(status == EOF)
//				break;
//			_mem[i>>2] |= buffer<<((i%4)*8);
//			i++;
//		}
//	}
//
//#ifndef NDEBUG
//	cerr << name() << ": read " << i << "(max: " << _mem_length << ") ";
//	cerr << " values from file: " << fn << endl;
//#endif
//
//	fclose(stream);
//}
//
//// ----------------------------------------------------------------------------
////  Interface Method : DW_TCMemory::write_to_file
//// ----------------------------------------------------------------------------
//void
//DW_TCMemory::write_to_file(const sc_string& fn)
//{
//	unsigned int  i, j;
//	char *tabstring = new char[_mem_length*3+1];
//	char *p_tabstring = tabstring;
//	FILE *stream;
//
//	stream = fopen(expand(fn), "w");
//	if(stream == 0) {
//		cout << "ERROR: the data file: " << fn;
//		cout << " can not be opened for reading. <" << name() << ">" << endl;
//		sc_stop();
//	}
//
//	if (_big_endian) { // MSB is mapped to mem[0]
//		for(i=0; i<_mem_length;) {
//			for(j=0; (j<15) && (i<(_mem_length-1)); j++, i++) {
//				fprintf(stream ,"%02X\t", (_mem[i>>2]>>((3-(i%4))*8))&0xff);
//				p_tabstring += 3;
//			}
//			fprintf(stream, "%02X\n", (_mem[i>>2]>>((3-(i%4))*8))&0xff);
//			p_tabstring += 3;
//			i++;
//		}
//	} else {           // LSB is mapped to mem[0]
//		for(i=0; i<_mem_length;) {
//			for(j=0; (j<15) && (i<(_mem_length-1)); j++, i++) {
//				fprintf(stream ,"%02X\t", (_mem[i>>2]>>((i%4)*8))&0xff);
//				p_tabstring += 3;
//			}
//			fprintf(stream, "%02X\n", (_mem[i>>2]>>24)&0xff);
//			p_tabstring += 3;
//			i++;
//		}
//	}
//	fprintf(stream, "%c\n", '\0');
//	fclose(stream);
//}

