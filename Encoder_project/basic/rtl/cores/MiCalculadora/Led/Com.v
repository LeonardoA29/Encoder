module Com #(parameter divider = 20)
(
    input clk,
    input reset,
    input init,
    input [7:0]data_cmd,
    output DIO,
    output clk_com,
    output done
);

wire w_sh;
wire w_sd;
wire w_ld;
wire w_z;
wire w_clk_com_div;

clk_div #(.divider(divider)) clk_div0(.clk(clk),.reset(reset),.init(init),.z(w_z),
          .clk_com(clk_com),.clk_com_div(w_clk_com_div));

Control_Com Control0(.clk(clk),.clk_com(clk_com),.reset(reset),.init(init),.z(w_z),
                     .dn(done),.ld(w_ld),.sh(w_sh),.sd(w_sd));

data_path_Com data_path0(.clk_com_div(w_clk_com_div),.ld(w_ld),.sh(w_sh),.sd(w_sd),
                         .dn(done),.reset(reset),.data_cmd(data_cmd),.DIO(DIO),.z(w_z));
    
endmodule
/*
Este modulo se encarga de enviar un dato 8 bits a la pantalla 7 segmentos.

*/

module data_path_Com(
    input clk_com_div,
    input ld,
    input sh,
    input sd,
    input dn,
    input reset,
    input [7:0]data_cmd,
    output reg DIO,
    output reg z
);
reg [7:0]data_to_send; 
reg [3:0]sh_cnt;

always @(posedge clk_com_div or posedge reset) begin
    if (reset)begin
        data_to_send = 0;
        DIO = 0;
        sh_cnt = 0;
    end 
    else if (ld) begin
        DIO = data_cmd[0];
        data_to_send = data_cmd;
        sh_cnt = 8;
    end
    else if (sh) begin 
        data_to_send = data_to_send >> 1;
        sh_cnt = sh_cnt - 1;
    end 
    else if (sd) begin
        DIO = data_to_send[0];
    end
    else if(dn) DIO = 0;
    
end

always @(*) begin
    z = sh_cnt == 0? 1:0; 
end
    
endmodule
/*
Reloj de la pantalla 7 segementos, este modulo divide el reloj del sistema por un factor
dato por el paramatro divider, el cual es de 20 por defecto. Otra cosa a atener en cuenta
es que el no solo se genera el reloj de la pantalla sino que tambien se genera un reloj
a la mitad de la frecuencia del reloj de la pantalla, esto es necesario para el envio de datos
a la pantalla, ya que el envio de datos se hace en la mitad del periodo del reloj de la pantalla,
 es decir, cuando el reloj de la pantalla esta en 0.
 Por último es necesario ver que este reloj solo funciona cuando se esta enviando datos a la pantalla,
  es decir, cuando init = 1 o z = 0.
*/

module clk_div #(
    parameter divider = 20
) (
    input clk,
    input reset,
    input init,
    input z,
    output reg clk_com,
    output reg clk_com_div

);
reg [7:0]div_cnt;
parameter divider_2 = divider/2;

always @(posedge clk or posedge reset) begin
    if (reset)begin
        clk_com = 0;
        div_cnt = 0;
        clk_com_div = 0;
    end
    else if (init || !z || div_cnt != divider) begin
        if (div_cnt == divider)begin
            div_cnt = 0;
            clk_com = ~clk_com;
            clk_com_div = ~clk_com_div;
        end
        else if (div_cnt == divider_2) clk_com_div = ~clk_com_div;
        div_cnt = div_cnt + 1;
    end
    else begin
        div_cnt = 0;
        clk_com = 0;
        clk_com_div = 0;
    end
end 
endmodule

//MAQUINA DE CONTROL

/*
Máquina de control para la pantalla 7 segmentos 
Posible estados: START, LOAD, SHIFT, SEND
START: Estado inicial, espera a que se active la señal init para pasar al estado LOAD.
LOAD: Carga el valor de data_cmd en el registro data_to_send y pasa al estado SHIFT.
SHIFT: Desplaza el registro data_to_send 1 bit a la derecha y decrementa sh_cnt,
si sh_cnt es 0 se termina la transmisión poniendo dn = 1 y apaga la señal sd, si no pasa al estado SEND.
SEND: Activa la señal sd para enviar el bit menos significativo de data_to_send a la
pantalla, y pasa al estado SHIFT.
*/
module Control_Com(
    input       clk,
    input       clk_com,
    input       reset,
    input       init,
    input       z,

    output reg   dn,
    output reg   ld,
    output reg   sh,
    output reg   sd
);
      			
parameter START = 2'b00, LOAD = 2'b01,SHIFT = 2'b10,SEND = 2'b11;
reg [1:0] state;

always @(negedge clk or  posedge reset) begin
    if (reset) state = START;
    else begin 
        case (state)
            START:
                begin
                    if (init) state = LOAD;
                    else state = START; 
                end
            LOAD:begin
                if (clk_com) state = SHIFT;
                else state = LOAD;
            end
            SEND:begin
                if (clk_com) state = SHIFT;
                else state = SEND;
            end
            SHIFT:begin
                if (z && !clk_com) state = START;
                else if (!clk_com) state = SEND;
                else state = SHIFT;  
            end
            default:state = START;
        endcase
   end
end

always @(*) begin
    case (state)
        START: begin     
            sh = 0; ld = 0; sd = 0; dn = 1;
        end
        LOAD: begin
            sh = 0; ld = 1; sd = 0; dn = 0;
        end
        SHIFT: begin 
            sh = 1; ld = 0; sd = 0; dn = 0;
        end  
        SEND: begin
            sh = 0; ld = 0; sd = 1; dn = 0;
        end
    endcase
end
`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(state)
    START    : state_name = "START";
    LOAD     : state_name = "LOAD";
    SHIFT    : state_name = "SHIFT";
    SEND    : state_name = "SEND";
  endcase
end
`endif
endmodule

