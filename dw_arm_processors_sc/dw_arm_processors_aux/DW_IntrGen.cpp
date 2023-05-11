
#include "ahb_types.h"

using namespace ahb_namespace;

#include "DW_IntrGen.h"
#include "ahb_dw_misc.h"


#include <string.h>
#include <stdio.h>

// ----------------------------------------------------------------------------
// Constructor : DW_IntrGen::DW_IntrGen
//
// create a memory with one memory region
// ----------------------------------------------------------------------------

template<class SIF>
DW_IntrGen<SIF>::DW_IntrGen(sc_module_name   name_,
                                  ahb_addr_t       start_address,
                                  ahb_addr_t       end_address,
                                  const sc_string& file_name,
                                  bool             big_endian)
	: sc_module            (name_)
	, _file_name           (file_name)
	, _big_endian          (big_endian)
{
	InitParameters();

	// check the address range
	if(start_address >= end_address) {
		cerr << "ERROR: end address must be greater than the start address. <" << name() << ">" << endl;
		sc_stop();
	}

	// check the parameter address 1k alignment
	if(start_address&0x3FF) {
		cerr << "ERROR: start address must be 1k aligned. <" << name() << ">" << endl;
		sc_stop();
	}
	if((end_address+1)&0x3FF) {
		cerr << "ERROR: end address must be 1k aligned. <" << name() << ">" << endl;
		sc_stop();
	}

	ahb_address_region tmp(start_address, end_address);
	_address_map.push_back(tmp);
	_region_offset[0] = 0;

	_mem_length = end_address-start_address+1;
	_region_offset[0] = 0;

	create_memory();
	
	irq_pulse = 0;
	fiq_pulse = 0;
	SC_METHOD( main_action );
	sensitive_pos << clk;

	dont_initialize();
}

template<class SIF>
void
DW_IntrGen<SIF>::main_action() {
  if(_mem[0] & 0x00000001){
     if (irq_pulse){
        irq_pulse--;
        if (!irq_pulse){
           _mem[0] &= _mem[0] & 0x000fff0e;
        }
     }
     nIRQ.write(0);
   } else {
     nIRQ.write(1);
   }

   if(_mem[0] & 0x00000002){
     if (fiq_pulse){
        fiq_pulse--;
        if (!fiq_pulse){
           _mem[0] &= _mem[0] & 0xfff0000d;
        }
     }
     nFIQ.write(0);
   } else {
     nFIQ.write(1);
   }

   if(_mem[0] & 0x00000004){
     if (reset_cnt <= 1){
         nRESET.write(1);
         _mem[0] &= 0xfff0000b;
     } else {
        nRESET.write(0);
        reset_cnt--;
     }
   } else {
     nRESET.write(1);
     reset_cnt = 30;
   }

   if(_mem[0] & 0x00000008){
     VINITHI.write(1);
   } else {
     VINITHI.write(0);
   }

   if(_mem[0] & 0x00000010){
     INITRAM.write(1);
   } else {
     INITRAM.write(0);
   }
}

// ----------------------------------------------------------------------------
// Constructor : DW_IntrGen::DW_IntrGen
//
// create a memory with up to eight memory regions
// ----------------------------------------------------------------------------

