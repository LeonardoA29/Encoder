/*
Modulo secuencial que convierte un nibble de 4 bits en un byte de 8 bits
para ser enviado a la pantalla 7 segmentos.

No solo se pasan números sino tambein comandos, estos se envían en el mismo formato que los números,
es decir, en 8 bits, pero con un valor diferente al de los números.
Si se quisieran modificar los comandos, se puede hacer en este modulo, ya que
es el encargado de convertir el nibble en 8 bits.
*/
module bcd_siete_seg(
    input wire[3:0] nibble,
    output reg [7:0] out_siete_seg
);
always @(*) begin
    case (nibble)
        4'h0:out_siete_seg = 8'b00111111;
        4'h1:out_siete_seg = 8'b00000110;
        4'h2:out_siete_seg = 8'b01011011; 
        4'h3:out_siete_seg = 8'b01001111;
        4'h4:out_siete_seg = 8'b01100110;
        4'h5:out_siete_seg = 8'b01101101;
        4'h6:out_siete_seg = 8'b01111101;
        4'h7:out_siete_seg = 8'b00000111;
        4'h8:out_siete_seg = 8'b01111111;
        4'h9:out_siete_seg = 8'b01101111;
        4'hA:out_siete_seg = 8'b01000000;//send_data_auto_norm_cmd
        4'hB:out_siete_seg = 8'b11000000;//set_display_Addr_0
        4'hC:out_siete_seg = 8'b10001111;//max Brightness-display ON
        default: out_siete_seg = 8'b00000000;
    endcase
end

endmodule