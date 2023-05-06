// Barrel Shifter with 32 bit input & 32 bit output 
`timescale 1ns/100ps

module Barrel_Shifter(BS_Enable,BS_Input_Bus,BS_Shift_Type,BS_Shift_Amt,BS_Cin,BS_Shift_Output,BS_Cout);

input[31:0] BS_Input_Bus;
input[4:0] BS_Shift_Amt;
input[1:0] BS_Shift_Type;
input BS_Enable;
input BS_Cin;
output BS_Cout;
output[31:0] BS_Shift_Output;

wire[31:0] BS_Input_Bus;
wire[4:0] BS_Shift_Amt;
wire[1:0] BS_Shift_Type;
wire BS_Enable;
wire BS_Cin;
reg BS_Cout;
reg[31:0] BS_Shift_Output;
integer i;

 always @(BS_Enable or BS_Input_Bus or BS_Shift_Type or BS_Shift_Amt or BS_Cin)  
   begin
   if (BS_Enable==1'b0)
     begin        
       BS_Shift_Output[31:0]=BS_Input_Bus[31:0];
       BS_Cout=BS_Cin;
     end
   else
   if (BS_Enable==1'b1)                            //If shift needed
     begin
     case(BS_Shift_Type[1:0])                      //Case for Shift type 
      2'b00:begin                                  //LSL - Logical Shift Left 
        if (BS_Shift_Amt[4:0]==5'b00000)             
         begin                                     //LSL#0 -special case   
           BS_Shift_Output[31:0]=BS_Input_Bus[31:0];
           BS_Cout=BS_Cin;
         end 
        else					   //Shift of nonzero bits
          begin
           for (i=0;i<=31;i=i + 1)                  //for each bit of output check the condition and assign a value  
            begin
             if (BS_Shift_Amt[4:0] > i)            //Condition 
                 BS_Shift_Output[i]=1'b0;
             else 
                 BS_Shift_Output[i]=BS_Input_Bus[i-BS_Shift_Amt[4:0]];     
            end
           BS_Cout=BS_Input_Bus[31-BS_Shift_Amt[4:0]+1];
          end
        end

      2'b01:begin                                 //LSR - Logic Shift Right
        if (BS_Shift_Amt[4:0]==5'b00000)          //LSR#0 -used to encode LSR#32 
         begin
           BS_Shift_Output[31:0]=32'b00000000000000000000000000000000;
           BS_Cout=BS_Input_Bus[31];
         end 
        else                                      //Shift of nonzero bits  
         begin
           for (i=0;i<=31;i=i+1)                   //for each bit of output check the condition and assign a value  
            begin
             if (i > 31-BS_Shift_Amt[4:0])        //Condition 
                 BS_Shift_Output[i]=1'b0;
             else
                BS_Shift_Output[i]=BS_Input_Bus[i+BS_Shift_Amt[4:0]];   
            end
           BS_Cout=BS_Input_Bus[BS_Shift_Amt[4:0]-1]; 
          end
        end
      2'b10:begin                                //ASR - Arithmetic Shift Right
        if (BS_Shift_Amt[4:0]==5'b00000)        //ASR#0 -used to encode ASR#32 
         begin
           for (i=0;i<=31;i=i+1)
           BS_Shift_Output[i]=BS_Input_Bus[31];
           BS_Cout=BS_Input_Bus[31];
         end
        else  					 //Shift of nonzero bits
          begin
           for (i=0;i<=31;i=i+1)                  //for each bit of output check the condition and assign a value    
            begin
             if (i > 31-BS_Shift_Amt[4:0])       //Condition 
                 BS_Shift_Output[i]=BS_Input_Bus[31];
             else
                 BS_Shift_Output[i]=BS_Input_Bus[i+BS_Shift_Amt[4:0]];
           end
           BS_Cout=BS_Input_Bus[BS_Shift_Amt[4:0]-1];     
          end
        end
      2'b11:begin                                //ROR - Rotate Right 
        if (BS_Shift_Amt[4:0]==5'b00000)         //Shift of Zero(RRX) - Special case
         begin                                  
           for (i=0;i<=31;i=i+1)
            if (i < 31)
            BS_Shift_Output[i]=BS_Input_Bus[i+1];
            else if (i==31)
            BS_Shift_Output[i]=BS_Cin;
            BS_Cout=BS_Input_Bus[0];
         end
        else                                     //Shift of nonzero bits    
         begin
           for (i=0;i<=31;i=i+1)                  //for each bit of output check the condition and assign a value 
            begin
             if (i > 31-BS_Shift_Amt[4:0])       //Condition 
                 BS_Shift_Output[i]=BS_Input_Bus[i-31+BS_Shift_Amt[4:0]-1];
             else
                 BS_Shift_Output[i]=BS_Input_Bus[i+BS_Shift_Amt[4:0]]; 
            end
           BS_Cout = BS_Input_Bus[BS_Shift_Amt[4:0]-1];    
          end
        end
      default:begin
              end  
     endcase                                    // case(BS_Shift_Type[1:0])
	
     end                                        // if (BS_Enable==1'b1)

   end                                          //always 
endmodule                                       //module
  