template<class SIF>
DW_IntrGen<SIF>::DW_IntrGen(sc_module_name   name_,
                       const sc_string& file_name,
                       bool             big_endian,
                       ahb_addr_t       normal_start_addr1,
                       ahb_addr_t       normal_end_addr1,
                       ahb_addr_t       boot_start_addr1,
                       ahb_addr_t       boot_end_addr1,
                       ahb_addr_t       normal_start_addr2,
                       ahb_addr_t       normal_end_addr2,
                       ahb_addr_t       boot_start_addr2,
                       ahb_addr_t       boot_end_addr2,
                       ahb_addr_t       normal_start_addr3,
                       ahb_addr_t       normal_end_addr3,
                       ahb_addr_t       boot_start_addr3,
                       ahb_addr_t       boot_end_addr3,
                       ahb_addr_t       normal_start_addr4,
                       ahb_addr_t       normal_end_addr4,
                       ahb_addr_t       boot_start_addr4,
                       ahb_addr_t       boot_end_addr4,
                       ahb_addr_t       normal_start_addr5,
                       ahb_addr_t       normal_end_addr5,
                       ahb_addr_t       boot_start_addr5,
                       ahb_addr_t       boot_end_addr5,
                       ahb_addr_t       normal_start_addr6,
                       ahb_addr_t       normal_end_addr6,
                       ahb_addr_t       boot_start_addr6,
                       ahb_addr_t       boot_end_addr6,
                       ahb_addr_t       normal_start_addr7,
                       ahb_addr_t       normal_end_addr7,
                       ahb_addr_t       boot_start_addr7,
                       ahb_addr_t       boot_end_addr7,
                       ahb_addr_t       normal_start_addr8,
                       ahb_addr_t       normal_end_addr8,
                       ahb_addr_t       boot_start_addr8,
                       ahb_addr_t       boot_end_addr8
)
	: sc_module            (name_)
	, _mem_length          (0)
	, _file_name           (file_name)
	, _big_endian          (big_endian)
{
	unsigned int region_length;
	unsigned int b_start, b_end, n_start, n_end;
	ahb_address_region *tmp;

	InitParameters();

	for (int i=0; i<8; i++) {
		switch (i) {
			case 0: b_start=boot_start_addr1; b_end=boot_end_addr1; n_start=normal_start_addr1; n_end=normal_end_addr1; break;
			case 1: b_start=boot_start_addr2; b_end=boot_end_addr2; n_start=normal_start_addr2; n_end=normal_end_addr2; break;
			case 2: b_start=boot_start_addr3; b_end=boot_end_addr3; n_start=normal_start_addr3; n_end=normal_end_addr3; break;
			case 3: b_start=boot_start_addr4; b_end=boot_end_addr4; n_start=normal_start_addr4; n_end=normal_end_addr4; break;
			case 4: b_start=boot_start_addr5; b_end=boot_end_addr5; n_start=normal_start_addr5; n_end=normal_end_addr5; break;
			case 5: b_start=boot_start_addr6; b_end=boot_end_addr6; n_start=normal_start_addr6; n_end=normal_end_addr6; break;
			case 6: b_start=boot_start_addr7; b_end=boot_end_addr7; n_start=normal_start_addr7; n_end=normal_end_addr7; break;
			default: b_start=boot_start_addr8; b_end=boot_end_addr8; n_start=normal_start_addr8; n_end=normal_end_addr8; break;
		}

		// check if the region with the current index is used:
		if (n_start != 0 || n_end != 0) {
			if(n_start > n_end) {
				cerr << "ERROR: normal mode start address must be <= end_address. <" << name() << ">" << endl;
				sc_stop();
			}
			if(n_start & 0x3FF) {
				cerr << "ERROR: normal mode start address must be 1k aligned. <" << name() << ">" << endl;
				sc_stop();
			}
			if((n_end+1) & 0x3FF) {
				cerr << "ERROR: normal mode end address must be 1k aligned. <" << name() << ">" << endl;
				sc_stop();
			}
			if (b_start == 0 && b_end == 0) {
				region_length = n_end+1-n_start;
				tmp = new ahb_address_region(n_start, n_end);
			} else {
				region_length = n_end+1-n_start;
				if(b_start > b_end) {
					cerr << "ERROR: boot mode start address must be <= end_address. <" << name() << ">" << endl;
					sc_stop();
				}
				if(b_start & 0x3FF) {
					cerr << "ERROR: boot mode start address must be 1k aligned. <" << name() << ">" << endl;
					sc_stop();
				}
				if((b_end+1) & 0x3FF) {
					cerr << "ERROR: boot mode end address must be 1k aligned. <" << name() << ">" << endl;
					sc_stop();
				}
				if (region_length != b_end+1-b_start) {
					cerr << "ERROR: boot mode and normal mode region length differ. <" << name() << ">" << endl;
					sc_stop();
				}
				tmp = new ahb_address_region(n_start, n_end, b_start, b_end);
			}
		} else {
			region_length = 0;
			tmp = 0;
		}

		_region_offset[i] = _mem_length;
		_mem_length += region_length;
		if(tmp) {
			_address_map.push_back(*tmp);
			delete tmp;
			tmp = 0;
		}
	}

	create_memory();

	dont_initialize();
}


