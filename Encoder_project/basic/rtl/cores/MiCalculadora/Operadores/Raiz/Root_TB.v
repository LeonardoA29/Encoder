`timescale 1ns / 1ps
`define SIMULATION
module Root_TB;
   reg  clk;
   reg  reset;
   reg  init;
   reg  [27:0] Radicando;
   wire [27:0] Residuo;
   wire [13:0] Raiz;
   wire done;

   Root Rt_TB(
      .clk(clk), 
      .reset(reset), 
      .init(init), 
      .Radicando(Radicando), 
      .Residuo(Residuo), 
      .Raiz(Raiz), 
      .done(done)
   );

   parameter PERIOD = 20;
   initial begin  // Initialize Inputs
      clk = 0; reset = 0; init = 0; Radicando = 99999999;
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
     $dumpfile("Root_TB.vcd");
     $dumpvars(-1, Root_TB);
     #(PERIOD*100) $finish;
   end

endmodule

