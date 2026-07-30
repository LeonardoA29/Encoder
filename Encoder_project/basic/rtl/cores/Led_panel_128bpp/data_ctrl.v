module data_ctrl #(
  parameter number_of_bits = 128 * 64 * 48 
)
(
  input clk,
  input flag_for_edge,
  input rst,
  input wire [2:0]config_register,
  input dt_ld,
  input ld_cnfg,
  input sd_cnfg,
  input done,
  input wire [15:0] data_R0,
  input wire [15:0] data_G0,
  input wire [15:0] data_B0,
  input wire [15:0] data_R1,
  input wire [15:0] data_G1,
  input wire [15:0] data_B1,
  output frame_done,
  output reg [2:0] RGB0,
  output reg [2:0] RGB1
);

reg [15:0] in_data_R0;
reg [15:0] in_data_G0;
reg [15:0] in_data_B0;
reg [15:0] in_data_R1;
reg [15:0] in_data_G1;
reg [15:0] in_data_B1;

reg [5:0] bit_cnt;
reg [15:0] pack_cnt;
reg [1:0] sub_state;
reg [3:0] config_rep;

assign frame_done = bit_cnt >= 1 && pack_cnt > 4095? 1:0;
                            
localparam  SHIFT = 2'b01 , SEND = 2'b00, DONE = 2'b10;
localparam config1 = 16'h1FB0, config2 = 16'h0fb0, config3 = 16'h20B6,config4 = 16'h1A70,config5 = 16'h7E08;
//localparam config1 = 16'h0970, config3 = 16'h4007,config4 = 16'h0040,config5 = 16'h0000;
localparam config2R = 16'hF39C, config2G = 16'hE79C, config2B = 16'hD79C;

