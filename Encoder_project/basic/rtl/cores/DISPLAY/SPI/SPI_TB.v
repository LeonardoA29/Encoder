`timescale 1ns / 1ps
`define SIMULATION
module SPI_TB;
   reg  clk;
   reg  reset;
   reg  init;
   reg  [7:0] data_tx;
   reg  MISO;

   wire done;
   wire spi_clk;
   wire MOSI;
   wire [7:0] data_rx;

   SPI uut (
      .clk(clk), 
      .reset(reset), 
      .init(init), 
      .data_tx(data_tx),
      .MISO(MISO),
      .done(done),
      .spi_clk(spi_clk),
      .MOSI(MOSI),
      .data_rx(data_rx)
   );

   parameter PERIOD = 20;
   initial begin  
      clk = 0; reset = 0; init = 0; data_tx = 0; MISO = 0;
   end
  
   initial         clk <= 0;
   always #(PERIOD/2) clk <= ~clk;

   initial begin 
   
        reset = 1;
        init = 0;
        data_tx = 8'h00;
        #(PERIOD);
        reset = 0;

  

        data_tx = 8'hAA;
        init = 1;
        #(PERIOD);
        init = 0;
        wait(done == 1);
 


        #(PERIOD);
        data_tx = 8'hAA;
        init = 1;
        #(2*PERIOD);
        init = 0;
        wait(done == 1);
    

   end
	 

   initial begin: TEST_CASE
     $dumpfile("SPI_TB.vcd");
     $dumpvars(-1, SPI_TB);
     #(PERIOD*250) $finish;
   end

endmodule

