module led_panel_128(
    input   clk,
    input   init,
    input   rst,
    input   [47:0]w_data0,
    input   [47:0]w_data1,
    input   [13:0]w_address,
    input   en_a,
    output  [2:0] RGB0,
    output  [2:0] RGB1,
    output  [4:0] ROW,
    output  OE,
    output  latch, 
    output  Led_clk,
    output  done  
);



parameter slowing_factor = 5;
parameter number_of_bits = 128*64*48;
parameter ROW_width = 5;
parameter mem_size = 4096;
parameter mem_width = 12;
parameter mem_file_name_R0 = "images/imageR0.hex";
parameter mem_file_name_R1 = "images/imageR1.hex";
parameter mem_file_name_G0 = "images/imageG0.hex";
parameter mem_file_name_G1 = "images/imageG1.hex";
parameter mem_file_name_B0 = "images/imageB0.hex";
parameter mem_file_name_B1 = "images/imageB1.hex";

assign W_Led_clk = Led_clk;
assign w_done = done;

wire w_done;
wire w_clk_edge_signal;
wire w_configdone;
wire w_cnfig_sd;
wire w_latch_done;
wire w_frame_done; 
wire w_send_done;
wire w_ltch;
wire w_pract;
wire w_wt;
wire w_en_op;
wire w_vsy;
wire w_ld_cnfg;
wire w_sd_config;
wire w_dt_ld;
wire [11:0] w_Address_r;
wire [2:0] w_cnfg_reg;
wire [15:0] w_dataR0;
wire [15:0] w_dataR1;
wire [15:0] w_dataG0;
wire [15:0] w_dataG1;
wire [15:0] w_dataB0;
wire [15:0] w_dataB1;

clk_div #(.slowing_factor(slowing_factor))
 clk_div0(.clk(clk),.rst(rst),.Led_clk(Led_clk),.flag_for_edge(w_clk_edge_signal));

ctrl_lp128 ctrl_lp0(.clk(clk),.Led_clk(W_Led_clk),.flag_for_edge(w_clk_edge_signal),
  .init(1'b1),.rst(rst),.config_done(w_configdone),.config_sended(w_cnfig_sd),
  .latch_done(w_latch_done),.frame_done(w_frame_done),
  .ltch(w_ltch),.pract(w_pract),.en_op(w_en_op),.vsy(w_vsy),.ld_cnfg(w_ld_cnfg),
  .sd_cnfg(w_sd_config),.done(done),.dt_ld(w_dt_ld),.wt(w_wt));

latch_ctrl latch_ctrl0(.clk(clk),.flag_for_edge(w_clk_edge_signal),.Led_clk(W_Led_clk),
  .rst(rst),.ltch(w_ltch),.pract(w_pract),.en_op(w_en_op),.vsy(w_vsy),.ld_cnfg(w_ld_cnfg),
  .sd_cnfg(w_sd_config),.dt_ld(w_dt_ld),.wt(w_wt),.done(w_done),.latch(latch),.latch_done(w_latch_done),
  .config_sended(w_cnfig_sd),.config_register(w_cnfg_reg),.config_done(w_configdone));

data_ctrl #(.number_of_bits(number_of_bits)) data_ctrl0(.clk(clk),.flag_for_edge(w_clk_edge_signal),.rst(rst),
  .config_register(w_cnfg_reg),.dt_ld(w_dt_ld),.ld_cnfg(w_ld_cnfg),.sd_cnfg(w_sd_config),
  .done(w_done),.data_R0(w_dataR0),.data_G0(w_dataG0),.data_B0(w_dataB0),.data_R1(w_dataR1),
  .data_G1(w_dataG1),.data_B1(w_dataB1),.frame_done(w_frame_done),.RGB0(RGB0),.RGB1(RGB1));

mem_dir mem_dir0(.clk(clk),.flag_for_edge(w_clk_edge_signal),.Led_clk(W_Led_clk),.rst(rst),
   .dt_ld(w_dt_ld),.frame_done(w_frame_done),.done(w_done),.Address(w_Address_r));

Row_dir #(.width(ROW_width)) Row_dir0(.clk(clk),.rst(rst),.vsy(w_vsy),.latch_done(w_latch_done),
   .flag_for_edge(w_clk_edge_signal),.Led_clk(W_Led_clk),.outc(ROW),.OE(OE));

memory #(.size(mem_size),.width(mem_width),.mem_file_name(mem_file_name_R0))
   memoryR0(.clk(clk),.address(w_Address_r),.rd(1'b1),.rdata(w_dataR0),.we_a(~w_address[13]),
   .w_address(w_address[12:0]),.w_data(w_data0[47:32]),.en_a(en_a));

memory #(.size(mem_size),.width(mem_width),.mem_file_name(mem_file_name_R1))
   memoryR1(.clk(clk),.address(w_Address_r),.rd(1'b1),.rdata(w_dataR1),.we_a(w_address[13]),
   .w_address(w_address[12:0]),.w_data(w_data1[47:32]),.en_a(en_a));

memory #(.size(mem_size),.width(mem_width),.mem_file_name(mem_file_name_G0))
   memoryG0(.clk(clk),.address(w_Address_r),.rd(1'b1),.rdata(w_dataG0),.we_a(~w_address[13]),
   .w_address(w_address[12:0]),.w_data(w_data0[31:16]),.en_a(en_a));

memory #(.size(mem_size),.width(mem_width),.mem_file_name(mem_file_name_G1))
   memoryG1(.clk(clk),.address(w_Address_r),.rd(1'b1),.rdata(w_dataG1),.we_a(w_address[13]),
   .w_address(w_address[12:0]),.w_data(w_data1[31:16]),.en_a(en_a));

memory #(.size(mem_size),.width(mem_width),.mem_file_name(mem_file_name_B0))
   memoryB0(.clk(clk),.address(w_Address_r),.rd(1'b1),.rdata(w_dataB0),.we_a(~w_address[13]),
   .w_address(w_address[12:0]),.w_data(w_data0[15:0]),.en_a(en_a));

memory #(.size(mem_size),.width(mem_width),.mem_file_name(mem_file_name_B1))
   memoryB1(.clk(clk),.address(w_Address_r),.rd(1'b1),.rdata(w_dataB1),.we_a(w_address[13]),
   .w_address(w_address[12:0]),.w_data(w_data1[15:0]),.en_a(en_a));

endmodule
