module peripheral_div(
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
reg [5:0] s; 	     //selector mux_4  and demux_4
reg [26:0] Dividendo;
reg  [26:0] Divisor;
reg init; 

wire [26:0]Cociente;
wire [26:0]Residuo;
wire done;

//------------------------------------ regs and wires-------------------------------

//----address_decoder (one selection bit for register) ------------------
always @(*) begin
	case (addr)
		8'h04:begin s = (cs) ? 6'b000001 : 6'b000000 ;end //Dividendo
		8'h08:begin s = (cs) ? 6'b000010 : 6'b000000 ;end //Divisor
		8'h0C:begin s = (cs) ? 6'b000100 : 6'b000000 ;end //init
        8'h10:begin s = (cs) ? 6'b001000 : 6'b000000 ;end //Cociente
        8'h14:begin s = (cs) ? 6'b010000 : 6'b000000 ;end //Residuo
		8'h18:begin s = (cs) ? 6'b100000 : 6'b000000 ;end //done
		default:begin s=6'b000000 ; end
	endcase
end

//Input Registers
always @(posedge clk) begin
	Dividendo = (s[0] & wr) ? d_in[26:0] : Dividendo;
	Divisor = (s[1] & wr) ? d_in[26:0] : Divisor;
	init = (s[2] & wr) ? d_in[0] : init;
end

//Output registers
always @(posedge clk) begin
	case (s)
		6'b001000: d_out= {5'b0,Cociente};
		6'b010000: d_out= {5'b0,Residuo};
		6'b100000: d_out= {31'b0,done};
		default: d_out=0;	
	endcase
end
Div Dv(
      .clk(clk), 
      .reset(reset), 
      .init(init), 
      .Dividendo(Dividendo), 
      .Divisor(Divisor),
      .Cociente(Cociente),
      .Residuo(Residuo), 
      .done(done)
);
endmodule
