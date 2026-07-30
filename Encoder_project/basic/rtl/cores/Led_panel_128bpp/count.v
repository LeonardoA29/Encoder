module count#(
    parameter width = 5
)(
    input   clk,
    input   rst,
    input   inc,
    output  reg [width:0] outc,
    output  zero
);

always @(negedge clk) begin
  if(rst)
    outc <= 0;
  else if(inc)
    outc <= outc + 1;
end
assign zero = (outc == 0) ? 1 : 0;
endmodule
