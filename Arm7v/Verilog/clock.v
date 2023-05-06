`define TIME_LIMIT 110000

module c1(clk);
   output clk;
   reg clk;

   always 
      begin
         if ($time == 0) 
            begin 
               clk = 0; 
            end
         #50 clk = ~clk;
      end

   always @(posedge clk)
      if ($time > `TIME_LIMIT) 
         #70 $stop;
endmodule 
