//Name:  Tam N. Nguyen, Thinh le, & Long Pham 
//Behave of Booth Multiplier.


`define MULT_NUM_STATE_BITS	2
`define MULT_IDLE		2'b00
`define MULT_SHIFT		2'b01
`define MULT_RESULT		2'b10
`timescale			1ns/100ps

module Booth_multiplier(Multiplier_enable, Multiplier_A, Multiplier_B, Multiplier_Result, 
			Multiplier_ready, sysclk);
	// input	Multiplier_enable, Multiplier_A, Multiplier_B, sysclk;
	input	Multiplier_enable, sysclk;
	input	[31:0] Multiplier_A, Multiplier_B;
	// output Multiplier_ready, Multiplier_Result;
	output Multiplier_ready;
	output [31:0] Multiplier_Result;
	wire	Multiplier_enable, sysclk;
	reg	prev;
	wire	[31:0] Multiplier_A, Multiplier_B;
	reg	Multiplier_ready;
	reg	[31:0] r1, Multiplier_Result;
	reg	[5:0] count;
	reg	[63:0] r2;
	reg [`MULT_NUM_STATE_BITS-1:0] present_state;
	
	always 
	   begin
		@(posedge sysclk) enter_new_state(`MULT_IDLE);
		  r1 <= @(posedge sysclk) Multiplier_A;
		  r2 <= @(posedge sysclk) {1'b0, Multiplier_B};
		  count <= @(posedge sysclk) 0;
		  prev <= @(posedge sysclk) 0;
		  Multiplier_ready = 1;
		  if (Multiplier_enable)
		     begin
			@(posedge sysclk) enter_new_state(`MULT_RESULT);	       	
		       	Multiplier_Result <= @(posedge sysclk) r2[31:0];			
			while (count <= 31)
			  begin
			    if (prev == 1)
			      begin
				if (r2[0] == 1)
				    prev <= @(posedge sysclk) 1;
				else  //r2[0] == 0  
				  begin
				    prev <= @(posedge sysclk) 0;
`ifdef BUG3
				    r2[63:32] <= @(posedge sysclk) r2[63:32] 
						  + Multiplier_A;
`else
				    r2[63:32] <= @(posedge sysclk) r2[63:32] + r1;
`endif
				  end
			      end
			    else //prev == 0
			      begin
				if (r2[0] == 1)
				  begin
				    prev <= @(posedge sysclk) 1;
`ifdef BUG3
				    r2[63:32] <= @(posedge sysclk) r2[63:32] 
							- Multiplier_A;
`else
				    r2[63:32] <= @(posedge sysclk) r2[63:32] - r1;
`endif
				  end
				else //r2[0] == 0
				    prev <= @(posedge sysclk) 0;
			      end
			    @(posedge sysclk) enter_new_state(`MULT_SHIFT);
			       r2 <= @(posedge sysclk) {r2[63], r2[63:1]};
			       count <= @(posedge sysclk) count + 1;
			    @(posedge sysclk) enter_new_state(`MULT_RESULT);
			    Multiplier_Result <= @(posedge sysclk) r2[31:0];			    
  		          end
			end
		 end
	task enter_new_state;
           input [`MULT_NUM_STATE_BITS-1:0] this_state;
           begin
             present_state = this_state;
             #1 Multiplier_ready = 0;
           end
        endtask
endmodule





			        
			      


