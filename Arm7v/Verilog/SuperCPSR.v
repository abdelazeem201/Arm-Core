// To specify a specific mode, set SC_CTRL_Type = 10000 and SC_CTRL_Source to the mode you want
// See the defines file to see the available mode definitions, are in the form SC_CTRL_SELECT_SOURCE_XXX_MODE
// To update a specific field, set SC_CTRL_Type = 0NZVC where N, Z,V,C are set if you want to update that bit
// For any questions, contact Isaac Sanchez at iisanche@uiuc.edu

`include "defines.v"

module Super_CPSR( SC_CTRL_Source, SC_CTRL_Type, SC_current_CPSR, SC_alu_result, SC_alu_flags, SC_shift_flags, SC_PSR_out);
	
   input [31:0] SC_current_CPSR;
   input [31:0] SC_alu_result;
   input [3:0]  SC_alu_flags;
   input        SC_shift_flags;
   input [3:0]  SC_CTRL_Source;
   input [4:0]  SC_CTRL_Type;	
	
   output [10:0] SC_PSR_out;

   wire [31:0]  SC_current_CPSR;
   wire [31:0]  SC_alu_result;
   wire [3:0]   SC_alu_flags;
   wire 	     SC_shift_flags;
   wire [3:0] 	SC_CTRL_Source;
   wire [4:0] 	SC_CTRL_Type;
   reg [10:0] 	SC_PSR_out, temp;

   always @(SC_CTRL_Source or SC_CTRL_Type or SC_current_CPSR or SC_alu_result or SC_shift_flags or SC_alu_flags or SC_PSR_out)
     begin
       if (SC_CTRL_Type[4] == 0)
         begin
           temp[10] = SC_current_CPSR[31];
           temp[9] = SC_current_CPSR[30];
           temp[8] = SC_current_CPSR[29];
           temp[7] = SC_current_CPSR[28];
           temp[6] = SC_current_CPSR[7];
           temp[5] = SC_current_CPSR[6];
           temp[4] = SC_current_CPSR[4];
           temp[3] = SC_current_CPSR[3];
           temp[2] = SC_current_CPSR[2];
           temp[1] = SC_current_CPSR[1];
           temp[0] = SC_current_CPSR[0];					
           if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_ALU_FLAGS)
             begin					
               if (SC_CTRL_Type[3] == 1)
                  temp[10] = SC_alu_flags[3];
               if(SC_CTRL_Type[2] == 1)
                  temp[9] = SC_alu_flags[2];
               if(SC_CTRL_Type[1] == 1)
                  temp[8] = SC_alu_flags[1];
               if(SC_CTRL_Type[0] == 1)
                  temp[7] = SC_alu_flags[0];
             end
           else if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_SFT_FLAGS)
             begin
               if (SC_CTRL_Type[3] == 1)
                 temp[10] = SC_alu_flags[3];
               if (SC_CTRL_Type[2] == 1)
                 temp[9] = SC_alu_flags[2];
               if (SC_CTRL_Type[1] == 1)
                 temp[7] = SC_alu_flags[1];
               if (SC_CTRL_Type[0] == 1)
                 temp[8] = SC_shift_flags;
             end
         end
       else  // (SC_CTRL_Type[4] != 0)
         begin
           if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_USR_MODE)
              temp = `SC_USR_MODE;
           else if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_SVC_MODE)
              temp = `SC_SVC_MODE;
           else if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_ALU)
             begin
               temp[10] = SC_alu_result[31];
               temp[9] = SC_alu_result[30];
               temp[8] = SC_alu_result[29];
               temp[7] = SC_alu_result[28];
               temp[6] = SC_alu_result[7];
               temp[5] = SC_alu_result[6];
               temp[4] = SC_alu_result[4];
               temp[3] = SC_alu_result[3];
               temp[2] = SC_alu_result[2];
               temp[1] = SC_alu_result[1];
               temp[0] = SC_alu_result[0];
             end
           else if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_ABT_MODE)
              temp = `SC_ABT_MODE;
           else if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_FIQ_MODE)
              temp = `SC_FIQ_MODE;
           else if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_IRQ_MODE)
              temp = `SC_IRQ_MODE;
           else if (SC_CTRL_Source == `SC_CTRL_SELECT_SOURCE_UND_MODE)
              temp = `SC_UND_MODE;				
         end
       SC_PSR_out = temp;
     end 
endmodule

