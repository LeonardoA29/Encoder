`timescale 1ns / 1ps
`define SIMULATION
module addrCtrl_TB;
   reg  clk;
   reg  reset;
   reg  init;
   reg  DC_input;
   reg  spiDone;

   wire [11:0] adrB;
   wire DC;
   wire displayCS;
   wire SPI_init;
   wire done;

   addrCtrl addrCtrl0(
      .reset(reset),
      .clk(clk),
      .init(init),
      .spiDone(spiDone),
      .DC_input(DC_input),
      .adrB(adrB),
      .DC(DC),
      .displayCS(displayCS),
      .SPI_init(SPI_init),
      .done(done)
      );


   parameter PERIOD = 20;
   initial begin  
      reset = 0; init = 0; DC_input = 0; spiDone = 0;
   end
  
   initial clk <= 0;
   always #(PERIOD/2) clk <= ~clk;

   initial begin 
   
        reset = 1;
        init = 0;
        DC_input = 0;
        spiDone = 0;
        #(PERIOD);
        reset = 0;
        while (!done) begin
         DC_input = adrB % 2 == 1? 1:0;
         #(2*PERIOD);
         spiDone = 1;
         #(PERIOD);
         spiDone = 0;
        end

        init = 1;
        #(2*PERIOD);
        init = 0;

        while (!done)begin
         DC_input = adrB % 2 == 1? 1:0;
         #(2*PERIOD);
         spiDone = 1;
         #(PERIOD);
         spiDone = 0;
        end

        wait(done);
        init = 1;
   

   end
	 
   
   initial begin: TEST_CASE
     $dumpfile("addrCtrl_TB.vcd");
     $dumpvars(-1, addrCtrl_TB);
     #(PERIOD*100000) $finish;
   end

endmodule

