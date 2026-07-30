module peripheral_Led(
    input  clk,
    input reset,
	input [31:0]d_in,
	input rd,
    input wr,
	input cs,
	input [6:0]addr,

	output wire DIO,
	output wire clk_com,
	output wire STB,
	output reg [31:0]d_out

);

//------------------------------------ regs and wires-------------------------------
reg [2:0] s; 	     //selector mux_4  and demux_4
reg init; 
reg [31:0]in_Bcd;
wire done;
//------------------------------------ regs and wires-------------------------------

//----address_decoder (one selection bit for register) ------------------
always @(*) begin
	case (addr)
		8'h04:begin s = (cs) ? 3'b001 : 3'b000 ;end //in_Bcd
		8'h08:begin s = (cs) ? 3'b010 : 3'b000 ;end //init
		8'h0C:begin s = (cs) ? 3'b100 : 3'b000 ;end //done
		default:begin s=3'b000 ; end
	endcase
end

//Input Registers
always @(posedge clk) begin
	in_Bcd = (s[0] & wr) ? d_in[31:0] : in_Bcd;
	init = (s[1] & wr) ? d_in[0] : init;
end
//Output registers
always @(posedge clk) begin
	case (s)
		3'b100: d_out= {31'b0,done};
		default: d_out=0;	
	endcase
end
Led Led0(
      .clk(clk), 
      .reset(reset), 
      .init(init),
      .in_Bcd(in_Bcd), 
      .DIO(DIO),
      .clk_com(clk_com),
      .STB(STB), 
      .done(done)
   );

endmodule