// ----------------------------------------------------------------------------
//  Method : DW_IntrGen::create_memory
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::create_memory()
{

	_mem                 = 0;
	_data                = 0;
	_waitstates          = 0;
	_idlebusy            = false;
	_ready               = true;
	_okay                = true;
	_byte_strobe         = 0;
	_unaligned           = false;
	_prot_domain         = 0;
	_protection          = 0;
	_masterid            = 0;
	_mem_monitor_table   = 0;
	_slave_port          = 0;

	for(int i=0; i<NUM_MASTERS; i++) {
		_xfer_addr[i]   = 0x0;
		_xfer_state[i]  = false;
		_xfer_domain[i] = -1;
	}

	// we might want to check for memory overlaps here ...

	try {
		_mem = new unsigned int[_mem_length/4];
	}
	catch(std::bad_alloc) {
		cerr << "ERROR: Memory allocation failed " << name() << ">" << endl;
		sc_stop();
		return;
	}

	if(DisableMonitor) {
		_mem_monitor_table = 0;
	} else {
		SC_METHOD(do_trace_action);

		char colstr[33];
		char* pcolstr = colstr;

		for(int i=0; i<16; i++) {
			sprintf(pcolstr, "%1X\t", i);
			pcolstr += 2;
		}
		colstr[32] = '\0';

		char* rowstr = 0;
		char* prowstr;

		int num_rows = 0;
		int memsize = 0;
		for(unsigned int j=0; j<_address_map.size(); j++) {
			memsize = _address_map[j].boot_end_addr-_address_map[j].boot_start_addr+1;
			num_rows += (memsize+15)/16;
		}
		rowstr = (char*) malloc(num_rows*9+1);
		if(rowstr == 0) {
			cerr << "ERROR: Memory allocation failed " << name() << ">" << endl;
			sc_stop();
			return;
		}
		rowstr[num_rows*9] = '\0';
		prowstr = rowstr;

		for(unsigned int j=0; j<_address_map.size(); j++) {
			for(unsigned int i=_address_map[j].boot_start_addr; i<=_address_map[j].boot_end_addr; i+=16) {
				sprintf(prowstr, "%08X\n", i);
				prowstr += 9;
			}
		}

		try {
			_mem_monitor_table = new ccss_monitor_table("memory_table",
			                                            "Memory Contents",
			                                            num_rows,
			                                            16,
			                                            rowstr,
			                                            colstr);
		}
		catch(std::bad_alloc) {
			cerr << "ERROR: Monitor object allocation failed " << name() << ">" << endl;
			sc_stop();
			return;
		}

		free(rowstr);

		_mem_monitor_table->initialize();
	}

	// reset the DW_IntrGen contents to '0'
	clear_mem();
}

// ----------------------------------------------------------------------------
//  Destructor : DW_IntrGen::~DW_IntrGen
// ----------------------------------------------------------------------------

template<class SIF>
DW_IntrGen<SIF>::~DW_IntrGen()
{
	// free the allocated memory
	if(_mem != 0) {
		delete[] _mem;
		_mem = 0;
	}
	if(_mem_monitor_table != 0) {
		delete _mem_monitor_table;
		_mem_monitor_table = 0;
	}
}


// ----------------------------------------------------------------------------
//  Process: memory::do_trace_action
// 
//  handler for the DoTrace parameter value change
// ----------------------------------------------------------------------------

template<class SIF>
void 
DW_IntrGen<SIF>::do_trace_action() {
	// display the full monitor contents if changed to true
	if(_mem_monitor_table && DoTrace)
		set_monitor();

	next_trigger(DoTrace.value_changed_event());
}


