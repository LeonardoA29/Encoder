`timescale 1ns / 1ps
`define SIMULATION
module Double_Dabble_TB;
   reg  clk;
   reg  reset;
   reg  init;
   reg  [26:0] in_Bin;
   wire [31:0] out_Bcd;
   wire done;

   Double_Dabble DD_TB(
      .clk(clk), 
      .reset(reset), 
      .init(init), 
      .in_Bin(in_Bin), 
      .out_Bcd(out_Bcd), 
      .done(done)
   );

   parameter PERIOD = 20;
   initial begin  // Initialize Inputs
      clk = 0; reset = 0; init = 0; in_Bin = 12345678;
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
     $dumpfile("Double_Dabble_TB.vcd");
     $dumpvars(-1, Double_Dabble_TB);
     #(PERIOD*100) $finish;
   end

endmodule

