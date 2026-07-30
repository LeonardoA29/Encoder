//------------------------------------------------------------mòdulo principal -------------------------------------------------------//

module Display(clk,reset,en_a,adr_a,dat_a,we_a,dat_a_out,data_rx,spi_clk,MOSI,busy,MISO,DC,displayCS,displayReset,done,init);
    // Inputs del perifèrico

    input  clk;
    input reset;
    
    //Inputs a memoria puerot A

	input  en_a;
	input [11:0]  adr_a;
	input [15:0]  dat_a;
	input we_a;

    // Output de memoria

	output wire [15:0]  dat_a_out;

    //Outputs SPI

    output [15:0]data_rx;
    output spi_clk;
    output MOSI;

    //Inputs a SPI
    input busy;
    input MISO;
    wire w_SPI_init;

    //Inputs memoria Puerto B

	wire  [11:0] w_adr_b;

    //Outputs Address control

    output DC;
    output displayCS;
    output displayReset;
    output done;

    //Input Address control

    input init;
    wire w_spiDone;
    wire [15:0] w_dat_b;
    wire w_delay;

parameter slowing_factor = 38; //38 , Valor de medio periodo del SPI clk , tiene que ser par
parameter number_of_bits = 8; // Numero de bits por paquete
parameter adr_width = 12;
parameter dat_width = 16;
parameter mem_file_name = "init_dpram.ini";

wire w_configState;

dpram dp_ram0 (.clk_a(clk),
                .en_a(en_a),
                .adr_a(adr_a),
                .dat_a(dat_a),
                .we_a(we_a),
                .clk_b(clk),
                .en_b(1'b1),
                .re_b(1'b1),
                .adr_b(w_adr_b),
                .dat_b(w_dat_b),
                .dat_a_out(dat_a_out));

addrCtrl #(.slowing_factor(slowing_factor))
    addrCtrl0 (.reset(reset),
                    .displayReset(displayReset),
                    .clk(clk),
                    .init(1'b0),
                    .spiDone(w_spiDone),
                    .DC_input(w_dat_b[0]),
                    .frst_done(frst_done),
                    .adrB(w_adr_b),
                    .DC(DC),
                    .displayCS(displayCS),
                    .SPI_init(w_SPI_init),
                    .done(done),
                    .delay(w_delay),
                    .configState(w_configState));

SPI #(.slowing_factor(slowing_factor),.number_of_bits(number_of_bits)) 
    SPI0 (.reset(reset),
          .clk(clk),
          .init(w_SPI_init),
          .data_tx(w_dat_b),
          .MISO(MISO),
          .delay(w_delay),
          .busy(!busy),
          .configState(w_configState),
          .done(w_spiDone),
          .frst_done(frst_done),
          .data_rx(data_rx),
          .spi_clk(spi_clk),
          .MOSI(MOSI));


endmodule




