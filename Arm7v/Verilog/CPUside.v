// Memory Interface - Main ASM.

`timescale 1ns/100ps 

module CPU_coupler(D, A, nMREQ, nRW, MAS, nWAIT, sysclk, reset, Store_Trigger, Load_Trigger, 
		   write_buffer_data, write_buffer_addr, write_buffer_is_byte, st_busy, ld_busy, 
		   load_from_mem_req, load_from_mem_data, load_from_mem_offset);
   inout [31:0]  D;

   input [31:0]  A;
   input 	 nMREQ;
   input 	 nRW;
   input [1:0] 	 MAS;
   input 	 st_busy, ld_busy;
   input 	 sysclk, reset;
   input 	load_from_mem_req;
   input [31:0] load_from_mem_data;
   input [1:0] 	load_from_mem_offset;
   
   output 	 nWAIT;
   output 	 Store_Trigger, Load_Trigger;
   output 	 write_buffer_is_byte;
   output [31:0] write_buffer_data, write_buffer_addr;    
   
   wire [31:0] 	D;
   wire [31:0] 	A;
   wire 	nMREQ, nRW;
   wire [1:0] 	MAS;
   wire		nWAIT;
   wire 	st_busy, ld_busy;
   wire 	sysclk, reset;
   reg [31:0] 	write_buffer_data;
   reg [31:0] 	write_buffer_addr;
   reg 		write_buffer_is_byte;
   reg 		Load_Trigger, Store_Trigger;
   wire 	load_from_mem_req;
   wire [31:0]	load_from_mem_data;
   wire [1:0] 	load_from_mem_offset;
   
   // All defines
   `define MAIN_CACHE_LINES     64
   `define MAIN_CACHE_LINE_BITS 6
   // _BITS - 1 + 4
   `define MAIN_CACHE_LINE_BIT_HIGH 9
   // - 1 + 4 = Ignore 4word addr.
   `define MAIN_CACHE_LINE_BIT_LOW 4
   `define MAIN_CACHE_TAG_BITS  22
   // 31 - BITS
   `define MAIN_CACHE_TAG_BIT_LOW 9
   `define MAIN_CACHE_TAG_BIT_HIGH 31
 
   `define VICTIM_CACHE_LINES     4
   `define VICTIM_CACHE_TAG_BITS  28
   
   `define CPUSIDE_NUM_STATE_BITS 4
   `define CPUSIDE_IDLE           4'b0000
   `define CPUSIDE_WAIT	          4'b0001
   `define CPUSIDE_WAIT2          4'b0010
   `define CPUSIDE_LOADING        4'b0011
   `define CPUSIDE_LOADEND        4'b0100

   // Use DEDSEC?
   `define DO_DEDSEC
   //`define DEDSEC_DEBUG

   // Tell me what you're doing?
   //`define TALK
   
   // Registers used by CPU ASM  (Memory Registers are just above its ASM, lower down)
   reg [127:0]                      main_cache        [`MAIN_CACHE_LINES-1:0];
   reg [`MAIN_CACHE_TAG_BITS-1:0]   main_cache_tag    [`MAIN_CACHE_LINES-1:0];
   reg [24:0] 			    main_cache_dedsec [`MAIN_CACHE_LINES-1:0];
   reg 				    main_cache_valid  [`MAIN_CACHE_LINES-1:0];
   
   reg [127:0] 			    victim_cache        [`VICTIM_CACHE_LINES-1:0];
   reg [`VICTIM_CACHE_TAG_BITS-1:0] victim_cache_tag    [`VICTIM_CACHE_LINES-1:0];
   reg [24:0] 			    victim_cache_dedsec [`VICTIM_CACHE_LINES-1:0];
   reg 				    victim_cache_valid  [`VICTIM_CACHE_LINES-1:0];
   reg [1:0] 			    oldest_victim_line;
   
   reg [`CPUSIDE_NUM_STATE_BITS-1:0] present_cpu_state;
   reg 			     cpu_busy;
   reg [31:0]		     Dout;
   reg 			     victim_dedsec_result, main_dedsec_result;

   // Required by initial for loop
   integer 		     i; 

`ifdef DO_DEDSEC
   function [24:0] dedsec_bits;
      input [127:0] 	     data;
      integer 		     i,j;

      begin
	 
	 // Horizontal decsec bits	
	 // Calculate the horizontal dedsec bits on the bottom. 
	 // The code, rather silly, calculate the dedsec bits of the column of data one by one. 
	 dedsec_bits[24] = data[127]^data[111]^data[95]^data[79]^data[63]^data[47]^data[31]^data[15];
	 dedsec_bits[23] = data[126]^data[110]^data[94]^data[78]^data[62]^data[46]^data[30]^data[14];
	 dedsec_bits[22] = data[125]^data[109]^data[93]^data[77]^data[61]^data[45]^data[29]^data[13];
	 dedsec_bits[21] = data[124]^data[108]^data[92]^data[76]^data[60]^data[44]^data[28]^data[12];
	 dedsec_bits[20] = data[123]^data[107]^data[91]^data[75]^data[59]^data[43]^data[27]^data[11];
	 dedsec_bits[19] = data[122]^data[106]^data[90]^data[74]^data[58]^data[42]^data[26]^data[10];
	 dedsec_bits[18] = data[121]^data[105]^data[89]^data[73]^data[57]^data[41]^data[25]^data[ 9];
	 dedsec_bits[17] = data[120]^data[104]^data[88]^data[72]^data[56]^data[40]^data[24]^data[ 8];
	 dedsec_bits[16] = data[119]^data[103]^data[87]^data[71]^data[55]^data[39]^data[23]^data[ 7];
	 dedsec_bits[15] = data[118]^data[102]^data[86]^data[70]^data[54]^data[38]^data[22]^data[ 6];
	 dedsec_bits[14] = data[117]^data[101]^data[85]^data[69]^data[53]^data[37]^data[21]^data[ 5];
	 dedsec_bits[13] = data[116]^data[100]^data[84]^data[68]^data[52]^data[36]^data[20]^data[ 4];
	 dedsec_bits[12] = data[115]^data[ 99]^data[83]^data[67]^data[51]^data[35]^data[19]^data[ 3];
	 dedsec_bits[11] = data[114]^data[ 98]^data[82]^data[66]^data[50]^data[34]^data[18]^data[ 2];
	 dedsec_bits[10] = data[113]^data[ 97]^data[81]^data[65]^data[49]^data[33]^data[17]^data[ 1];
	 dedsec_bits[ 9] = data[112]^data[ 96]^data[80]^data[64]^data[48]^data[32]^data[16]^data[ 0];
	 
	 // Vertical dedsec bits
	 // Calculate the vertical dedsec bits on the right side. 
	 // The following eight line of code initialize the dedsec_bits, xoring the first two
	 //  data bits together.
	 dedsec_bits[8]=data[127]^data[126];
	 dedsec_bits[7]=data[111]^data[110];
	 dedsec_bits[6]=data[95]^data[94];
	 dedsec_bits[5]=data[79]^data[78];
	 dedsec_bits[4]=data[63]^data[62];
	 dedsec_bits[3]=data[47]^data[46];
	 dedsec_bits[2]=data[31]^data[30];
	 dedsec_bits[1]=data[15]^data[14];

	 // The following double for-loop xor the rest of the data bits. 
	 for ( i=8 ; i>=1; i=i-1 )
	    begin
	       for ( j=(i*16)-3; j>=((i-1)*16); j=j-1)
		  begin
		     dedsec_bits[i] = dedsec_bits[i] ^ data[j];
		  end
	    end
	 
	 // Calculate the combined dedsec bit
	 // As with the previous calculations, firstly xor the first two bits 
	 //  together, then xor the rest of the bits in the for loop 
	 dedsec_bits[0]=dedsec_bits[1]^dedsec_bits[2];
	 for ( i=3 ; i<=24; i=i+1)
	    begin
	       dedsec_bits[0] = dedsec_bits[0] ^ dedsec_bits[i];
	    end // for ( i=3 ; i<=24; i=i+1)

	 `ifdef DEDSEC_DEBUG
	    $display("DEDSEC DEBUG dedsec_bits: input=%h dedsec_bits=%h", data, dedsec_bits);
	 `endif
	 
      end
   endfunction // dedsec_bits
`else
   function [24:0] dedsec_bits;
      input [127:0]          data;
      dedsec_bits = 25'b1;
   endfunction // dedsec_bits
`endif   

   // Returns whether the given data passes the DEDSEC test
`ifdef DO_DEDSEC   
   task pass_dedsec;
      inout [127:0]           data;
      inout [24:0] 	      dedsec;
      output 		      pass_dedsec;
      
      reg [127:0] 	      data;
      reg [24:0] 	      dedsec;	
      reg [24:0] 	      old_dedsec;
      reg [24:0] 	      new_dedsec;
      reg 		      pass_dedsec;
      integer 		      i, no_of_error, error_location1, error_location2, temp, l;
      
      begin
	 
	 no_of_error = 0;
	 
	 old_dedsec = dedsec;
	 
	 new_dedsec = dedsec_bits(data);
	 
	 // Calculate the number of error, as well as notice the location 
	 //  of the errors  
	 for ( i = 24 ; i >= 0 ; i = i - 1 )
	    begin
	       if ( old_dedsec[i] != new_dedsec[i] )
		  begin
		     no_of_error = no_of_error + 1;
		     
		     if ( no_of_error == 1 ) 
			begin
			   error_location1 = i; 
			end
		     else if ( no_of_error == 2 )
			begin
			   error_location2 = i;
			end
		     
		  end
	    end
	 
	 pass_dedsec = 1'b1;
	 
	 if ( no_of_error == 0 ) 
	    begin
	       pass_dedsec = 1'b1;
	    end
	 else if ( error_location1 <= 24 && error_location2 <= 24 
		   && error_location1 >= 9 && error_location2 >= 9 )
	    // Same row of bits contains error bits, can't recover
	    begin
	       pass_dedsec = 1'b0; 
	    end
	 else if ( error_location1 <= 8 && error_location2 <= 8 
		   && error_location1 >= 1 && error_location2 >= 1 ) 
	    // Same column of bits contains error bits, can't recover
	    begin
	       pass_dedsec = 1'b0; 
	    end
	 else if ( no_of_error >= 3 ) // too many errors, can't recover
	    begin
	       pass_dedsec = 1'b0;
	    end 
	 else if ( error_location1 == 0 && no_of_error == 1 ) 
	    begin 
	       // Just for the zeroth dedsec bit is in error.
	       // Error correctable, just modify the corner bit of DEDSEC.
	       // Recalculate the combined dedsec bit.
	       dedsec[0]=dedsec[1]^dedsec[2];
	       for ( i=3 ; i<=24; i=i+1)
		  begin
		     dedsec[0] = dedsec[0] ^ dedsec[i];
		  end
	    end
	  else if ( error_location1 == 0 || error_location2 == 0) 
	     // One error bit in the 0th dedsec bit another in row/column.
	     begin
		// Make error_location2 contains the nonzero location, to 
		//  unify the correcting process 
		if ( error_location2 == 0) 
		   begin
		      error_location2 = error_location1;
		      error_location1 = 0;	
		   end
		// If the error location is the horizontal dedsec row, 
		//  then the dedsec bit is in error, recalculate that bit
		if ( error_location2 <= 24 && error_location2 >= 9 ) 
		   begin
		      dedsec[error_location2] = data[error_location2] ^ data[error_location2+16];
		      for (i = 2; i <= 7 ; i = i+1 )
			 begin
			    dedsec[error_location2] = dedsec[error_location2] ^    
			       data[error_location2 + 16 * i];
			 end
		   end	
		// If the error location is the vertical dedsec column
		//  then the dedsec bit is in error, recalculate that bit
		if ( error_location2 <= 8 && error_location2 >= 1 ) 
		   begin
		      dedsec[error_location2] = data[(error_location2-1)*16] ^
					data[(error_location2-1)*16+1];
		      for (i = 2; i <= 15 ; i = i+1 )
			 begin
			    dedsec[error_location2] = dedsec[error_location2] ^    
			       data[(error_location2-1)*16+i];
			 end
		   end	
		
		// Finally, after recalculating the error bit in the row/col,
		//  recalculate the faulty zeroth dedsec bit. 
		dedsec[0]=dedsec[1]^dedsec[2];
		for ( i=3 ; i<=24; i=i+1)
		   begin
		      dedsec[0] = dedsec[0] ^ dedsec[i];
		   end
	     end
	  else 
	     // Finally, it is the normal case where the dedsec bit 
	     //  themselves has no error and only 1 data bit have error 
	     begin
		// If error_loc2>error_loc1 swap them to facilitate the program
		if ( error_location2 > error_location1 ) 
		   begin
		      temp = error_location2;
		      error_location2 = error_location1;
		      error_location1 = temp; 
		   end
		// Calculate the error bit location and invert it
		l = (error_location2 - 1) * 16 + (error_location1 - 9);
		data[l] = ~data[l]; 
	     end
	 
	 `ifdef DEDSEC_DEBUG
	    $display("DEDSEC DEBUG pass_dedsec: Data:new=%h dedsec:dedsec1=%h old=%h new=%h pass=%b",
		     data, dedsec, old_dedsec, new_dedsec, pass_dedsec);
	 `endif
      end
   endtask
`else // If NOT DO_DEDSEC
   task pass_dedsec;
      inout [127:0]           data;
      inout [24:0] 	      dedsec;
      output 		      pass_dedsec;
      
      pass_dedsec = 1;
   endtask
`endif
   
   // Use word bits to input (update) the appropriate word from D to the cacheline
   // Note that to be able to calculate the dedsec in this same cycle, we need to take the
   //  merge of the current cacheline and the new cache word.
   task input_word;
      inout [127:0] 	     cacheline;  // Line to put the word
      input [1:0] 	     word;       // Word index (within cache line)
      input [31:0] 	     source;     // Where to get the update (D or load_from_mem_data)
      output [24:0] 	     dedsec;     // New DEDSEC for this line

      begin
	 case (word)
	   2'b00 : 
	      begin 
		 cacheline[31:0]   = source; 
		 dedsec = dedsec_bits({cacheline[127: 32], source                 }); 
	      end
	   2'b01 : 
	      begin 
		 cacheline[63:32]  = source; 
		 dedsec = dedsec_bits({cacheline[127: 64], source, cacheline[31:0]}); 
	      end
	   2'b10 : 
	      begin 
		 cacheline[95:64]  = source; 
		 dedsec = dedsec_bits({cacheline[127: 96], source, cacheline[63:0]}); 
	      end
	   2'b11 : 
	      begin 
		 cacheline[127:96] = source; 
		 dedsec = dedsec_bits({                    source, cacheline[95:0]}); 
	      end
	 endcase //case(address[3:2])
      end
   endtask // input_word
      
   // Use lowest bits of address to input (update) the appropriate byte to the cacheline from D
   // Note that to be able to calculate the dedsec in this same cycle, we need to take the
   //  merge of the current cacheline and the new cache word.
   task input_byte;
      inout [127:0] 	     cacheline; // Line to put the word
      //inout [7:0]            cacheline [15:0];
      input [3:0] 	     bytepos;   // Byte index (within cache line)
      input [31:0] 	     source;    // Where to get the update (always D)
      output [24:0] 	     dedsec;     // New DEDSEC for this line

      // It would be nice if this could all be done in one line .. how?

      //cacheline[((bytepos << 3) + 7):(bytepos << 3)] = source[ 7: 0];
      //cacheline[bytepos] = source[ 7: 0];

      begin
	 case (bytepos)
	   4'b0000 : 
	      begin 
		 cacheline[  0+ 7:  0+ 0] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127: 0+ 8], source[7:0]                    }); 
	      end
	   4'b0001 : 
	      begin 
		 cacheline[  0+15:  0+ 8] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127: 0+16], source[7:0], cacheline[ 0+ 8:0]}); 
	      end
	   4'b0010 : 
	      begin 
		 cacheline[  0+23:  0+16] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127: 0+24], source[7:0], cacheline[ 0+16:0]}); 
	      end
	   4'b0011 : 
	      begin 
		 cacheline[  0+31:  0+24] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127: 0+32], source[7:0], cacheline[ 0+24:0]}); 
	      end
	   4'b0100 : 
	      begin 
		 cacheline[ 32+ 7: 32+ 0] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:32+ 8], source[7:0], cacheline[31+ 0:0]}); 
	      end
	   4'b0101 : 
	      begin 
		 cacheline[ 32+15: 32+ 8] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:32+16], source[7:0], cacheline[31+ 8:0]}); 
	      end
	   4'b0110 : 
	      begin 
		 cacheline[ 32+23: 32+16] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:32+24], source[7:0], cacheline[31+16:0]}); 
	      end
	   4'b0111 : 
	      begin 
		 cacheline[ 32+31: 32+24] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:32+32], source[7:0], cacheline[31+24:0]}); 
	      end
	   4'b1000 : 
	      begin 
		 cacheline[ 64+ 7: 64+ 0] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:64+ 8], source[7:0], cacheline[63+ 0:0]}); 
	      end
	   4'b1001 : 
	      begin 
		 cacheline[ 64+15: 64+ 8] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:64+16], source[7:0], cacheline[63+ 8:0]}); 
	      end
	   4'b1010 : 
	      begin 
		 cacheline[ 64+23: 64+16] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:64+24], source[7:0], cacheline[63+16:0]}); 
	      end
	   4'b1011 : 
	      begin 
		 cacheline[ 64+31: 64+24] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:64+32], source[7:0], cacheline[63+24:0]}); 
	      end
	   4'b1100 : 
	      begin 
		 cacheline[ 96+ 7: 96+ 0] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:96+ 8], source[7:0], cacheline[95+ 0:0]}); 
	      end
	   4'b1101 : 
	      begin 
		 cacheline[ 96+15: 96+ 8] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:96+16], source[7:0], cacheline[95+ 8:0]}); 
	      end
	   4'b1110 : 
	      begin 
		 cacheline[ 96+23: 96+16] = source[ 7: 0]; 
		 dedsec = dedsec_bits({cacheline[127:96+24], source[7:0], cacheline[95+16:0]}); 
	      end
	   4'b1111 : 
	      begin 
		 cacheline[ 96+31: 96+24] = source[ 7: 0]; 
		 dedsec = dedsec_bits({                      source[7:0], cacheline[95+24:0]}); 
	      end
	 endcase // case(address[3:2])
      end      
   endtask // input_byte
   
   // Use word index to output the appropriate word from the cacheline to D
   task output_word;
      input [127:0] 	     cacheline;
      input [1:0] 	     word;
      
      begin
	 case (word)
	   2'b00 : Dout = cacheline[31:0];
	   2'b01 : Dout = cacheline[63:32];
	   2'b10 : Dout = cacheline[95:64];
	   2'b11 : Dout = cacheline[127:96];
	 endcase // case(address[3:2])
      end      
   endtask
   
   // Use bytepos index to output the appropriate byte from the cacheline to D
   task output_byte;
      input [127:0] 	     cacheline;
      input [3:0] 	     bytepos;
      
      begin
	 Dout[31:8] = 24'h000000;
	 case (bytepos)
	   4'b0000 : Dout[7:0] = cacheline[  0+ 7:  0+ 0];	   
	   4'b0001 : Dout[7:0] = cacheline[  0+15:  0+ 8];	   
	   4'b0010 : Dout[7:0] = cacheline[  0+23:  0+16];	   
	   4'b0011 : Dout[7:0] = cacheline[  0+31:  0+24];	   
	   4'b0100 : Dout[7:0] = cacheline[ 32+ 7: 32+ 0];	   
	   4'b0101 : Dout[7:0] = cacheline[ 32+15: 32+ 8];	   
	   4'b0110 : Dout[7:0] = cacheline[ 32+23: 32+16];	   
	   4'b0111 : Dout[7:0] = cacheline[ 32+31: 32+24];	   
	   4'b1000 : Dout[7:0] = cacheline[ 64+ 7: 64+ 0];	   
	   4'b1001 : Dout[7:0] = cacheline[ 64+15: 64+ 8];	   
	   4'b1010 : Dout[7:0] = cacheline[ 64+23: 64+16];	   
	   4'b1011 : Dout[7:0] = cacheline[ 64+31: 64+24];	   
	   4'b1100 : Dout[7:0] = cacheline[ 96+ 7: 96+ 0];	   
	   4'b1101 : Dout[7:0] = cacheline[ 96+15: 96+ 8];	   
	   4'b1110 : Dout[7:0] = cacheline[ 96+23: 96+16];	   
	   4'b1111 : Dout[7:0] = cacheline[ 96+31: 96+24];	   
	 endcase // case(address[3:2])
      end      
   endtask
   
   // Displace to victim cache
   task move_main_to_victim;
      input [31:0] 	     address;   // NB. Only upper bits of address are used
                                        //  (for working out the cache line)
      begin
	 `ifdef TALK
	    $display("CPUside: Moving cache line b%b = d%d (address %h) to victim cache", 
		     main_cache_line(address), main_cache_line(address), address);
	 `endif
	 victim_cache[oldest_victim_line] <= @(posedge sysclk) 
	    main_cache[main_cache_line(address)];

	 // The victim tag is the main tag && offset
	 victim_cache_tag[oldest_victim_line] <= @(posedge sysclk) 
	    { main_cache_tag[main_cache_line(address)], main_cache_line(address) };
	 
	 victim_cache_dedsec[oldest_victim_line] <= @(posedge sysclk) 
	    main_cache_dedsec[main_cache_line(address)];
	 
	 victim_cache_valid[oldest_victim_line] <= @(posedge sysclk) 
	    main_cache_valid[main_cache_line(address)];

	 // Move our FIFO onwards
	 oldest_victim_line <= @(posedge sysclk) oldest_victim_line + 1;
      end      
   endtask
   
   // Swap lines in the two caches
   task swap_caches;
      input [31:0] 	     address;

      begin
	 victim_cache_tag[victim_cache_line(address)] <= @(posedge sysclk) 
	    { main_cache_tag[main_cache_line(address)], main_cache_line(address) };
	 
	 victim_cache[victim_cache_line(address)] <= @(posedge sysclk) 
	    main_cache[main_cache_line(address)];
	 
	 victim_cache_dedsec[victim_cache_line(address)] <= @(posedge sysclk) 
	    main_cache_dedsec[main_cache_line(address)];

	 
	 main_cache_tag[main_cache_line(address)] <= @(posedge sysclk) 
	    A[31:32-`MAIN_CACHE_TAG_BITS]; // *********** Check this line *************************
	 
	 main_cache[main_cache_line(address)] <= @(posedge sysclk) 
	    victim_cache[victim_cache_line(address)];
	 
	 main_cache_dedsec[main_cache_line(address)] <= @(posedge sysclk) 
	    victim_cache_dedsec[victim_cache_line(address)];
      end
   endtask
    
   // Returns the bits used for indexing the main cache from the given address
   function [`MAIN_CACHE_LINE_BITS-1:0] main_cache_line;
      input [31:0] 	     address;
      
      main_cache_line = address[`MAIN_CACHE_LINE_BIT_HIGH:`MAIN_CACHE_LINE_BIT_LOW];
   endfunction
   
   // Returns the bits used for indexing the victim cache from the given address
   function [27:0] victim_cache_line;
      input [31:0] 	     address;
      
      if (victim_cache_tag[0] == address[31:4])
	 victim_cache_line = 0;
      else if (victim_cache_tag[1] == address[31:4])
	 victim_cache_line = 1;
      else if (victim_cache_tag[2] == address[31:4])
	 victim_cache_line = 2;
      else //if (victim_cache_tag[3] == address[31:4])
	 victim_cache_line = 3;
   endfunction
   
   // Returns whether the given address has a match in the main cache
   function in_main_cache;
      input [31:0] 	     address;

      in_main_cache = ( main_cache_tag[main_cache_line(address)] == 
			  address[`MAIN_CACHE_TAG_BIT_HIGH:`MAIN_CACHE_TAG_BIT_LOW]
			& main_cache_valid[main_cache_line(address)]
			& main_dedsec_result );
   endfunction
   
   // Returns whether the given address has a match in the victim cache
   function in_victim_cache;
      input [31:0] 	     address;
      
      in_victim_cache = ( ( ( (  victim_cache_tag[0] == address[31:4]) & victim_cache_valid[0] )
			    | ( (victim_cache_tag[1] == address[31:4]) & victim_cache_valid[1] )
			    | ( (victim_cache_tag[2] == address[31:4]) & victim_cache_valid[2] )
			    | ( (victim_cache_tag[3] == address[31:4]) & victim_cache_valid[3] ) )
			  & victim_dedsec_result );
   endfunction // in_victim_cache
   
   // nWAIT assignment
   assign nWAIT = !cpu_busy;

   // D assignment
   assign D = Dout;
   
   // Initial setup
   initial      
      begin
	 present_cpu_state = `CPUSIDE_IDLE;
	 for (i = 0; i < `MAIN_CACHE_LINES; i = i+1)
	    main_cache_valid[i] = 0;
	 for (i = 0; i < `VICTIM_CACHE_LINES; i = i+1)
	    victim_cache_valid[i] = 0;
	 oldest_victim_line = 0;
      end 

   // Correct DEDSEC errors as they occur - main cache
   always
      begin
	 @(posedge sysclk) #1;
	 pass_dedsec(main_cache[main_cache_line(A)],
		     main_cache_dedsec[main_cache_line(A)],
		     main_dedsec_result );
      end // always begin
   
   // Correct DEDSEC errors as they occur - victim cache
   always
      begin
	 @(posedge sysclk) #1;
	 pass_dedsec(victim_cache[victim_cache_line(A)],
		     victim_cache_dedsec[victim_cache_line(A)],
		     victim_dedsec_result );
      end // always begin
   
   // CPU ASM
   always
      begin
	 @(posedge sysclk) enter_new_cpu_state(`CPUSIDE_IDLE);
	 cpu_busy = 0;
	 if (! nMREQ)
	    if (nRW)  // Write / Store
	       begin
		  while (st_busy)
		     begin
			cpu_busy = 1;
			@(posedge sysclk) enter_new_cpu_state(`CPUSIDE_WAIT);
		     end // while (st_busy)		  
		  if (in_main_cache(A))
		     if (MAS[1])
			input_word(main_cache[main_cache_line(A)], 
				   A[3:2], 
				   D, 
				   main_cache_dedsec[main_cache_line(A)]);
		     else
			input_byte(main_cache[main_cache_line(A)], 
				   A[3:0], 
				   D, 
				   main_cache_dedsec[main_cache_line(A)]);
		  else
		     if (in_victim_cache(A))
			begin
			   if (MAS[1])
			      input_word(victim_cache[victim_cache_line(A)], 
					 A[3:2], 
					 D, 
					 victim_cache_dedsec[victim_cache_line(A)]);
			   else
			      input_byte(victim_cache[victim_cache_line(A)],
					 A[3:0], 
					 D, 
					 victim_cache_dedsec[victim_cache_line(A)]);
			end // if (in_victim_cache(A))
		  if (MAS[1])
		     begin
			// Memoryside needs this in a register
			write_buffer_data <= @(posedge sysclk) D;
		     end
		  else
		     begin
			// Memoryside needs this in a register
			write_buffer_data <= @(posedge sysclk) {D[7:0], D[7:0], D[7:0], D[7:0]};
		     end // else: !if(MAS[1])
		  // Memoryside needs this in a register
		  write_buffer_is_byte <= @(posedge sysclk) ! MAS[1];
		  // Memoryside needs the address in this clock cycle
		  write_buffer_addr = A;
		  Store_Trigger = 1;
	       end
	    else
	       begin // (!nRW) = Read / Load
		  `ifdef TALK
		     $display("CPUside: Load start");
		  `endif
		     if (in_main_cache(A))
			begin
			`ifdef TALK
			   $display("CPUside: Main cache hit");
			`endif
			   if (MAS[1])
			      output_word(main_cache[main_cache_line(A)], A[3:2]);
			   else
			      output_byte(main_cache[main_cache_line(A)], A[3:0]);
			end // if (in_main_cache(A))
		  else
		     if (in_victim_cache(A))
			begin
			   `ifdef TALK
			      $display("CPUside: Victim cache hit (will swap cache w. main)");
			   `endif
			   if (MAS[1])
			      output_word(victim_cache[victim_cache_line(A)], A[3:2]);
			   else
			      output_byte(victim_cache[victim_cache_line(A)], A[3:0]);
			   swap_caches(A);
			end // if (in_victim_cache)
		     else
			begin
			   if (main_cache_valid[main_cache_line(A)])
			      // Only moving it if the line is valid is a small optimisation 
			      //  for the victim cache.
			      // Probably not beneficial for a normal CPU, but will make a 
			      //  difference in the small tests that will be run here!
			      // Will also make debugging easier.
			      // In other words, the above "if" should probably be removed,
			      //  but I'm leaving it in for now.
			      move_main_to_victim(A);

			   // Stall until Memoryside is ready
			   while (st_busy)
			      begin
				 cpu_busy = 1;
				 @(posedge sysclk) enter_new_cpu_state(`CPUSIDE_WAIT2);
			      end // while (st_busy)		  

			   // Memoryside now ready, so give it its next piece of work.
			   Load_Trigger = 1;
			   cpu_busy = 1;  // Ensure that CPU waits...

			   // Get data from Memoryside as it becomes ready
			   while (ld_busy | (present_cpu_state != `CPUSIDE_LOADING))
			      begin
				 @(posedge sysclk) enter_new_cpu_state(`CPUSIDE_LOADING);
				 cpu_busy = 1;
				 #2;
				 if (load_from_mem_req)
				    input_word(main_cache[main_cache_line(A)], 
					       load_from_mem_offset, 
					       load_from_mem_data, 
					       main_cache_dedsec[main_cache_line(A)]);
			      end // while (ld_busy)

			   @(posedge sysclk) enter_new_cpu_state(`CPUSIDE_LOADEND);
			   // Calculate DEDSEC bits for the newly loaded cache line
			   main_cache_dedsec[main_cache_line(A)] <= @(posedge sysclk) 
			      dedsec_bits(main_cache[main_cache_line(A)]);
			   
			   // Save the tag
			   main_cache_tag[main_cache_line(A)] <= @(posedge sysclk) 
			      A[`MAIN_CACHE_TAG_BIT_HIGH:`MAIN_CACHE_TAG_BIT_LOW];
			   
			   // Mark that this line is valid
			   main_cache_valid[main_cache_line(A)] <= @(posedge sysclk) 1;
	
$display ("%d: A=%h  D=%h", $time, A, main_cache[main_cache_line(A)]);		   
			   // Output to ARM Core
			   if (MAS[1])
			      output_word(main_cache[main_cache_line(A)], A[3:2]);
			   else
			      output_byte(main_cache[main_cache_line(A)], A[3:0]);
			   
			   `ifdef TALK
			      $display("CPUside: Load (from mem) result output (line=%h)", 
				       main_cache_line(A));
			   `endif
			end // else: !if(in_victim_cache)
	       end // else: !if(nRW)
      end // always begin

   task enter_new_cpu_state;
      input [`CPUSIDE_NUM_STATE_BITS-1:0] this_state;
      begin
	 #0 Dout = 32'hzzzzzzzz;
	 #1 present_cpu_state = this_state;
	 Load_Trigger = 0;
	 Store_Trigger = 0;
	 cpu_busy = 0;
	 // Any more to be added?
      end
   endtask // enter_new_cpu_state
      
endmodule
