module peripheral_Rdd_TB;
reg clk;
reg reset;
reg [31:0]d_in;
reg rd;
reg wr;
reg cs;
reg [6:0]addr;
   
wire done;
wire [31:0]d_out;

peripheral_Rdd peripheral_Rdd0(
      .clk(clk), 
      .reset(reset), 
	  .d_in(d_in),
	  .rd(rd),
	  .wr(wr),
	  .cs(cs),
	  .addr(addr),
	  .d_out(d_out)
);

parameter PERIOD = 20;
initial begin  
    clk = 0; reset = 0; d_in = 0; addr = 7'b0; cs=0; rd=0; wr=0;
end

initial         clk <= 0;
always #(PERIOD/2) clk <= ~clk;

initial begin 
	@ (negedge clk);
	reset = 1;
	@ (negedge clk);
	reset = 0;
	#(PERIOD)
	cs=1; rd=0; wr=1;
	d_in = 32'h12345678;
	addr = 8'h08;
	#(PERIOD)
    d_in = 1;
	addr = 8'h10;
	#(PERIOD*5)
    d_in = 0;
	addr = 8'h10;
	#(PERIOD*5) 
	cs=0; rd=0; wr=0;
end
always @(posedge peripheral_Rdd_TB.peripheral_Rdd0.RDD.done) begin
	cs=1; rd=1; wr=0;
	addr = 8'h12;
	#(PERIOD);
end
initial begin: TEST_CASE
     $dumpfile("perip_Rev_Double_Dabble_TB.vcd");
     $dumpvars(-1, peripheral_Rdd_TB);
     #(PERIOD*500000) $finish;
end



endmodule