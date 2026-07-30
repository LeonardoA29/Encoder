`timescale 1ns / 1ps
`define SIMULATION
module Display_TB;
   reg clk;
   reg reset;
   reg init;
   reg en_a;
	reg [11:0]  adr_a;
	reg [15:0]  dat_a;
	reg we_a;
   reg MISO;

   wire [15:0]  dat_a_out;//
   wire [7:0]data_rx;//

   wire spi_clk;
   wire MOSI;
   wire DC;
   wire displayCS;
   wire displayReset;

   wire done;
   integer idx; 

   Display Display0 (.clk(clk),.reset(reset),.en_a(en_a),.adr_a(adr_a),.dat_a(dat_a),
                     .we_a(we_a),.dat_a_out(dat_a_out),.data_rx(data_rx),.spi_clk(spi_clk),
                     .MOSI(MOSI),.MISO(MISO),.DC(DC),.displayCS(displayCS),
                     .displayReset(displayReset),.done(done),.init(init));

   parameter PERIOD = 20;
   initial begin  
          clk = 0;
          reset = 0;
          init = 0;
          en_a = 0;
          adr_a = 0;
          dat_a = 0;
          we_a = 0;
          MISO = 0;
   end
  
   initial clk <= 0;
   always #(PERIOD/2) clk <= ~clk;

   initial begin 
   
        reset = 1;
        init = 0;
        #(PERIOD);
        reset = 0;

        wait(done);

        init = 1;
        #(2*PERIOD);
        init = 0;

        wait(done) 

        init = 1;
   end
	 
   
   initial begin: TEST_CASE
     $dumpfile("Display_TB.vcd");
     $dumpvars(-1, Display_TB);
     #(PERIOD*10000000) $finish;
   end

endmodule