// ----------------------------------------------------------------------------
//  Interface Method: DW_IntrGen::register_port
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::register_port(sc_port_base& port_,
                             const char* if_typename_)
{
	sc_string nm(if_typename_);

	if( nm == typeid( ahb_slave_if ).name() || nm == typeid( ahb11ext_slave_if ).name() ) {
		// an out or inout port; only one can be connected
		if(_slave_port != 0 ) {
			cout << "ERROR: AHB slave interface was already bound. <" << name() << ">" << endl;
			sc_stop();
		}
		_slave_port = &port_;
	} /* else {
		// this code line never is reached if the class is
		// derived from only one interface
	} */
}

// ----------------------------------------------------------------------------
//  Interface Method: DW_IntrGen::register_bus
// ----------------------------------------------------------------------------

template<class SIF>
int
DW_IntrGen<SIF>::register_bus(int id,
                         int priority,
                         int address_width,
                         int data_width)
{
	_address_width_word = address_width/32;
	_data_width_word    = data_width/32;

	_strobe_width_word = (_data_width_word+7)/8;

//	_data = new (unsigned int*)[_data_width_word];
//	if(_data == 0) {
//		cerr << "ERROR: Memory allocation failed " << name() << ">" << endl;
//		sc_stop();
//	}
	return SlaveID;
}


// ----------------------------------------------------------------------------
//  Interface Method : DW_IntrGen::set_data
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::set_data(int handle_,
                             ahb_data_t data_)
{
	if (_idlebusy) {
		return;
	}

	// error if writing to ReadOnly DW_IntrGen
	if (ReadOnly && (_rwflag != RD)) {
		_okay = false;
		return;
	}

	_okay = get_physical_address (_address);
	if(!_okay) {
		return;
	}
	_data = data_;
	return;
}

// ----------------------------------------------------------------------------
//  Interface Method: DW_IntrGen::response
// ----------------------------------------------------------------------------

template<class SIF>
bool
DW_IntrGen<SIF>::response(int handle_,
                             ahb_hresp& status_)
{
		if(_idlebusy) {
			_idlebusy = false;
			status_ = OKAY;
			return true;
		}

		// check if the set_data method reported an error
		if(_okay) {
			status_ = OKAY;
			_waitstates--;
			// no error, count the number of wait cycles.
			if(_waitstates > 0) {
				_ready = false;
			} else {
				if(_protection & EXCLUSIVE) {
					// EXCLUSIVE ACCESS
					if (_rwflag == RD) {
						// exclusive read
						_xfer_addr[_masterid]   = _address;
						_xfer_state[_masterid]  = true;
						_xfer_domain[_masterid] = _prot_domain;
					} else {
						// exclusive write
						if(_xfer_state[_masterid] && (_xfer_addr[_masterid] == _address)) {
							_xfer_state[_masterid]  = false;
						} else {
							status_ = XFAIL;
							_ready = true;
							return false;
						}
					}
				} else {
					// NON-EXCLUSIVE ACCESS
					if(_rwflag == WR) {
						if(_xfer_state[_masterid] && (_xfer_addr[_masterid] == _address)) {
							_xfer_state[_masterid] = false;
						} else {
							for(int i=0; i<NUM_MASTERS; i++) {
								if((_xfer_domain[i] == _prot_domain) && (_xfer_addr[i] == _address))
									_xfer_state[i] = false;
							}
						}
					}
				}
				if (_rwflag == RD) {
					_okay =  get_mem(_address, _data, _byte_strobe, _num_bytes);
				} else {
					_okay =  put_mem(_address, _data, _byte_strobe, _num_bytes);
				}
				_byte_strobe = 0;
				_ready = true;
				if(_okay) {
					status_ = OKAY;
					return true;
				} else {
					status_ = ERROR;
					return false;
				}
			}
			return _ready;
		} else {
			status_ = ERROR;
			_ready = true;
		}

		return _okay;
}


