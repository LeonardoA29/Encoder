//------------------------------------------------------------mòdulo principal -------------------------------------------------------//

module SPI #(
    parameter slowing_factor = 30,
    parameter number_of_bits = 8)
    (
    input reset,
	input clk,             
	input init,
    input [number_of_bits*2 - 1:0]data_tx,
    input MISO,
    input delay,
    input busy,
    input configState,

    output done,
    output frst_done,
    output [number_of_bits*2 - 1:0]data_rx,
    output spi_clk,
    output MOSI);

wire w_load;
wire w_done;
wire w_flag_for_edge;
wire w_ending;
wire w_stop;
wire w_spi_clk;
wire w_scnd_ld;

assign w_done = done;
assign w_spi_clk = spi_clk;

spi_datapath #(.number_of_bits(number_of_bits)) 
    spi_datapath0(.clk(clk),
                  .flag_for_edge(w_flag_for_edge),
                  .spi_clk(w_spi_clk),
                  .reset(reset),
                  .done(w_done),
                  .load(w_load),
                  .scnd_ld(w_scnd_ld),
                  .data_tx(data_tx),
                  .MISO(MISO),
                  .ending(w_ending),
                  .data_rx(data_rx),
                  .MOSI (MOSI));

spiclk #(.slowing_factor(slowing_factor)) 
    spiclk0  (.clk(clk),
              .reset(reset),
              .done(w_done),
              .load(w_load),
              .stop(w_stop),
              .scnd_ld(w_scnd_ld),
              .spi_clk(spi_clk),
              .flag_for_edge(w_flag_for_edge));

control_SPI control_SPI0 (.reset(reset),
                          .clk(clk),
                          .init(init),
                          .ending(w_ending),
                          .configState(configState),
                          .delay(delay),
                          .busy(busy),
                          .dn(done),
                          .ld(w_load),
                          .stop(w_stop),
                          .scnd_ld(w_scnd_ld),
                          .frst_done(frst_done));

endmodule

//----------------------------------------------modulo de manipulaciòn del registro data ---------------------------------------------//

module spi_datapath #(
    parameter number_of_bits = 8)
    (  
    input clk,
    input flag_for_edge,
    input spi_clk,
    input reset,
    input done,
    input load,
    input scnd_ld,
    input [number_of_bits*2 - 1 :0]data_tx,
    input MISO,

    output ending,
    output reg[number_of_bits*2 - 1:0]data_rx,
    output reg MOSI);


reg [6:0] bit_cnt;
reg [1:0] sub_state;
reg [number_of_bits*2 - 1 :0]data;

assign ending = bit_cnt == number_of_bits && !spi_clk? 1:0; // es la señal a la maquina de control de que se acabo el envío de datos
                                        //^este and es necesario para evitar que acabe el clk subitamente, sino que espere a que este en 0
localparam  SHIFT = 2'b01 , SEND = 2'b00, DONE = 2'b10;

always @(posedge clk)begin // Es modulo que en el fondo es sensible a ambos flancos del spi_clk
    if (done || reset)begin
        MOSI <= 0;
        sub_state <= DONE; // Solamente como precaución, evita que algo se envie en caso de que el done se haga 0 pero no se de un load
        bit_cnt <= 0;
        data_rx <= 0;
    end 
    else if (scnd_ld) begin
        MOSI <= data[number_of_bits*2 - 1]; // se carga el primer bit del MOSI ya que el modulo lo lee en el flanco positivo del clk
        bit_cnt <= 0;
        sub_state <= SHIFT;
    end
    else if (load) begin 
        MOSI <= data_tx[number_of_bits * 2 - 1]; // se carga el primer bit del MOSI ya que el modulo lo lee en el flanco positivo del clk
        data <= data_tx;
        bit_cnt <= 0;
        sub_state <= SHIFT;
    end
    else if (sub_state == SHIFT && flag_for_edge)begin

        data_rx <= {data_rx[number_of_bits*2 - 2:0],MISO};// se recibe el dato del MISO y se borra el dato del MOSI que ya se envío
        data <= data << 1;
        sub_state <= SEND;
        bit_cnt <= bit_cnt + 1; // El contador se ubica en este sub estado ya que hay que esperar a recibir el ultimo bit del mosi antes de acbar
    end
    else if (sub_state == SEND && flag_for_edge) begin
        MOSI <= data[number_of_bits * 2 - 1]; // Se cambia el dato del MOSI
        sub_state <= SHIFT; 
    end
end

`ifdef BENCH
reg [8*40:1] substate_name;
always @(*) begin
  case(sub_state)
    SEND  : substate_name = "SEND";
    SHIFT   : substate_name = "SHIFT";
    DONE    : substate_name = "DONE";
  endcase
end
`endif
endmodule

