`timescale 1ns / 1ps

`define SIMULATION
module led_panel_128_TB;
   reg  clk;
   reg  init;
   reg  rst;
   reg [47:0] w_data0;
   reg [47:0] w_data1;
   reg [13:0] w_address;

   wire  [2:0] RGB0;
   wire  [2:0] RGB1;
   wire  [4:0] ROW;
   wire  OE;
   wire  latch;
   wire Led_clk;
   wire done;


   led_panel_128 uut (
        .clk(clk),
        .init(init),
        .rst(rst),
        .w_data0(w_data0),
        .w_data1(w_data1),
        .w_address(w_address),
        .RGB0(RGB0),
        .RGB1(RGB1),
        .ROW(ROW),
        .OE(OE),
        .latch(latch),
        .Led_clk(Led_clk),
        .done(done)
    );



   parameter PERIOD = 20;

   // Initialize Inputs
   initial begin  
      clk = 0; rst = 0; init = 0; w_data0 = 48'b0;
      w_data1 = 48'b0; w_address = 11'b0;
   end

   // clk generation
   initial         clk <= 0;
   always #(PERIOD/2) clk <= ~clk;

   initial begin 
     // Reset 
     @ (posedge clk);
      rst = 1;
      @ (posedge clk);
      rst = 0;
     #(PERIOD*4)
      init = 1;
     #(PERIOD*30000)
      init = 0;
   end

   integer idx;
   initial begin: TEST_CASE
     $dumpfile("led_panel_128_TB.vcd");
     $dumpvars(-1, led_panel_128_TB);
    //for(idx = 0; idx < 100; idx = idx +1)  $dumpvars(0, led_panel_128_TB.uut.mem0.MEM[idx]);
     #(PERIOD*1000000) $finish;
   end





endmodule
