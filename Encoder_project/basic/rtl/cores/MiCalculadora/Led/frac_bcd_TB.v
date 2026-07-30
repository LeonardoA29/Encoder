`timescale 1ns / 1ps
`define SIMULATION
module frac_bcd_TB;
   reg  clk;
   reg  reset;
   reg  init;
   reg transmision_done;
   reg  [31:0] in_Bcd;

   wire [3:0] nibble;
   wire init_send;
   wire STB;
   wire done;

   frac_bcd frac_bcd_TB0(
      .clk(clk), 
      .reset(reset), 
      .init(init),
      .transmision_done(transmision_done), 
      .in_Bcd(in_Bcd), 
      .nibble(nibble),
      .init_send(init_send),
      .STB(STB), 
      .done(done)
   );

   parameter PERIOD = 20;
   initial begin  // Initialize Inputs
      clk = 0; reset = 0; init = 0; 
      in_Bcd = 32'h12345678;
      transmision_done = 0;
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
	 
   always @(*) begin
      if (frac_bcd_TB.frac_bcd_TB0.Control0.sd) begin
         transmision_done = 0;
         #(PERIOD*10)
         transmision_done = 1;
      end
   end
   initial begin: TEST_CASE
     $dumpfile("frac_bcd_TB.vcd");
     $dumpvars(-1, frac_bcd_TB);
     #(PERIOD*1000) $finish;
   end

endmodule