// ----------------------------------------------------------------------------
//  Interface Method: DW_IntrGen::read
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::read(int        handle_,
                    ahb_addr_t address,
                    ahb_hsize  hsize)
{

		_address         = address;
		_num_bytes       = 1<<hsize;
		_rwflag          = RD;

		if(_ready)
			_waitstates = ReadWaitStates+1;

}


// ----------------------------------------------------------------------------
//  Interface Method : DW_IntrGen::write
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::write(int handle_,
                          ahb_addr_t address,
                          ahb_hsize  hsize)
{

		_address         = address;
		_num_bytes       = 1<<hsize;
		_rwflag          = WR;

		if(_ready)
			_waitstates = WriteWaitStates+1;

}


// ----------------------------------------------------------------------------
//  Interface Method : DW_IntrGen::control info
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::control_info(int,
								 ahb_hburst,
                                 ahb_htrans     transf_type_,
                                 ahb_hprot      protection_,
                                 int           masterid_,
                                 bool)
{
	if(_ready) {
		// explicit busy or idle command, response must be AHB_OKAY
		switch(transf_type_) {
			case BUSY:
				_idlebusy   = true;
				_waitstates--;
			break;
			case IDLE:
				_idlebusy   = true;
				_waitstates = 0;
			break;
			default:
				// store the transfer control information
				_protection = protection_;
				_masterid   = masterid_;
			break;
		}
	}
}

template<>
void
DW_IntrGen<ahb11ext_slave_if>::set_ahb11ext_control(int,                              // bus id
                                                       const unsigned int* byte_strobe_, // byte strobe line information
                                                       bool unaligned_,                  // unaligned access indication
                                                       int prot_domain_)                 // protection domain
{
	if(_ready) {
		_byte_strobe = byte_strobe_;
		_unaligned   = unaligned_;
		_prot_domain = prot_domain_;
	}
}

// ----------------------------------------------------------------------------
//  Interface Method : DW_IntrGen::direct_read
// ----------------------------------------------------------------------------

template<class SIF>
bool
DW_IntrGen<SIF>::direct_read(int        handle_,
                           ahb_addr_t address,
                           ahb_data_t data_,
                           int        num_bytes_)
{
	unsigned int tmp_addr = address;
	bool okay;

	okay = get_physical_address (tmp_addr);
	if(!okay)
		return false;

	return get_mem(tmp_addr, data_, 0, num_bytes_);
}


// ----------------------------------------------------------------------------
//  Interface Method : DW_IntrGen::direct_write
// ----------------------------------------------------------------------------

template<class SIF>
bool
DW_IntrGen<SIF>::direct_write(int        handle_,
                            ahb_addr_t address,
                            ahb_data_t data_,
                            int        num_bytes_)
{
	unsigned int tmp_addr = address;
	bool okay;

	// error if writing to ReadOnly DW_IntrGen
	if (ReadOnly)
		return false;

	okay = get_physical_address (tmp_addr);
	if(!okay)
		return false;

	return put_mem(tmp_addr, data_, 0, num_bytes_);
}


// ----------------------------------------------------------------------------
// Method: DW_IntrGen::get_physical_address
//
// translates the address in the memory regions into an address in
// physical memory _mem (all values character based)
// ----------------------------------------------------------------------------

template<class SIF>
bool
DW_IntrGen<SIF>::get_physical_address(unsigned int& abs_address)
{
	unsigned int i = 0;

	do {
		if ((abs_address>=_address_map[i].boot_start_addr) &&
		    (abs_address<=_address_map[i].boot_end_addr)) {
			abs_address = abs_address-_address_map[i].boot_start_addr+_region_offset[i];
			return true;
		}
		i++;
	} while (i < _address_map.size());

	return false;
}

