`timescale 1ns / 1ps
`define SIMULATION
module Com_TB;
   reg  clk;
   reg  reset;
   reg  init;
   reg  [7:0] data_cmd;
   wire DIO;
   wire clk_com;
   wire done;

   Com Com_TB(
      .clk(clk), 
      .reset(reset), 
      .init(init), 
      .data_cmd(data_cmd), 
      .DIO(DIO),
      .clk_com(clk_com), 
      .done(done)
   );

   parameter PERIOD = 20;
   initial begin  // Initialize Inputs
      clk = 0; reset = 0; init = 0; data_cmd = 8'b10101101;
   end
   // clk generation
   initial         clk <= 0;
   always #(PERIOD/2) clk <= ~clk;

   initial begin // Reset the system, Start the image capture process
        // Reset 
        @ (negedge clk);
	     reset = 1;
	     @ (negedge clk);
	     reset = 0;
        #(PERIOD*4)
        init = 0;
        @ (posedge clk);
        init = 1;
        #(PERIOD*2)
        init = 0;
        #(PERIOD*60);
   end
	 

   initial begin: TEST_CASE
     $dumpfile("Com_TB.vcd");
     $dumpvars(-1, Com_TB);
     #(PERIOD*1000) $finish;
   end

endmodule

