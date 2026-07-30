module memory#(
    parameter size = 2047,
    parameter width = 11,
    parameter mem_file_name = "images/imageR0.hex"
)(
  input              clk,
  input  [width:0]   address,
  input              rd,
  output reg [15:0]  rdata,

  input              we_a,
  input  [width:0]   w_address,
  input  [15:0]      w_data,
  input              en_a
);

reg [15:0] MEM [0:size-1];

initial begin
    $readmemh(mem_file_name,MEM);  
end

  always @(negedge clk) begin
    if(rd) begin
      rdata <= MEM[address[width:0]];     //{RGB0,RGB1}
    end
  end

//------------------------------------------------------------------
// write port A
//------------------------------------------------------------------


always @(negedge clk)
begin
	if (en_a) begin
		  if (we_a) begin
			    MEM[w_address[width:0]] <= w_data;
		  end 
//      dat_a_out<=MEM[w_address];
	end 
end

endmodule