template<class SIF>
bool
DW_IntrGen<SIF>::get_mem(unsigned int        address_,
                       ahb_data_t          bdata_,
                       const unsigned int* byte_strobe_,
                       int                 num_bytes_)
{
	int index = ((address_>>2)/_data_width_word)*_data_width_word;

	// unaligned access
	if(address_%num_bytes_)
		return false;
	if(byte_strobe_ == 0) {
		byte_strobe_ = _tmp_byte_strobe;
		calculate_strobe(address_, num_bytes_, _data_width_word, _big_endian, _tmp_byte_strobe);
	}

	// for all words:
	for(int i=_data_width_word-1; i>=0; i--) {
		int mask_idx = (byte_strobe_[i/8]>>(i*4))&0xf;
		unsigned int mask = byte_strobe_mask[mask_idx];

		bdata_[i] &= ~mask;
		bdata_[i] |= _mem[index+i]&mask;
	}

	return true;
}

template<class SIF>
bool
DW_IntrGen<SIF>::put_mem(unsigned int   address_,
                       ahb_data_t          bdata_,
                       const unsigned int* byte_strobe_,
                       int                 num_bytes_)
{
	int index = ((address_>>2)/_data_width_word)*_data_width_word;

	// unaligned access
	if(address_%num_bytes_)
		return false;
	if(byte_strobe_ == 0) {
		byte_strobe_ = _tmp_byte_strobe;
		calculate_strobe(address_, num_bytes_, _data_width_word, _big_endian, _tmp_byte_strobe);
	}

	// for all words:
	for(int i=_data_width_word-1; i>=0; i--) {
		int mask_idx = (byte_strobe_[i/8]>>(i*4))&0xf;
		unsigned int mask = byte_strobe_mask[mask_idx];

		_mem[index+i] &= ~mask;
		_mem[index+i] |= bdata_[i]&mask;

	}

	if(_mem_monitor_table && DoTrace) {
		for(int i=0; i<_data_width_word; i++) {
			set_monitor((index+i)*4);
		}
		_mem_monitor_table->apply();
	}

	return true;
}

// ----------------------------------------------------------------------------
// Method : DW_IntrGen::clear_mem
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::clear_mem()
{
	memset(_mem, 0, _mem_length);

	if(_file_name != "") {
		// read the initial DW_IntrGen from file
		read_from_file(_file_name);
	}

	if(_mem_monitor_table && DoTrace)
		set_monitor();
}


// ----------------------------------------------------------------------------
// Method : DW_IntrGen::read_from_file
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::read_from_file(const sc_string& fn)
{
	FILE *stream;
	int status;
	unsigned int i = 0;
	unsigned int buffer;

	stream = fopen(expand(fn), "r");
	if(stream == 0) {
		cout << "ERROR: the data file: " << fn;
		cout << " can not be opened for reading. <" << name() << ">" << endl;
		sc_stop();
	}

	if (_big_endian) {
		while ((status=fscanf(stream, "%02X", &buffer)) && (i < _mem_length)) {
			if(status == EOF)
				break;
			_mem[i>>2] |= buffer<<((3-(i%4))*8);
			i++;
		}
	} else {
		while ((status=fscanf(stream, "%02X", &buffer)) && (i < _mem_length)) {
			if(status == EOF)
				break;
			_mem[i>>2] |= buffer<<((i%4)*8);
			i++;
		}
	}

	fclose(stream);
}


