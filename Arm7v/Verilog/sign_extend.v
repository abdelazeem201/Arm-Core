//  Written by Amit Pandey

//  Modified 4/4/00 by Kevin Duda
//  Modified 4/6/00 by Amit Pandey 

// SIGN EXTENDER MODULE 
// SZE_CTRL = 1 : do sign extend ELSE  zero extend
// SZE_SEL : select between 3 different inputs

module sign_extend(IR2110, IR2_MUL70, IR270,IR2230,
	SZE_SEL, SZE_CTRL,BS_INPUT_SEL_EXT );

input [11:0] IR2110;
input [23:0] IR2230;
input [7:0] IR2_MUL70;
input [7:0] IR270;
input [1:0] SZE_SEL;
input SZE_CTRL;
output [31:0] BS_INPUT_SEL_EXT;

wire [11:0] IR2110;
wire [23:0] IR2230;
wire [7:0] IR2_MUL70;
wire [7:0] IR270;
wire [1:0] SZE_SEL;
wire SZE_CTRL;
reg [31:0] BS_INPUT_SEL_EXT;


always @(IR2110 or IR2_MUL70 or IR270 or IR2230 or
	 SZE_SEL or SZE_CTRL )
begin
	
   if( SZE_SEL == `SZE_SEL_IR2110 )
      begin
	 if(SZE_CTRL == 1)
	    begin
	       BS_INPUT_SEL_EXT = { IR2110[11],IR2110[11],IR2110[11],IR2110[11],IR2110[11],
				    IR2110[11],IR2110[11],IR2110[11],IR2110[11],IR2110[11],
				    IR2110[11],IR2110[11],IR2110[11],IR2110[11],IR2110[11],
				    IR2110[11],IR2110[11],IR2110[11],IR2110[11],IR2110[11],
				    IR2110[11],IR2110[11:0] };
	    end
	 else
	    begin
	       BS_INPUT_SEL_EXT = { 20'b00000000000000000000, IR2110[11:0] };
	    end
      end
   else
      if( SZE_SEL == `SZE_SEL_IR2_MUL70 )
	 begin
	    if(SZE_CTRL == 1)
	       begin
		  BS_INPUT_SEL_EXT = { IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],
				       IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],
				       IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],
				       IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],
				       IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],
				       IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],IR2_MUL70[7],
				       IR2_MUL70[7:0] };
	       end
	    else
	       begin
		  BS_INPUT_SEL_EXT = { 24'b000000000000000000000000, IR2_MUL70[7:0] };
	       end
	 end // if ( SZE_SEL == `SZE_SEL_IR2_MUL70 )   
      else
	 if( SZE_SEL == `SZE_SEL_IR2_70 )
	    begin
	       if(SZE_CTRL == 1)
		  begin
		     BS_INPUT_SEL_EXT = { IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],
					  IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],
					  IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],IR270[7],
					  IR270[7],IR270[7],IR270[7],IR270[7:0] };
		  end
	       else
		  begin
		     BS_INPUT_SEL_EXT = { 24'b000000000000000000000000, IR270[7:0] };
		  end
	    end // if ( SZE_SEL == `SZE_SEL_IR2_70 )   
	 else
	    if( SZE_SEL == `SZE_SEL_IR2_230 )
	       begin
		  if(SZE_CTRL == 1)
		     begin
			BS_INPUT_SEL_EXT = { IR2230[23],IR2230[23],IR2230[23],IR2230[23],IR2230[23],
					     IR2230[23],IR2230[23],IR2230[23],IR2230[23:0] };
		     end // if (SZE_CTRL == 1)
		  else
		     begin			
			BS_INPUT_SEL_EXT = { 8'b00000000, IR2230[23:0] };
		     end // else: !if(SZE_CTRL == 1)		  
	       end // if ( SZE_SEL == `SZE_SEL_IR2230 )   
end					   
   
endmodule


//////////////////////////////////////////////////////////////////////////////////////

// TEST CASE
/*
module top;
   
   reg [11:0] IR2110a;
   reg [7:0]  IR2_MUL70a;
   reg [7:0]  IR270a;
   reg [1:0] SZE_SELa;
   reg 	     SZE_CTRLa;
   wire [31:0] BS_INPUT_SEL_EXTa;
   
   sign_extend ext(IR2110a, IR2_MUL70a, IR270a,SZE_SELa, SZE_CTRLa,BS_INPUT_SEL_EXTa );
   initial
      begin
	 $stop;	 
	 #10; 
	 IR2110a = 12'b000000000001;
	 IR2_MUL70a = 8'b00000010;
	 IR270a = 8'b00000011;
	 SZE_CTRLa = 1;
	 SZE_SELa = `SZE_SEL_IR2110;   
	 #10;
	 SZE_SELa = `SZE_SEL_IR2_70;
	 #10;
	 SZE_SELa = `SZE_SEL_IR2_MUL70;
	 #10;
	 SZE_CTRLa = 0;
	 SZE_SELa = `SZE_SEL_IR2110;   
	 #10;
	 SZE_SELa = `SZE_SEL_IR2_70;
	 #10;
	 SZE_SELa = `SZE_SEL_IR2_MUL70;
	 #10;

	 
	 IR2110a = 12'b100000000001;
	 IR2_MUL70a = 8'b10000010;
	 IR270a = 8'b10000011;
	 SZE_SELa = `SZE_SEL_IR2110;   
	 #10;
	 SZE_SELa = `SZE_SEL_IR2_70;
	 #10;
	 SZE_SELa = `SZE_SEL_IR2_MUL70;
	 #10;
	 SZE_CTRLa = 1;
	 SZE_SELa = `SZE_SEL_IR2110;   
	 #10;
	 SZE_SELa = `SZE_SEL_IR2_70;
	 #10;
	 SZE_SELa = `SZE_SEL_IR2_MUL70;
	 #10;
	 
	
	 #10
	    $display("ir2_MUL70=%h BS_INPUT_SEL_EXTa=%h",IR2_MUL70a,BS_INPUT_SEL_EXTa );
	 #10
	    $finish;
      end
endmodule

*/
