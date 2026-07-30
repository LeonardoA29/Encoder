`timescale 1ns / 1ps
`define SIMULATION
module Div_TB;
   reg  clk;
   reg  reset;
   reg  init;
   reg  [26:0] Dividendo;
   reg  [26:0] Divisor;
   wire [26:0] Cociente;
   wire [26:0] Residuo;
   wire done;

   Div Div_TB0(
      .clk(clk), 
      .reset(reset), 
      .init(init), 
      .Dividendo(Dividendo), 
      .Divisor(Divisor),
      .Cociente(Cociente),
      .Residuo(Residuo), 
      .done(done)
   );

   parameter PERIOD = 20;
   initial begin  // Initialize Inputs
      clk = 0; reset = 0; init = 0; Dividendo = 29165460;Divisor=9;
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
     $dumpfile("Div_TB.vcd");
     $dumpvars(-1, Div_TB);
     #(PERIOD*100) $finish;
   end

endmodule

