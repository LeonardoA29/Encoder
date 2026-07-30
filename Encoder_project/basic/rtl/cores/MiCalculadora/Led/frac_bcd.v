module frac_bcd #(parameter divider = 20)
(
    input clk,
    input reset,
    input init,
    input transmision_done,
    input [31:0] in_Bcd,
    output [3:0] nibble,
    output init_send,
    output STB,
    output done
);

wire w_ld;
wire w_ld_nb;
wire w_sh;
wire w_sd;
wire w_z;
wire w_w;

data_path_frac #(.divider(divider))data_path0(.clk(clk),.reset(reset),.ld(w_ld),.ld_nb(w_ld_nb),
                     .sd(w_sd),.sh(w_sh),.in_Bcd(in_Bcd),.nibble(nibble),
                     .init_send(init_send),.STB(STB),.z(w_z),.w(w_w));

Control_frac Control0(.clk(clk),.reset(reset),.init(init),.z(w_z),.w(w_w),
                 .transmision_done(transmision_done),.dn(done),.ld(w_ld),.ld_nb(w_ld_nb),
                 .sh(w_sh),.sd(w_sd));


endmodule
/*
Este módulo se encarga de enviar los datos a la pantalla 7 segmentos de forma ordenada,
de manera que primero se envía el nibble de configuración, luego el nibble de comando y
finalmente los 8 nibbles de datos.

Es necesatio resetear la dirección de escritura de la pantalla 7 segmentos ,
 esto se hace enviando el nibble de configuración.

 Este modulo tambien se encarga de manejar el STB, el cual funciona como indicador de 
 que el dato es comando o dato, STB = 1 (COMANDO), STB = 0 (DATO). 

 El nibble que se quiere enviar no va directamente al modulo Com,sino que priemro se pasa por
 el modulo bcd_siete_seg, el cual se encarga de convertir el nibble en siete segmentos.
*/
//DATA_PATH
module data_path_frac #(parameter divider = 20)
(
    input           clk,
    input           reset,
    input           ld,
    input           ld_nb,
    input           sd,
    input           sh,

    input           [31:0]in_Bcd,
    output          reg[3:0]nibble,
    output          reg init_send,
    output          reg STB,
    output          reg z,
    output          reg w
);

reg[31:0] bcd;
reg[2:0] config_cnt;
reg[7:0] delay;
reg[4:0] sh_cnt;

always @(negedge clk or posedge reset) begin
    if (reset)begin
        bcd <= 32'h0;
        nibble <=0;
        init_send <= 0; 
        sh_cnt <= 8;
        STB <= 1;
        config_cnt <= 4;
        delay <= divider;
    end
    else begin
        if (delay) delay = delay - 1;
        else begin
            if (ld) begin
                bcd <= in_Bcd;
                config_cnt <= 4;
                sh_cnt <= 8;
                delay <= 0;
            end
            else if (ld_nb)begin

                case (config_cnt)
                    4: begin
                        nibble <= 4'hC;
                        STB <= 1;
                    end
                    3: begin
                        nibble <= 4'hA;
                        STB <= 1;
                    end
                    2: begin 
                        nibble = 4'hB;
                        STB <= 1;
                    end 
                    1: begin 
                        nibble <= bcd[31:28];
                        STB <= 0;
                    end
                    0: begin 
                        nibble <= 4'hF;
                        STB <= 0;
                    end
                    default: ;
                endcase
                delay <= divider;

            end
            else if (sd) begin 
                init_send <= 1;
                STB <= 0;
            end
            else if (sh)begin
                if (config_cnt == 0) begin 
                    bcd <= bcd << 4;
                    if (sh_cnt != 0) sh_cnt <= sh_cnt - 1;
                    config_cnt <= 1;
                end
                else config_cnt <= config_cnt - 1;
            end
            else begin
                if (sh_cnt == 0) STB <= 1'b1;
                init_send <= 1'b0;
            end
        end

    end
end
always @(*) begin
    z <= sh_cnt == 0? 1:0;
    w <= delay != 0? 1:0;
end
endmodule
//MÁQUINA DE CONTROL

/*
Este es la maquina de control que se encarga en manipular los estados del modulo data_path_frac,
de manera que se envíen los datos a la pantalla 7 segmentos de forma ordenada.
Estados posibles:
START: Estado inicial, espera a que se active la señal init para pasar al estado LOAD.
LOAD: Carga el valor de in_Bcd en el registro bcd y pasa al estado LOAD_NB.
LOAD_NB: Carga el nibble de configuración, comando o dato dependiendo del valor de config_cnt,
si config_cnt es 0 pasa al estado START, si no pasa al estado SEND.
SEND: Activa la señal init_send para enviar el nibble a la pantalla
WAIT: Espera a que transmision_done se active para pasar al estado SHIFT.
SHIFT: Desplaza el registro bcd 4 bits a la izquierda y decrementa sh_cnt,
 si sh_cnt es 0 se termina la transmisión poniendo STB = 1 y apaga la señal init_send, 
 si no pasa al estado LOAD_NB.
*/
module Control_frac(
    input       clk,
    input       reset,
    input       init,
    input       z,
    input       w,
    input       transmision_done,

    output reg   dn,
    output reg   ld,
    output reg   ld_nb,
    output reg   sh,
    output reg   sd
);
      			
parameter START = 3'b000, LOAD = 3'b001, LOAD_NB = 3'b010,SHIFT = 3'b011,
          SEND = 3'b100,WAIT = 3'b101;
reg [2:0] state;

always @(posedge clk or posedge reset) begin
    if (reset) state <= LOAD_NB;
    else begin 
        case (state)
            START:
                begin
                    if (init) state <= LOAD;
                    else state <= START; 
                end
            LOAD:state <= LOAD_NB;
            LOAD_NB:
                begin
                    if (w) state <= LOAD_NB;
                    else begin
                        if (z) state <= START;
                        else state <= SEND;
                    end
                end
            SEND:state = WAIT;
            WAIT:
                begin
                    if (transmision_done) state <= SHIFT;
                    else state <= WAIT;  
                end
            SHIFT:state <= LOAD_NB;  
            default:state <= START;
        endcase
   end
end

always @(*) begin
    if (reset)begin
        sh = 0; ld = 0; ld_nb = 0; sd = 0; dn = 1;
    end
    else begin
        case (state)
            START: begin     
                sh = 0; ld = 0; ld_nb = 0; sd = 0; dn = 1;
            end
            LOAD: begin
                sh = 0; ld = 1; ld_nb = 0; sd = 0; dn = 0;
            end
            LOAD_NB: begin
                sh = 0; ld = 0; ld_nb = 1; sd = 0; dn = 0;
            end
            SHIFT: begin 
                sh = 1; ld = 0; ld_nb = 0; sd = 0; dn = 0;
            end  
            SEND: begin
                sh = 0; ld = 0; ld_nb = 0; sd = 1; dn = 0;
            end
            WAIT: begin
                sh = 0; ld = 0; ld_nb = 0; sd = 0; dn = 0;
            end
            default:begin
                sh = 0; ld = 0; ld_nb = 0; sd = 0; dn = 0;
            end
        endcase
    end
end
`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(state)
    START    : state_name = "START";
    LOAD     : state_name = "LOAD";
    SHIFT    : state_name = "SHIFT";
    LOAD_NB    : state_name = "LOAD_NB";
    SEND    : state_name = "SEND";
    WAIT    : state_name = "WAIT";
  endcase
end
`endif
endmodule

