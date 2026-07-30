//------------------------------------------------------------mòdulo principal -------------------------------------------------------//

module SPI(reset,clk,init,data_tx,MISO,done,data_rx,spi_clk,MOSI);

    input reset;
	input clk;             
	input init;
    input [7:0]data_tx;
    input MISO;

    output done;
    output [7:0]data_rx;
    output spi_clk;
    output MOSI;

    wire w_sh;
    wire w_reset;
    wire w_load;
    wire w_send;
    wire w_x;

control_SPI control0(.reset(reset),.clk(clk),.init(init),.x(w_x),.spi_clk(spi_clk),.dn(done),.sh(w_sh),.ld(w_load),.sd(w_send));
spiclk spiclk0(.shift(w_sh),.send(w_send),.load(w_load),.spi_clk(spi_clk),.x(w_x));
data data0(.load(w_load),.shift(w_sh),.send(w_send),.data_tx(data_tx),.MISO(MISO),.MOSI(MOSI),.data_rx(data_rx));

endmodule

//----------------------------------------------modulo de manipulaciòn del registro data ---------------------------------------------//

module data(load,shift,send,data_tx,MISO,MOSI,data_rx);
   input load;
   input shift;
   input send;
   input [7:0]data_tx;
   input MISO;
   
   output reg[7:0]data_rx;
   output reg MOSI;
   
initial begin
    data_rx = 0;
    MOSI = 0;
end

always @(*)begin
    if (load) data_rx = data_tx;
    else if (shift) data_rx = {MISO,data_rx[7:1]};
    else if (send) MOSI = data_rx[0];
end

endmodule

//----------------------------------------------------------modulo señal de reloj y finalizaciòn ----------------------------------------------------//

module spiclk(shift,send,load,spi_clk,x);
    input shift;
    input send;
    input load;
    
    output reg spi_clk;
    output x;

reg temp;
reg [3:0] bit_cnt;
parameter size_pack = 8;
assign x = temp;

initial begin 
    spi_clk = 0;
    temp = 0;
    bit_cnt = 0;
end

always @(*)begin
    if (load) begin 
        bit_cnt = 0;
        temp = 0;
    end
    else begin
        if (bit_cnt != size_pack) begin
            if (send) spi_clk = 1;
            else if (shift) begin
                spi_clk = 0;
                bit_cnt = bit_cnt + 1;
            end
        end
        else if (send) temp = 1;
    end
end

endmodule


//------------------------------------------------------------mòdulo control ---------------------------------------------------------//

module control_SPI(reset,clk,init,x,spi_clk,dn,sh,ld,sd);
	input reset;
	input clk;             
	input init;
    input x;
    input spi_clk;

	output reg dn; 
    output reg sh;
    output reg ld;
    output reg sd;     
    			
parameter START = 3'b000, LOAD = 3'b001, SEND = 3'b010,SHIFT = 3'b011, SPI_CLK = 3'b100, DONE = 3'b101;
reg [2:0] state;

parameter medio_periodo = 5;
reg [14:0] count;

initial begin 
    dn = 0;
    sh = 0;
    sd = 0;
    ld = 0;
    state = 0;
    count = 0;
end 
always @(posedge clk) begin
    if (reset) begin 
        state = START;
    end
    else begin 
        case (state)
            START:

                if (init) state = LOAD;
                else state = START;
                
            LOAD:begin
            
                count = 0;
                state = SPI_CLK;
            end    
            SPI_CLK:
                
                if (x) begin
                state = DONE;
                end 
                else begin
                    if(count != medio_periodo && count != 2*medio_periodo)   begin
                        count = count + 1;
                        state = SPI_CLK;
                    end else if (count == medio_periodo) begin
                        state = SEND;
                        count = count + 1;
                    end else begin
                        state = SHIFT;
                        count = 0;
                    end
                end
            SEND:
                state = SPI_CLK;
            SHIFT:
                state = SPI_CLK;
            DONE:
                state = START;

            default:
                state = START;
        endcase
   end
end

always @(*) begin
    case (state)
        START: begin     
            sh = 0;
            ld = 0;
            sd = 0;
        end

        LOAD: begin
            dn = 0;
            sh = 0;
            ld = 1;
            sd = 0;
        end
        SPI_CLK: begin 
            dn = 0;
            sh = 0;
            ld = 0;
            sd = 0;
        end
        SEND: begin
            dn = 0;
            sh = 0;
            ld = 0;
            sd = 1;
        end
        
        SHIFT: begin 
            dn = 0;
            sh = 1;
            ld = 0;
            sd = 0;
        end     
        DONE: begin
            dn = 1;
            sh = 0;
            ld = 0;
            sd = 0;
        end
    endcase
end

`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(state)
    START    : state_name = "START";
    LOAD   : state_name = "LOAD";
    SEND    : state_name = "SEND";
    SPI_CLK   : state_name = "SPI_CLK";
    SHIFT    : state_name = "SHIFT";
    DONE    : state_name = "DONE";
  endcase
end
`endif
endmodule


