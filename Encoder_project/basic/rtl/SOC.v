module SOC (
    input 	     clk,    // system clock 
    input 	     resetn, // reset button
    output wire  LEDS,   // system LEDs
    input 	     RXD,    // UART receive
    output 	     TXD,    // UART transmit
   //E-paper
    /*input busy,
    output displayReset,
    output DC,
    output displayCS,
    output spi_clk,
    output MOSI
   //  */
   //  //Siete segmentos 
    
   //  output       DIO,
   //  output       STB,
   //  output       clk_com,
   
   //  //Teclado
   
   //  input        C0,
   //  input        C1,
   //  input        C2,
   //  input        C3,

   //  output       R0,
   //  output       R1,
   //  output       R2,
   //  output       R3
    input x_in_11,
    input x_in_10,
    input x_in_9,
    input x_in_8,
    input x_in_7,
    input x_in_6,
    input x_in_5,
    input x_in_4,
    input x_in_3,
    input x_in_2,
    input x_in_1,
    input x_in_0,

    input y_in_11,
    input y_in_10,
    input y_in_9,
    input y_in_8,
    input y_in_7,
    input y_in_6,
    input y_in_5,
    input y_in_4,
    input y_in_3,
    input y_in_2,
    input y_in_1,
    input y_in_0,

    output clk_adc_A,
    output clk_adc_B
   
);
   wire [31:0] mem_addr;
   reg  [31:0] mem_rdata;
   wire mem_rstrb;
   wire [31:0] mem_wdata;
   wire [3:0]  mem_wmask;

   FemtoRV32 CPU(
      .clk(clk),
      .reset(resetn),		 
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask),
      .mem_rbusy(1'b0),
      .mem_wbusy(1'b0)
   );
   wire [31:0] RAM_rdata;
   wire  wr = |mem_wmask;
   wire  rd = mem_rstrb; 

   bram RAM(
      .clk(clk),
      .mem_addr(mem_addr),
      .mem_rdata(RAM_rdata),
      .mem_rstrb(cs[0] & rd),
      .mem_wdata(mem_wdata),
      .mem_wmask({4{cs[0]}}&mem_wmask)
   );

   wire [31:0] uart_dout;
   wire [31:0] Encoder_dout;
   // wire [31:0] bdc2bin_dout;
   // wire [31:0] mult_dout;
   // wire [31:0] div_dout;
   // wire [31:0] root_dout;
   // wire [31:0] bin2bcd_dout;
   // wire [31:0] Led_dout;


  peripheral_uart #(
     .clk_freq(26000000),    // 27000000 for gowin 33333333 for efinix
     .baud(115200)            // 57600 for gowin
   ) per_uart(
     .clk(clk),
     .rst(!resetn),
     .d_in(mem_wdata),
     .cs(cs[5]),
     .addr(mem_addr[4:0]),
     .rd(rd),
     .wr(wr),
     .d_out(uart_dout),
     .uart_tx(TXD),
     .uart_rx(RXD),
     .ledout(LEDS)
   ); 

   // peripheral_Teclado tcl1(
   //    .clk(clk),
   //    .reset(!resetn),
   //    .d_in(mem_wdata[0]), 
	// 	.cs(cs[7]), 
	// 	.addr(mem_addr[4:0]), 
	// 	.rd(rd), 
	// 	.wr(wr), 
	// 	.d_out(Teclado_dout),
   //    .C0(C0),
   //    .C1(C1),
   //    .C2(C2),
   //    .C3(C3),
   //    .R0(R0),
   //    .R1(R1),
   //    .R2(R2),
   //    .R3(R3)
   // );

   // peripheral_Rdd RDD1(
   //    .clk (clk), 
   //    .reset (!resetn), 
   //    .d_in (mem_wdata), 
   //    .cs (cs[6]), 
   //    .addr (mem_addr[4:0]), 
   //    .rd (rd), 
   //    .wr(wr), 
   //    .d_out (bdc2bin_dout) 
   // );
   
	// peripheral_mult mult1 (
	// 	.clk(clk), 
	// 	.reset(!resetn), 
	// 	.d_in(mem_wdata), 
	// 	.cs(cs[8]), 
	// 	.addr(mem_addr[4:0]), 
	// 	.rd(rd), 
	// 	.wr(wr), 
	// 	.d_out(mult_dout) 
	// );


   // peripheral_div div1 (
   //    .clk (clk), 
   //    .reset (!resetn), 
   //    .d_in (mem_wdata), 
   //    .cs (cs[4]), 
   //    .addr (mem_addr[4:0]), 
   //    .rd (rd), 
   //    .wr(wr), 
   //    .d_out (div_dout) );

   // peripheral_Root root1 (
   //    .clk (clk), 
   //    .reset (!resetn), 
   //    .d_in (mem_wdata), 
   //    .cs (cs[3]), 
   //    .addr (mem_addr[4:0]), 
   //    .rd (rd), 
   //    .wr(wr), 
   //    .d_out (root_dout) );

   // peripheral_dd DD1(
   //    .clk (clk), 
   //    .reset (!resetn), 
   //    .d_in (mem_wdata), 
   //    .cs (cs[2]), 
   //    .addr (mem_addr[4:0]), 
   //    .rd (rd), 
   //    .wr(wr), 
   //    .d_out (bin2bcd_dout) );
   


   // peripheral_Led Led1(
   //   .clk(clk), 
   //   .reset(!resetn), 
	//   .d_in(mem_wdata),
	//   .rd(rd),
	//   .wr(wr),
	//   .cs(cs[1]),
	//   .addr(mem_addr[6:0]),
	//   .DIO(DIO),
	//   .clk_com(clk_com),
	//   .STB(STB),
	//   .d_out(Led_dout));

