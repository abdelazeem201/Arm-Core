// Written by Amit Pandey


`define SHIFT_TYPE1 2'b00 
`define SHIFT_TYPE2 2'b01 
`define SHIFT_TYPE3 2'b10 
`define SHIFT_TYPE4 2'b11 


module shift_maker(ir2, Reg_value, SAM_Ctrl,BS_Shift_Amt,BS_Shift_Type);

input [31:0] ir2, Reg_value;
input [1:0] SAM_Ctrl;
output [4:0] BS_Shift_Amt;
output [1:0] BS_Shift_Type;

wire [31:0]  ir2, Reg_value;
wire [1:0] SAM_Ctrl;
reg [4:0] BS_Shift_Amt;
reg [1:0] BS_Shift_Type;

always @(ir2 or Reg_value or SAM_Ctrl)
begin

   // SHIFT_TYPE1 = offset specified by shifting immediate value 
   if( SAM_Ctrl == `SHIFT_TYPE1)
   begin
	BS_Shift_Amt = ir2[11:7];
	BS_Shift_Type = ir2[6:5];
   end
   else
      // SHIFT_TYPE2 == offset specified by shifting the value contained in
      // register (ir2[11:8])
      if( SAM_Ctrl == `SHIFT_TYPE2 )
      begin
        BS_Shift_Amt =  Reg_value[4:0];
        BS_Shift_Type = ir2[6:5];
      end 
   else
     // SHIFT_TYPE3 == special case where logical shift left by 2
      if( SAM_Ctrl == `SHIFT_TYPE3 )
      begin
        BS_Shift_Amt =  4'b0010;
        BS_Shift_Type = 2'b00;
      end 	
   else
      // SHIFT_TYPE4 == special case for data processing instructions where 
      // shift amount is calculated by rotating an immediate value
      if( SAM_Ctrl == `SHIFT_TYPE4 )
      begin
        BS_Shift_Amt =  { ir2[11:8], 1'b0 };
        BS_Shift_Type = 2'b11;
      end
end


endmodule 
