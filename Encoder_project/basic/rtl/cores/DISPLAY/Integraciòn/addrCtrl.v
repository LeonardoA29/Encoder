//------------------------------------------------------------mòdulo principal -------------------------------------------------------//
module addrCtrl #(
    parameter slowing_factor = 30)
(
    input reset,
    input clk,
    input init,
    input spiDone,
    input DC_input,
    input frst_done,

    output wire[11:0] adrB,
    output DC,
    output displayCS,
    output SPI_init,
    output done,
    output delay,
    output configState,
    output displayReset);

assign w_dn = done;
assign w_delay = delay;
assign w_configState =  configState ;

wire w_frFinshed;
wire w_configState;
wire w_delay;
wire w_sd;  
wire w_ld;
wire w_sh;
wire w_dn;

DC DC0(.clk(clk),
       .reset(reset),
       .sd(w_sd),
       .dn(w_dn),
       .spiDone(spiDone),
       .frst_done(frst_done),
       .configState(w_configState),
       .DC_input(DC_input),
       .delay(w_delay),
       .DC(DC),
       .SPI_init(SPI_init),
       .displayCS(displayCS));

addr addr0(.clk(clk),
           .reset(reset),
           .sh(w_sh),
           .ld(w_ld),
           .spiDone(spiDone),
           .frameFinished(w_frFinshed),
           .configState(configState),
           .address(adrB),
           .delay(delay));

control_addr #(.slowing_factor(slowing_factor))
    control_addr0 (.reset(reset),
                            .displayReset(displayReset),
                            .clk(clk),
                            .init(init),
                            .frameFinished(w_frFinshed),
                            .spiDone(spiDone),
                            .delay(w_delay),
                            .frst_done(frst_done),
                            .dn(done),
                            .sh(w_sh),
                            .ld(w_ld),
                            .sd(w_sd)); 
    
endmodule
//-----------------------------------------------------------mòdulo de envìo---------------------------------------------------------//
module DC(
    input clk,
    input reset,
    input sd,
    input dn,
    input spiDone,
    input frst_done,
    input configState,
    input DC_input,
    input delay,
    output reg DC,
    output reg SPI_init,
    output reg displayCS
); 

    always @(negedge clk or posedge reset) begin
        if (reset)begin
            DC <= 0;
            displayCS <= 1;
            SPI_init <= 0; 
        end
        else begin
            if (sd) begin

                if (configState) DC <= DC_input;
                else DC <= 1;

                displayCS <= 0;
                SPI_init <= 1;
            end
            else if (dn || frst_done || spiDone) begin
                displayCS <= 1;
                SPI_init <= 0;
            end 
            else SPI_init <= 0;
        end
    end
    
endmodule

//-----------------------------------------------------------control de direccionamiento-------------------------------------------------//

module addr(
    input clk,
    input reset,
    input sh,
    input ld,
    input spiDone,

    output frameFinished,
    output reg configState,
    output reg[11:0]address,
    output reg delay
);


reg[4:0] pointerResets;
localparam CONFIG_END_ADDR = 44;  // 67 para pantalla lcd , 44 para e paper

// Calculos parametricos dependiendo de la pantalla y el tamaño de la memoria
parameter total_frame_bits = 250 * 128 * 2;
localparam Memory_cells = 4096; 
localparam cell_size = 16;
localparam bits_of_mem = (Memory_cells -  CONFIG_END_ADDR)* cell_size ;
localparam required_full_memories = total_frame_bits / bits_of_mem;
localparam end_bits =  total_frame_bits - required_full_memories*(Memory_cells -  CONFIG_END_ADDR);
localparam end_address = CONFIG_END_ADDR + end_bits/cell_size;
localparam end_address_with_ending_cmds = end_address + 5;
//

localparam st_address1 = 3, st_address2 = 42; // direcciones en donde debe de haber un delay antes de enviarlas

assign frameFinished = pointerResets == required_full_memories && address == end_address_with_ending_cmds? 1:0;

