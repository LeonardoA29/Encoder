`timescale 1ns / 1ps
`define SIMULATION
module Led_TB;
   reg  clk;
   reg  reset;
   reg  init;
   reg  [31:0] in_Bcd;

   wire DIO;
   wire clk_com;
   wire STB;
   wire done;

   Led Led_TB(
      .clk(clk), 
      .reset(reset), 
      .init(init),
      .in_Bcd(in_Bcd), 
      .DIO(DIO),
      .clk_com(clk_com),
      .STB(STB), 
      .done(done)
   );

   parameter PERIOD = 20;
   initial begin  // Initialize Inputs
      clk = 0; reset = 0; init = 0; 
      in_Bcd = 32'h12345678;
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
        #(PERIOD);
   end
	 
   initial begin: TEST_CASE
     $dumpfile("Led_TB.vcd");
     $dumpvars(-1, Led_TB);
     #(PERIOD*30000) $finish;
   end

endmodule

