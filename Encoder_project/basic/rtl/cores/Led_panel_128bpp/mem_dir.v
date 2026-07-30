module mem_dir(
    input clk,
    input Led_clk,
    input flag_for_edge,
    input rst,
    input dt_ld,
    input frame_done,
    input done,
    output wire [11:0] Address
);
reg [5:0] cnt;
reg inc;
reg cnt_rst;
reg stream_send;

always @(negedge clk) begin
    if (rst)begin 
        stream_send <= 0;
        cnt_rst <= 1;
        cnt <= 0;
        inc <= 0;
    end
    else begin
        cnt_rst <= 0;
        if (done) begin
            cnt_rst <= 1;
            cnt <= 0;
            stream_send <= 0;
            inc <= 0;
        end 
        else if (dt_ld) begin
            stream_send <= 1;
            cnt <= 0;
        end
        else if (frame_done) stream_send <= 0;
        else if (stream_send && flag_for_edge && !Led_clk) begin
            if (!cnt) begin
                inc <= 1; cnt <= 15;
            end
            else begin
                cnt <= cnt - 1;
            end
        end

        else inc <= 0;           
    end
end

count #(.width(11)) instance_name (.clk(clk),.rst(cnt_rst),.inc(inc),.outc(Address));
endmodule


