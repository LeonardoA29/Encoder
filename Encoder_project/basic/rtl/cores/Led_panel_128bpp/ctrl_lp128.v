module ctrl_lp128(
    input   clk,
    input   Led_clk,
    input   flag_for_edge,
    input   init,
    input   rst,
    input   config_done,
    input   config_sended,
    input   latch_done,
    input   frame_done,
    output  reg ltch,
    output  reg pract,
    output  reg en_op,
    output  reg vsy,
    output  reg ld_cnfg,
    output  reg sd_cnfg,
    output  reg done,
    output  reg dt_ld,
    output  reg wt
);

 parameter START          = 4'b0000;
 parameter CONFIG_STATE   = 4'b0001;
 parameter PREACTIVE      = 4'b0010;
 parameter SENDING_CONFIG = 4'b0011;
 parameter DATA_LD        = 4'b0100;
 parameter WAIT           = 4'b0101;
 parameter LATCH          = 4'b0111;
 parameter VSYNC          = 4'b1000;
 parameter SYNC           = 4'b1001;
 parameter EN_OP          = 4'b1010;

 reg [3:0] state;
 reg [3:0] sync_state;
 reg en_op_sended;
 reg ready_vsync;
 reg first_pract;

 always @(posedge clk) begin
  if (rst) begin
    state = SYNC;
    en_op_sended = 0;
    ready_vsync = 1;
    first_pract = 0;
    sync_state <= PREACTIVE;
  end else begin
    case(state)
      START: begin
        if(init)begin
          state <= SYNC;
          sync_state <= DATA_LD;
          ready_vsync <= 1;
        end
        else begin
          state <= START;
        end
        
      end 

      SYNC: begin
        if (Led_clk && flag_for_edge)
          state <= sync_state;
        else 
          state <= SYNC; 
      end

      CONFIG_STATE: begin
        state <= SENDING_CONFIG;
      end

      PREACTIVE: begin 
        state <= LATCH;
      end

      EN_OP:begin
        en_op_sended <= 1;
        state <= LATCH;
      end

      SENDING_CONFIG: begin
        if (config_done) state <= START;
        else if (config_sended) state <= PREACTIVE;
        else state <= SENDING_CONFIG;
      end

      LATCH: begin
        if(latch_done) begin
          if (frame_done && ready_vsync) state <= VSYNC;
          else if (frame_done && !ready_vsync) state <= START;
          else if (!en_op_sended) state <= EN_OP;
          else if (en_op_sended && !first_pract) begin
            state <= PREACTIVE;
            first_pract <= 1;
          end
          else state <= CONFIG_STATE;
        end
        
        else state = LATCH;
      end
      DATA_LD: begin
        state = WAIT;
      end

      WAIT: begin
        if (frame_done)begin
         state <= VSYNC; 
         ready_vsync <= 1;
        end
        else  state <= WAIT;
      end
      VSYNC: begin
        state <= LATCH;
        ready_vsync <= 0;
      end
      default: state <= START;
    endcase
  end
end

always @(*) begin
    case(state)
      START: begin
        ltch = 0; pract = 0; vsy = 0; ld_cnfg = 0; sd_cnfg = 0;
        done = 1; dt_ld = 0; en_op = 0; wt = 0;
      end

      CONFIG_STATE: begin
        ltch = 0; pract = 0; vsy = 0; ld_cnfg = 1; sd_cnfg = 0;
        done = 0; dt_ld = 0; en_op = 0; wt = 0;
      end

      PREACTIVE: begin
        ltch = 0; pract = 1; vsy = 0; ld_cnfg = 0; sd_cnfg = 0;
        done = 0; dt_ld = 0; en_op = 0; wt = 0;
      end

      EN_OP: begin
        ltch = 0; pract = 0; vsy = 0; ld_cnfg = 0; sd_cnfg = 0;
        done = 0; dt_ld = 0; en_op = 1; wt = 0;
      end

      SENDING_CONFIG: begin
        ltch = 0; pract = 0; vsy = 0; ld_cnfg = 0; sd_cnfg = 1;
        done = 0; dt_ld = 0; en_op = 0; wt = 0;
      end

      DATA_LD: begin
        ltch = 0; pract = 0; vsy = 0; ld_cnfg = 0; sd_cnfg = 0;
        done = 0; dt_ld = 1; en_op = 0; wt = 0;
      end

      LATCH: begin
        ltch = 1; pract = 0; vsy = 0; ld_cnfg = 0; sd_cnfg = 0;
        done = 0; dt_ld = 0; en_op = 0; wt = 0;
      end

      VSYNC: begin
        ltch = 0; pract = 0; vsy = 1; ld_cnfg = 0; sd_cnfg = 0;
        done = 0; dt_ld = 0; en_op = 0; wt = 0;
      end

      WAIT:begin
        ltch = 0; pract = 0; vsy = 0; ld_cnfg = 0; sd_cnfg = 0;
        done = 0; dt_ld = 0; en_op = 0; wt = 1;        
      end

      default: begin
        ltch = 0; pract = 0; vsy = 0; ld_cnfg = 0; sd_cnfg = 0;
        done = 0; dt_ld = 0; en_op = 0; wt = 0;
      end
    endcase
end

`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(state)
    START          : state_name = "START";
    SYNC           : state_name = "SYNC";
    CONFIG_STATE   : state_name = "CONFIG_STATE";
    PREACTIVE      : state_name = "PREACTIVE";
    EN_OP          : state_name = "EN_OP";
    SENDING_CONFIG : state_name = "SENDING_CONFIG";
    DATA_LD        : state_name = "DATA_LD";
    WAIT           : state_name = "WAIT";
    LATCH          : state_name = "LATCH";
    VSYNC          : state_name = "VSYNC";
  endcase
end
`endif

endmodule
