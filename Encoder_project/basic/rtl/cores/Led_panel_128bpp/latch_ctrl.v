module latch_ctrl(
  input clk,
  input flag_for_edge,
  input Led_clk,
  input rst,
  input ltch,
  input pract,
  input en_op,
  input vsy,
  input ld_cnfg,
  input sd_cnfg,
  input dt_ld,
  input wt,
  input done,
  output reg latch,
  output reg latch_done,
  output reg config_sended,
  output wire [2:0]config_register,
  output config_done
);
assign config_register = config_num/2 - 1;
assign config_done = config_num > 12? 1 : 0;


reg [3:0] config_num;
reg [7:0] cnt_wh_latch;
reg [7:0] bit_cnt;

always @(negedge clk or posedge rst) begin
  if (rst) begin
    config_num <= 4;
    cnt_wh_latch <= 255;
    bit_cnt <= 0; 
    latch_done <= 0;
  end
  else if (done)begin
    cnt_wh_latch <= 255;
    bit_cnt <= 0;
    latch_done <= 0;
  end
  else begin
    if (ld_cnfg) begin 
      if (config_num > 10) cnt_wh_latch <= 128 - 2 + 1;
      else cnt_wh_latch <= 128 - config_num + 1; // este es 128 en vez de 16 porque se tiene que enviar 8 veces
      bit_cnt <= 1; 
      latch_done <= 0;
      config_sended = 0;

    end
    else if (dt_ld)begin
      cnt_wh_latch <= 128;
      latch_done <= 0;
      bit_cnt <= 1;
    end
    else if (sd_cnfg) begin
      if (flag_for_edge && Led_clk) begin
        if (bit_cnt < 128) bit_cnt <= bit_cnt + 1;
        else begin
          config_num = config_num + 2;
          config_sended = 1;
        end
      end
    end
    else if (wt)begin
      if (flag_for_edge && Led_clk)begin 
        if(bit_cnt < 128) bit_cnt = bit_cnt + 1;
        else bit_cnt = 0;
       end 
    end
    else if (pract) begin
      bit_cnt <= 0;
      cnt_wh_latch <= 16 - 14;
      latch_done <= 0;
    end
    else if (en_op) begin
      bit_cnt <= 0;
      cnt_wh_latch <= 16 - 12;
      latch_done <= 0;
    end
    else if (vsy) begin
      bit_cnt <= 0;
      cnt_wh_latch <= 16 - 3;
      latch_done <= 0;
    end
    else if  (ltch)begin
      if (bit_cnt < 16 && flag_for_edge && Led_clk) begin
        bit_cnt <= bit_cnt + 1;
      end
      else if (bit_cnt >= 16) latch_done <= 1;
    end
    else begin 
      cnt_wh_latch <= 16 - 1;//Para el data latch
      bit_cnt <= 0;
      latch_done <= 0;
    end 
  end
end

always @(*) begin
  latch = cnt_wh_latch <= bit_cnt? 1:0;
end

endmodule
