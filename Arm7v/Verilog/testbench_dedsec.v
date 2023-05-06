///// testbench_dedsec.v

`include "clock.v"

module top;
   integer x,y;
   reg [127:0] data;
   reg [25:0]  dedsec;
   reg 	       pass;

   c1 clock(sysclk);

   always 
      begin
	 @(posedge sysclk);
	 //		for (x=0;x<=14;x=x+1)
	 //		begin
	 @(posedge sysclk);
	 data = 128'heeeeffffffffffffffffffffffffffff;
	 dedsec = dedsec_bits(data);
	 pass_dedsec(data,dedsec,pass);	
	 dedsec = dedsec >> 1;
	 $display("data=%h dedsec=%h pass=%h",data,dedsec,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111000000000000000000000;
	 dedsec = dedsec_bits(data);
	 pass_dedsec(data,dedsec,pass);	
	 dedsec = dedsec >> 1;
	 $display("data=%h dedsec=%h pass=%h",data,dedsec,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111011101110111011100000;
	 dedsec = dedsec_bits(data);
	 pass_dedsec(data,dedsec,pass);	
	 dedsec = dedsec >> 1;
	 $display("data=%h dedsec=%h pass=%h",data,dedsec,pass);
	 @(posedge sysclk);
	 data = 128'h00001110111011101110111011101110;
	 dedsec = dedsec_bits(data);
	 pass_dedsec(data,dedsec,pass);	
	 dedsec = dedsec >> 1;
	 $display("data=%h dedsec=%h pass=%h",data,dedsec,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111000000000000000000000;
	 dedsec = dedsec_bits(data);
	 dedsec[21] = 1'b0; 
	 dedsec[8] = 1'b0;
	 $display("dedsec_pass test #1");
	 $display("data before : %h",data);
	 pass_dedsec(data,dedsec,pass);	
	 $display("data after : %h, pass: %h", data,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111000000000000000000000;
	 dedsec = dedsec_bits(data);
	 dedsec[8] = ~dedsec[8]; 
	 dedsec[7] = ~dedsec[7];
	 dedsec[6] = ~dedsec[6];
	 $display("dedsec_pass test #2");
	 $display("data before : %h",data);
	 pass_dedsec(data,dedsec,pass);	
	 $display("data after : %h, pass: %h", data,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111000000000000000000000;
	 dedsec = dedsec_bits(data);
	 dedsec[21] = 1'b0; 
	 dedsec[20] = ~dedsec[20]; 
	 dedsec[7] = 1'b0;
	 $display("dedsec_pass test #3");
	 $display("data before : %h",data);
	 pass_dedsec(data,dedsec,pass);	
	 $display("data after : %h, pass: %h", data,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111000000000000000000000;
	 dedsec = dedsec_bits(data);
	 dedsec[21] = 1'b0; 
	 dedsec[7] = 1'b0;
	 dedsec[0] = ~dedsec[0]; 
	 $display("dedsec_pass test #4");
	 $display("data before : %h",data);
	 pass_dedsec(data,dedsec,pass);	
	 $display("data after : %h, pass: %h", data,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111000000000000000000000;
	 dedsec = dedsec_bits(data);
	 dedsec[0] = ~dedsec[0];
	 $display("dedsec_pass test #5");
	 $display("data before : %h",data);
	 pass_dedsec(data,dedsec,pass);	
	 $display("data after : %h, pass: %h", data,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111000000000000000000000;
	 dedsec = dedsec_bits(data);
	 dedsec[21] = ~dedsec[21]; 
	 dedsec[0] = ~dedsec[0];
	 $display("dedsec_pass test #6");
	 $display("data before : %h",data);
	 pass_dedsec(data,dedsec,pass);	
	 $display("data after : %h, pass: %h", data,pass);
	 @(posedge sysclk);
	 data = 128'h11101110111000000000000000000000;
	 dedsec = dedsec_bits(data);
	 dedsec[8] = ~dedsec[21]; 
	 dedsec[0] = ~dedsec[0];
	 $display("dedsec_pass test #7");
	 $display("data before : %h",data);
	 pass_dedsec(data,dedsec,pass);	
	 $display("data after : %h, pass: %h", data,pass);
	 //		end
	 $stop;
         $finish;
      end

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

      end
   endfunction // dedsec_bits

   // Returns whether the given data passes the DEDSEC test
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
      end
   endtask
endmodule