// ----------------------------------------------------------------------------
// Method : DW_IntrGen::write_to_file
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::write_to_file(const sc_string& fn)
{
	unsigned int  i, j;
	char *tabstring, *p_tabstring;
	FILE *stream;

	stream = fopen(expand(fn), "w");
	if(stream == 0) {
		cout << "WARNING: The data file: " << fn;
		cout << " can not be opened for writing. <" << name() << ">" << endl;
		return;
	}
	tabstring = (char*) malloc(_mem_length*3+1);
	if(tabstring == 0) {
		cout << "WARNING: Memory allocation error, file not written. <" << name() << ">" << endl;
		return;
	}
	p_tabstring = tabstring;

	if (_big_endian) { // MSB is mapped to mem[0]
		for(i=0; i<_mem_length;) {
			for(j=0; (j<15) && (i<(_mem_length-1)); j++, i++) {
				fprintf(stream ,"%02X\t", (_mem[i>>2]>>((3-(i%4))*8))&0xff);
				p_tabstring += 3;
			}
			fprintf(stream, "%02X\n", (_mem[i>>2]>>((3-(i%4))*8))&0xff);
			p_tabstring += 3;
			i++;
		}
	} else {           // LSB is mapped to mem[0]
		for(i=0; i<_mem_length;) {
			for(j=0; (j<15) && (i<(_mem_length-1)); j++, i++) {
				fprintf(stream ,"%02X\t", (_mem[i>>2]>>((i%4)*8))&0xff);
				p_tabstring += 3;
			}
			fprintf(stream, "%02X\n", (_mem[i>>2]>>24)&0xff);
			p_tabstring += 3;
			i++;
		}
	}
	fprintf(stream, "%c\n", '\0');
	fclose(stream);
}


// ----------------------------------------------------------------------------
// Method : DW_IntrGen::set_monitor
//
// (re-) draw the complete monitor object
// ----------------------------------------------------------------------------

template<class SIF>
void
DW_IntrGen<SIF>::set_monitor()
{
	int  i, j;
	int offset = 0;
	int trace_length = _mem_length;
	char *tabstring, *p_tabstring;

	tabstring = (char*) malloc(trace_length*3+1);
	if(tabstring == 0) {
		cout << "WARNING: Monitor memory allocation error, monitoring disabled. <" << name() << ">" << endl;
		DisableMonitor = true;
		return;
	}
	p_tabstring = tabstring;

	if (_big_endian) { // big endian, MSB is mapped to mem[0]
		for(i=0; i<trace_length;) {
			for(j=0; (j<15) && (i<(trace_length-1)); j++, i++) {
				sprintf(p_tabstring,"%02X\t", (_mem[(offset+i)>>2]>>((3-(i%4))*8))&0xff);
				p_tabstring += 3;
			}
			sprintf(p_tabstring,"%02X\n", (_mem[(offset+i)>>2]>>((3-(i%4))*8))&0xff);
			p_tabstring += 3;
			i++;
		}
	} else { // LSB is mapped to mem[0]
			for(i=0; i<trace_length;) {
			for(j=0; (j<15) && (i<(trace_length-1)); j++, i++) {
				sprintf(p_tabstring,"%02X\t", (_mem[(offset+i)>>2]>>((i%4)*8))&0xff);
				p_tabstring += 3;
			}
			sprintf(p_tabstring,"%02X\n", (_mem[(offset+i)>>2]>>24)&0xff);
			p_tabstring += 3;
			i++;
		}
	}

	tabstring[trace_length*3]='\0';
	_mem_monitor_table->set(tabstring);
	_mem_monitor_table->apply();
	free(tabstring);
}

// ----------------------------------------------------------------------------
// Method :DW_IntrGen::set_monitor
//
// update one single address of the monitor
// ----------------------------------------------------------------------------
template<class SIF>
void
DW_IntrGen<SIF>::set_monitor(int idx_)
{
	char tabstring [12];
	int offset = idx_&(~0x3);

	if (_big_endian) { // big endian, MSB is mapped to mem[0]
		for(int i=0; i<4; ++i) {
			sprintf(tabstring,"%02X", (_mem[(offset+i)>>2]>>((3-(i%4))*8))&0xff);
			_mem_monitor_table->change(offset/16, (offset+i)%16, tabstring);
		}
	} else {           // LSB is mapped to mem[0]
		for(int j=0; j<4; ++j) {
			sprintf(tabstring,"%02X", (_mem[(offset+j)>>2]>>((j%4)*8))&0xff);
			_mem_monitor_table->change(offset/16, (offset+j)%16, tabstring);
		}
	}
}

// Explicit instantiation makes your compiler perform a complete processing
// of the template class with the given arguments. For example:
template class DW_IntrGen<ahb_slave_if>;
template class DW_IntrGen<ahb11ext_slave_if>;
