module Row_dir#(
    parameter width = 5
)(
    input   clk,
    input   rst,
    input   vsy,
    input   latch_done,
    input   flag_for_edge,
    input   Led_clk,
    output  reg [width - 1:0] outc,
    output  reg OE
);

localparam MAX = {(width + 1){1'b1}};

reg [6:0] OE_cnt; 
reg vsy_flag;
reg start_flag;

always @(negedge clk) begin
  if(rst) begin
    outc <= 0;
    OE_cnt <= 0;
    vsy_flag <= 0;
    start_flag <= 0;
    OE <= 0;
  end
  else begin
    if (vsy) begin
        vsy_flag <= 1;
        start_flag <= 0;
        outc <= 0;
        OE_cnt <= 0;  
    end
    else if (vsy_flag && latch_done) begin
        vsy_flag <= 0;
        start_flag <= 1;
    end
    else if (start_flag && flag_for_edge) begin
        if (OE_cnt >= 74) begin
          if (OE_cnt == 78)begin
            if (outc == MAX) outc <= 0;
            else outc <= outc + 1;
            OE_cnt <= OE_cnt + 1;
          end
          else if (OE_cnt == 127) OE_cnt <= 0;
          OE <= 0;
          OE_cnt <= OE_cnt + 1;
        end
        else begin
          OE_cnt <= OE_cnt + 1;
          OE <= ~OE; 
        end
      end
  end
end
endmodule


