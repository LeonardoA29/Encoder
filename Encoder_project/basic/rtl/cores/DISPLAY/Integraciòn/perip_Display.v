module peripheral_Display(
    input  clk,
    input reset,
	input [15:0]d_in,
	input MISO,
	input busy,
	output wire DC,
    output wire displayCS,
    output wire displayReset,
    output wire spi_clk,
    output wire MOSI,
	input rd,
    input wr,
	input cs,
	input [6:0]addr,
	output reg [15:0]d_out

);

//------------------------------------ regs and wires-------------------------------
reg [6:0] s; 	     //selector mux_4  and demux_4
reg [15:0] dat_a;
reg [11:0] adr_a;
reg init;
reg mem_wr;
wire [15:0] data_rx;  
wire [15:0]dat_a_out;
wire done;

//------------------------------------ regs and wires-------------------------------

//----address_decoder (one selection bit for register) ------------------
always @(*) begin
	case (addr)
		8'h04:begin s = (cs) ? 7'b0000001 : 7'b000000 ;end //dat_a
		8'h08:begin s = (cs) ? 7'b0000010 : 7'b000000 ;end //adr_a
		8'h0C:begin s = (cs) ? 7'b0000100 : 7'b000000 ;end //init
		8'h10:begin s = (cs) ? 7'b0001000 : 7'b000000 ;end //mem_wr
		8'h14:begin s = (cs) ? 7'b0010000 : 7'b000000 ;end //data_rx
		8'h18:begin s = (cs) ? 7'b0100000 : 7'b000000 ;end //dat_a_out
		8'h1C:begin s = (cs) ? 7'b1000000 : 7'b000000 ;end //done
		default:begin s=7'b0000000 ; end
	endcase
end

//Input Registers
always @(posedge clk) begin
	dat_a = (s[0] & wr) ? d_in[15:0] : dat_a;
	adr_a = (s[1] & wr) ? d_in[11:0] : adr_a;
	init = (s[2] & wr) ? d_in[0] : init;
	mem_wr = (s[3] & wr) ? d_in[0] : mem_wr;
end

//Output registers
always @(posedge clk) begin
	case (s)
		7'b0010000: d_out= {data_rx};
		7'b0100000: d_out= {dat_a_out};
		7'b1000000: d_out= {15'b0,done};
		default: d_out=0;	
	endcase
end

Display Display0 (.clk(clk),			//input
				.reset(reset),			//input
				.en_a(cs),			//input
				.adr_a(adr_a),			//input
				.dat_a(dat_a),			//input
                .we_a(mem_wr),			//input
				.dat_a_out(dat_a_out),			//Output
				.data_rx(data_rx),				//Output
				.spi_clk(spi_clk),				//Output
            	.MOSI(MOSI),					//Output
				.busy(busy),
				.MISO(MISO),		// External input
				.DC(DC),						//Output
				.displayCS(displayCS),			//Output
                .displayReset(displayReset),	//Output
				.done(done),					//Output
				.init(init));	//input
endmodule