always @(negedge clk)begin 
  if (done || rst)begin
        RGB0 <= 3'b0;
        RGB1 <= 3'b0;
        sub_state <= DONE; 
        bit_cnt <= 0;
        config_rep <= 0;
        pack_cnt <= 0;
        in_data_R0 <= 0;
        in_data_B0 <= 0;
        in_data_G0 <= 0;
        in_data_R1 <= 0;
        in_data_G1 <= 0;
        in_data_B1 <= 0;
  end 
  if (dt_ld)begin
    in_data_R0 <= data_R0;
    in_data_B0 <= data_B0;
    in_data_G0 <= data_G0;
    in_data_R1 <= data_R1;
    in_data_G1 <= data_G1;
    in_data_B1 <= data_B1;

    RGB0 <= {data_R0[15],data_G0[15],data_B0[15]};
    RGB1 <= {data_R1[15],data_G1[15],data_B1[15]};

    sub_state <= SHIFT;
    bit_cnt <= 1;
    pack_cnt <= 0;
  end
  if (ld_cnfg)begin
    case (config_register)
      1:begin
        in_data_R0 <= config1;
        in_data_B0 <= config1;
        in_data_G0 <= config1;
        in_data_R1 <= config1;
        in_data_G1 <= config1;
        in_data_B1 <= config1;

        RGB0 <= {config1[15],config1[15],config1[15]};
        RGB1 <= {config1[15],config1[15],config1[15]};
      end
      2:begin
        in_data_R0 <= config2R;
        in_data_B0 <= config2B;
        in_data_G0 <= config2G;
        in_data_R1 <= config2R;
        in_data_G1 <= config2G;
        in_data_B1 <= config2B;

        RGB0 <= {config2R[15],config2G[15],config2B[15]};
        RGB1 <= {config2R[15],config2G[15],config2B[15]};
      end
      3:begin
        in_data_R0 <= config3;
        in_data_B0 <= config3;
        in_data_G0 <= config3;
        in_data_R1 <= config3;
        in_data_G1 <= config3;
        in_data_B1 <= config3;

        RGB0 <= {config3[15],config3[15],config3[15]};
        RGB1 <= {config3[15],config3[15],config3[15]};
      end
      4:begin
        in_data_R0 <= config4;
        in_data_B0 <= config4;
        in_data_G0 <= config4;
        in_data_R1 <= config4;
        in_data_G1 <= config4;
        in_data_B1 <= config4;

        RGB0 <= {config4[15],config4[15],config4[15]};
        RGB1 <= {config4[15],config4[15],config4[15]};
      end
      5:begin
        in_data_R0 <= config5;
        in_data_B0 <= config5;
        in_data_G0 <= config5;
        in_data_R1 <= config5;
        in_data_G1 <= config5;
        in_data_B1 <= config5;

        RGB0 <= {config5[15],config5[15],config5[15]};
        RGB1 <= {config5[15],config5[15],config5[15]};
      end
      default:;
    endcase
    config_rep <= 0;
    sub_state <= SHIFT;
    bit_cnt <= 1;
  end
  else if (sub_state == SEND && flag_for_edge && pack_cnt < 4096)begin
    if (bit_cnt >= 16) begin
      if (config_rep >= 7 ) begin
        if (bit_cnt < 18) bit_cnt = bit_cnt + 1;
        else sub_state <= DONE; 
      end
      else if (sd_cnfg)begin
        case (config_register)
          1:begin
            in_data_R0 <= config1;
            in_data_B0 <= config1;
            in_data_G0 <= config1;
            in_data_R1 <= config1;
            in_data_G1 <= config1;
            in_data_B1 <= config1;

            RGB0 <= {config1[15],config1[15],config1[15]};
            RGB1 <= {config1[15],config1[15],config1[15]};
          end
          2:begin
            in_data_R0 <= config2R;
            in_data_B0 <= config2B;
            in_data_G0 <= config2G;
            in_data_R1 <= config2R;
            in_data_G1 <= config2G;
            in_data_B1 <= config2B;

            RGB0 <= {config2R[15],config2G[15],config2B[15]};
            RGB1 <= {config2R[15],config2G[15],config2B[15]};
          end
          3:begin
            in_data_R0 <= config3;
            in_data_B0 <= config3;
            in_data_G0 <= config3;
            in_data_R1 <= config3;
            in_data_G1 <= config3;
            in_data_B1 <= config3;

            RGB0 <= {config3[15],config3[15],config3[15]};
            RGB1 <= {config3[15],config3[15],config3[15]};
          end
          4:begin
            in_data_R0 <= config4;
            in_data_B0 <= config4;
            in_data_G0 <= config4;
            in_data_R1 <= config4;
            in_data_G1 <= config4;
            in_data_B1 <= config4;

            RGB0 <= {config4[15],config4[15],config4[15]};
            RGB1 <= {config4[15],config4[15],config4[15]};
          end
          5:begin
            in_data_R0 <= config5;
            in_data_B0 <= config5;
            in_data_G0 <= config5;
            in_data_R1 <= config5;
            in_data_G1 <= config5;
            in_data_B1 <= config5;

            RGB0 <= {config5[15],config5[15],config5[15]};
            RGB1 <= {config5[15],config5[15],config5[15]};
          end
          default:;
        endcase

        config_rep <= config_rep + 1;
        sub_state <= SHIFT;
        bit_cnt <= 1;
    end
    else begin // Para cambiar continuamente sin necesidad de un load entre paquetes
        in_data_R0 <= data_R0;
        in_data_G0 <= data_G0;
        in_data_B0 <= data_B0;
        in_data_R1 <= data_R1;
        in_data_G1 <= data_G1;
        in_data_B1 <= data_B1;

        RGB0 <= {data_R0[15],data_G0[15],data_B0[15]};
        RGB1 <= {data_R1[15],data_G1[15],data_B1[15]};

        pack_cnt <= pack_cnt + 1;
        sub_state <= SHIFT;
        bit_cnt <= 1;
      end
    end
    else begin

      RGB0 <= {in_data_R0[15],in_data_G0[15],in_data_B0[15]};
      RGB1 <= {in_data_R1[15],in_data_G1[15],in_data_B1[15]};

      bit_cnt <= bit_cnt + 1;
      sub_state <= SHIFT;       
    end

  end
  else if (sub_state == SHIFT && flag_for_edge && pack_cnt < 4096) begin

    in_data_R0 <= in_data_R0 << 1;
    in_data_G0 <= in_data_G0 << 1;
    in_data_B0 <= in_data_B0 << 1;
    in_data_R1 <= in_data_R1 << 1;
    in_data_G1 <= in_data_G1 << 1;
    in_data_B1 <= in_data_B1 << 1;

    sub_state <= SEND;

  end

end

`ifdef BENCH
reg [8*40:1] substate_name;
always @(*) begin
  case(sub_state)
    SEND  : substate_name = "SEND";
    SHIFT   : substate_name = "SHIFT";
    DONE    : substate_name = "DONE";
  endcase
end
`endif
endmodule
