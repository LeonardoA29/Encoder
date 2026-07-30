module peripheral_Rdd(
    input  clk,
    input reset,
	input [31:0]d_in,
	input rd,
    input wr,
	input cs,
	input [6:0]addr,
	output reg [31:0]d_out

);

//------------------------------------ regs and wires-------------------------------
reg [3:0] s; 	     //selector mux_4  and demux_4
reg [31:0]in_Bcd;
reg init; 
wire [26:0] out_Bin;
wire done;

//------------------------------------ regs and wires-------------------------------

//----address_decoder (one selection bit for register) ------------------
always @(*) begin
	case (addr)
		8'h04:begin s = (cs) ? 4'b0001 : 4'b0000 ;end //in_Bcd
		8'h08:begin s = (cs) ? 4'b0010 : 4'b0000 ;end //init
        8'h0C:begin s = (cs) ? 4'b0100 : 4'b0000 ;end //out_Bin
        8'h10:begin s = (cs) ? 4'b1000 : 4'b0000 ;end //done
		default:begin s=4'b0000 ; end
	endcase
end

//Input Registers
always @(posedge clk) begin
	in_Bcd = (s[0] & wr) ? d_in : in_Bcd;
	init = (s[1] & wr) ? d_in[0] : init;
end

//Output registers
always @(posedge clk) begin
	case (s)
		4'b0100: d_out[26:0] = out_Bin;
		4'b1000: d_out= {31'b0,done};
		default: d_out=0;	
	endcase
end
Rev_Double_Dabble RDD(
      .clk(clk), 
      .reset(reset), 
      .init(init), 
      .in_Bcd(in_Bcd), 
      .out_Bin(out_Bin), 
      .done(done)
);
endmodule