always @(negedge clk) begin
    if (reset)begin
        address <= 0;// cuando se resetea se vuelven a escribir los comandos de configuración
        pointerResets <= 0;
    end
    else if (ld) begin
        address <= CONFIG_END_ADDR - 1 ; // solo se envía el comando para empazar a enviar datos
        pointerResets <= 0;
    end
    else if (sh) begin
        if (address < end_address_with_ending_cmds) address <= address + 1;
        else begin
            pointerResets <= pointerResets + 1;
            address <= CONFIG_END_ADDR;
        end
    end
    if(spiDone) configState = (pointerResets == 0 && address < CONFIG_END_ADDR )|| address > end_address? 1:0;

end
always @(*) begin
    delay = address == st_address1 ||  address == st_address2 ? 1:0; // activa el delay para antes de enviar estas direcciones
end
endmodule

//------------------------------------------------------------mòdulo control ---------------------------------------------------------//

module control_addr #(
    parameter slowing_factor = 30)
    (
	input reset,
	input clk,            
	input init,
    input frameFinished,
    input spiDone,
    input delay,
    input frst_done,

	output reg dn, 
    output reg sh,
    output reg ld,
    output reg sd,
    output reg displayReset);     
    			
parameter START = 3'b000, LOAD = 3'b001, START_SPI = 3'b010,SHIFT_ADDR = 3'b011, WAIT = 3'b100 , DELAY = 3'b101, CONFIGURE_LD = 3'b110, START_SPI_2 = 3'b111;
reg [2:0] state;

reg [28:0] delay_cnt;
parameter delay_time = 300;   //3000000 -> para 12 ms


always @(posedge clk) begin
    if (reset) begin
        state <= CONFIGURE_LD; // Este estado es necesario para evitar que se envie la dirección si el reset cae despues que el modulo controlado lo lee (negedge)
        delay_cnt <= 0;
        displayReset <= 1;
    end
    else begin 
    displayReset <= 0;
    case (state)
        START:begin
            if (init) state <= LOAD;
            else state <= START;
        end   
        LOAD: state <= START_SPI;

        START_SPI: state <= SHIFT_ADDR;

        SHIFT_ADDR: state <= WAIT;
            
        WAIT:begin
            if (spiDone || frst_done)begin
                if (frameFinished) state <= START;
                else begin
                    if (delay) delay_cnt <= delay_time;//Este es para algun retraso especial , como en la pantalla lcd despues de ciertos comandos
                    else delay_cnt = slowing_factor; // se deja medio cilo de reloj del spi_clk el cs en alto , debido a que se necesita cierto tiempo entre paquetes 
                    state <= DELAY;
                end
            end
            else state <= WAIT; 
        end

        START_SPI_2: state = WAIT;  // EN este estado se da el segundo init para utilizar los 16 bits de memoria por completo , una vez ya se ha configurado

        DELAY:begin
            if (delay_cnt) delay_cnt <= delay_cnt - 1;
            else begin
                if (spiDone)state <= START_SPI;
                else if (frst_done) state <= START_SPI_2;
            end
        end
        CONFIGURE_LD : state <= START_SPI;
        default:
            state <= START;
    endcase
   end
end

always @(*) begin
    case (state)

        START: begin     
            dn = 1; sh = 0; ld = 0; sd = 0;
        end

        LOAD: begin
            dn = 0; sh = 0; ld = 1; sd = 0;
        end

        START_SPI: begin
            dn = 0; sh = 0; ld = 0; sd = 1;
        end

        SHIFT_ADDR: begin 
            dn = 0; sh = 1; ld = 0; sd = 1;
        end
        START_SPI_2:begin
            dn = 0; sh = 0; ld = 0; sd = 1;
        end   
        default begin
            dn = 0; sh = 0; ld = 0; sd = 0;
        end

    endcase
end

`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(state)

    START    : state_name = "START";
    LOAD   : state_name = "LOAD";
    SHIFT_ADDR    : state_name = "SHIFT_ADDR";
    START_SPI    : state_name = "START_SPI";
    WAIT    : state_name = "WAIT";
    DELAY    : state_name = "DELAY";
    CONFIGURE_LD : state_name = "CONFIGURE_LD";

  endcase
end
`endif
endmodule