//----------------------------------------------------------modulo señal de reloj ----------------------------------------------------//

module spiclk #(
    parameter slowing_factor = 30)(
    input clk,
    input reset,
    input done,
    input load,
    input stop,
    input scnd_ld,

    output reg spi_clk, //Clk de salida del SPI
    output reg flag_for_edge //Clk para poder hace la FSM dependiente de ambos flancos del spi_clk, evitando metaestabilidad 
    );

reg [15:0] clk_div; // Contador del clk

always @(negedge clk)begin
    if (reset || done || stop) begin //se detiene ante estas señales, dado el periferico mantiene el done = 1 una vez acaba
        flag_for_edge <= 0;
        spi_clk <= 0;
        clk_div <= 0;
    end else if(load || scnd_ld)begin // para realizar la carga previa del primer dato del mosi es necesario que empiecen en fancos contrarios
        flag_for_edge <= 1;
        spi_clk <= 0; 
        clk_div <= 0;
    end else begin // generación de ambos clk
        if (clk_div == slowing_factor)begin
                spi_clk <= ~spi_clk;
                flag_for_edge <= 1;
                clk_div <= 0;
        end else begin 
            clk_div <= clk_div + 1;
            flag_for_edge = 0;     
        end    
    end
end
endmodule

//------------------------------------------------------------mòdulo control ---------------------------------------------------------//

module control_SPI (
	input reset,
	input clk,             
	input init,
    input delay,
    input busy,
    input ending,
    input configState,

	output reg dn, 
    output reg ld,
    output reg stop,
    output reg scnd_ld,
    output reg frst_done
);
    			
parameter START = 3'b000, LOAD = 3'b001, SENDING_DATA = 3'b010 , SLAVE_NOT_READY = 3'b011 , SECOND_LD = 3'b100, SECOND_START = 3'b101; 
reg [2:0] state;
reg second_pack;
reg Config_mode;
always @(posedge clk or posedge reset) begin
    if (reset) begin 
        state <= START;
    end
    else if (busy) begin
        state <= SLAVE_NOT_READY; // en caso de que se necesite  parar mientras el pin de busy este en 1(e paper)
    end
    else begin 
        case (state)
            START:begin

                if (init) state <= LOAD;
                else state <= START;
                Config_mode <= configState;
            end
            LOAD: begin 
                state <= SENDING_DATA;
                second_pack <= 0;
            end

            SENDING_DATA: begin
                if (ending) begin// señal de finalización cuando se envian todos los bits
                    if (Config_mode || second_pack) state <= START; //Pasa de largo si se esta configurando o ya envio el segundo paquete
                    else state <= SECOND_START; 
                end
                else state <= SENDING_DATA;
            end

            SLAVE_NOT_READY :state <= LOAD; // Dado que no se peude parar el envio a la mitad y luego continuarlo es necesario volver a cargar el dato desde cero

            SECOND_START: begin
                    if (init) state <= SECOND_LD; // Es necesario volver a esperar el init ya que sin esto no se puede bajar el cs para poder separar los paquetes
                    else state <= SECOND_START; // si no se esta configurando se espera un nuevo init para poder enviar la segunda parte del data tx
            end
            SECOND_LD: begin 
                state <= SENDING_DATA;
                second_pack <= 1;
            end
            default:
                state <= START;
        endcase
   end
end

always @(*) begin
    case (state)
        START: begin
            dn = 1; ld = 0; stop = 0; scnd_ld = 0; frst_done = 0;
        end
        LOAD: begin
            dn = 0; ld = 1; stop = 0; scnd_ld = 0; frst_done = 0;
        end
        SLAVE_NOT_READY:begin
            dn = 0; ld = 0; stop = 1; scnd_ld = 0; frst_done = 0;
        end
        //estos estados de abajo son para poder leer data tx entero cuando ya no se esta configurando
        SECOND_START: begin
            dn = 0; ld = 0; stop = 1; scnd_ld = 0; frst_done = 1;
        end
        SECOND_LD:begin
            dn = 0; ld = 0; stop = 0; scnd_ld = 1; frst_done = 0; 
        end
        default:begin
            ld = 0; dn = 0; stop = 0; scnd_ld = 0; frst_done = 0;
        end
    endcase
end

`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(state)
    START           : state_name = "START";
    LOAD            : state_name = "LOAD";
    SLAVE_NOT_READY : state_name = "WAIT";
    SENDING_DATA    : state_name = "SENDING_DATA";
    SECOND_LD       : state_name = "SECOND_LD";
    SECOND_START    : state_name = "SECOND_START";
  endcase
end
`endif
endmodule


