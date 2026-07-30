`timescale 1ns / 1ps

`define SIMULATION
module peripheral_Display_TB;

   reg clk;
   reg reset;
   reg [15:0]d_in;
   reg MISO;
   reg rd;
   reg wr;
   reg cs;
   reg [6:0]addr;
   
   wire DC;
   wire displayCS;
   wire displayReset;
   wire spi_clk;
   wire MOSI;
   wire [15:0]d_out;
 
   peripheral_Display peripheral_Display0 (
      .clk(clk),
      .reset(reset),
      .d_in(d_in),
      .MISO(MISO),
      .DC(DC),
      .displayCS(displayCS),
      .displayReset(displayReset),
      .spi_clk(spi_clk),
      .MOSI(MOSI),
      .rd(rd),
      .wr(wr),
      .cs(cs),
      .addr(addr),
      .d_out(d_out)
      );

   parameter PERIOD = 20;
   // Initialize Inputs
   initial begin  
      clk = 0; reset = 0; d_in = 0; addr = 7'b0; cs=0; rd=0; wr=0; MISO = 0;
   end
   // clk generation
   initial         clk <= 0;
   always #(PERIOD/2) clk <= ~clk;

   initial begin 
     // Reset 
	  reset = 1;
     #(PERIOD * 4);
	  reset = 0;
     #(PERIOD);
   end
	 

   initial begin: TEST_CASE
     $dumpfile("perip_Display_TB.vcd");
     $dumpvars(-1, peripheral_Display_TB);
     #(PERIOD*500000) $finish;
   end

endmodule

