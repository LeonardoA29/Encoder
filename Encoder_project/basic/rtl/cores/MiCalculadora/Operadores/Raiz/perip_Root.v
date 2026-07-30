module peripheral_Root(
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
reg [4:0] s; 	     //selector mux_4  and demux_4
reg [27:0] Radicando;
reg init; 
wire [13:0]Raiz;
wire [27:0]Residuo;
wire done;

//------------------------------------ regs and wires-------------------------------

//----address_decoder (one selection bit for register) ------------------
always @(*) begin
	case (addr)
		8'h04:begin s = (cs) ? 5'b00001 : 5'b0000 ;end //Radicando
		8'h08:begin s = (cs) ? 5'b00010 : 5'b0000 ;end //init
        8'h0C:begin s = (cs) ? 5'b00100 : 5'b0000 ;end //Raiz
        8'h10:begin s = (cs) ? 5'b01000 : 5'b0000 ;end //Residuo
		8'h14:begin s = (cs) ? 5'b10000 : 5'b0000 ;end //done
		default:begin s=4'b0000 ; end
	endcase
end

//Input Registers
always @(posedge clk) begin
	Radicando = (s[0] & wr) ? d_in[27:0] : Radicando;
	init = (s[1] & wr) ? d_in[0] : init;
end

//Output registers
always @(posedge clk) begin
	case (s)
		5'b00100: d_out= {18'b0,Raiz};
		5'b01000: d_out= {3'b0,Residuo};
		5'b10000: d_out= {31'b0,done};
		default: d_out=0;	
	endcase
end
Root Rt(
      .clk(clk), 
      .reset(reset), 
      .init(init), 
      .Radicando(Radicando), 
	  .Raiz(Raiz),
      .Residuo(Residuo), 
      .done(done)
);
endmodule