/*
   peripheral_Display peripheral_Display0 (
      .clk(clk),
      .reset(!resetn),
      .d_in(mem_wdata),
      .MISO(1'b0),
      .busy(busy),
      .DC(DC),
      .displayCS(displayCS),
      .displayReset(displayReset),
      .spi_clk(spi_clk),
      .MOSI(MOSI),
      .rd(rd),
      .wr(wr),
      .cs(cs[1]),
      .addr(mem_addr[6:0]),
      .d_out(Led_dout)
      );
*/

/*
   peripheral_dpram dpram_p0( 
      .clk(clk),
      .reset(!resetn),
      .d_in(mem_wdata[15:0]),
      .cs(cs[6]),
      .addr(mem_addr[15:0]),
      .rd(rd),
      .wr(wr),
      .d_out(dpram_dout)
  );

  
*/

   peripheral_Encoder Enc0 (
   .clk(clk),
   .reset(!resetn),
   .d_in(mem_wdata[0]), 
	.cs(cs[7]), 
	.addr(mem_addr[4:0]), 
	.rd(rd), 
	.wr(wr), 
	.d_out(Encoder_dout),


    .x_in_11(x_in_11), .x_in_10(x_in_10), .x_in_9(x_in_9), .x_in_8(x_in_8),
    .x_in_7(x_in_7),   .x_in_6(x_in_6),   .x_in_5(x_in_5), .x_in_4(x_in_4),
    .x_in_3(x_in_3),   .x_in_2(x_in_2),   .x_in_1(x_in_1), .x_in_0(x_in_0),

    .y_in_11(y_in_11), .y_in_10(y_in_10), .y_in_9(y_in_9), .y_in_8(y_in_8),
    .y_in_7(y_in_7),   .y_in_6(y_in_6),   .y_in_5(y_in_5), .y_in_4(y_in_4),
    .y_in_3(y_in_3),   .y_in_2(y_in_2),   .y_in_1(y_in_1), .y_in_0(y_in_0),

    .clk_adc_A(clk_adc_A),
    .clk_adc_B(clk_adc_B)
);
  // ============== Chip_Select (Addres decoder) ======================== 
  // se hace con los 8 bits mas significativos de mem_addr
  // Se asigna el rango de la memoria de programa 0x00000000 - 0x003FFFFF
  // ====================================================================
  reg [8:0]cs;  // CHIP-SELECT
  always @*
  begin
      case (mem_addr[31:16])	// direcciones - chip_select
      //   16'h0043: cs= 9'b100000000; //mult_out
        16'h0041: cs= 9'b010000000;	//Encoder_out
      //   16'h0042: cs= 9'b001000000;	//bcd2bin_out
        16'h0040: cs= 9'b000100000;	//uart
      //   16'h0044: cs= 9'b000010000;	//div_out
      //   16'h0045: cs= 9'b000001000; //root_out
      //   16'h0046: cs= 9'b000000100; //bin2bcd_out
      //   16'h0047: cs= 9'b000000010; //Led_out
        16'h0000: cs= 9'b000000001; //RAM   
        default:  cs= 9'b000000001;       
      endcase
  end
  // ============== MUX ========================  // se encarga de lecturas del RV32
  always @*
  begin
      case (cs)
      //   9'b100000000: mem_rdata = mult_dout;
        9'b010000000: mem_rdata = Encoder_dout;
      //   9'b001000000: mem_rdata = bdc2bin_dout;
        9'b000100000: mem_rdata = uart_dout;
      //   9'b000010000: mem_rdata = div_dout;
      //   9'b000001000: mem_rdata = root_dout;
      //   9'b000000100: mem_rdata = bin2bcd_dout;
      //   9'b000000010: mem_rdata = Led_dout;
        9'b000000001: mem_rdata = RAM_rdata;
      endcase
  end
 // ============== MUX ========================  // 

`ifdef BENCH
   always @(posedge clk) begin
      if(cs[5] & wr ) begin
	 $write("%c", mem_wdata[7:0] );
	 $fflush(32'h8000_0001);
      end
   end
`endif


endmodule
