module clk_div#(
    parameter slowing_factor = 30)(
    input clk,
    input rst,

    output reg Led_clk,
    output reg flag_for_edge 
    );

reg [15:0] clk_cnt;

always @(posedge clk)begin
    if (rst) begin 
        flag_for_edge <= 0;
        Led_clk <= 0;
        clk_cnt <= 0;
    end else begin
        if (clk_cnt == slowing_factor)begin
                Led_clk <= ~Led_clk;
                flag_for_edge <= 0;
                clk_cnt <= 0;
        end else if (clk_cnt == slowing_factor - 1) begin
            flag_for_edge = 1;
            clk_cnt <= clk_cnt + 1;
        end else begin 
            clk_cnt <= clk_cnt + 1;
            flag_for_edge <= 0;     
        end    
    end 
end
endmodule