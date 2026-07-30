module peripheral_Encoder(
    input  clk,
    input  reset,
    input  [31:0] d_in,
    input  rd,
    input  wr,
    input  cs,
    input  [6:0] addr,
    output reg [31:0] d_out,

    // Entradas del ADC canal X (12 bits en paralelo)
    input x_in_11,
    input x_in_10,
    input x_in_9,
    input x_in_8,
    input x_in_7,
    input x_in_6,
    input x_in_5,
    input x_in_4,
    input x_in_3,
    input x_in_2,
    input x_in_1,
    input x_in_0,

    // Entradas del ADC canal Y (12 bits en paralelo)
    input y_in_11,
    input y_in_10,
    input y_in_9,
    input y_in_8,
    input y_in_7,
    input y_in_6,
    input y_in_5,
    input y_in_4,
    input y_in_3,
    input y_in_2,
    input y_in_1,
    input y_in_0,

    // Salidas de reloj para ADCs
    output clk_adc_A,
    output clk_adc_B
);

//------------------------------------ Regs y Wires -------------------------------
reg [4:0] s;             // Selector de registro (decodificador de direcciones)
reg sampler_init;        // Registro de entrada: inicio de muestreo
reg module_init;         // Registro de entrada: inicio de modulo

wire signed [13:0] angle_out;  // Salida de angulo del encoder
wire [15:0] Speed_out;         // Salida de velocidad del encoder
wire sampler_done;             // Flag de finalizacion de muestreo

//------------------------------------ Decodificador de Direcciones ------------------
// 0x04: SAMPLER_INIT  (Escritura)
// 0x08: MODULE_INIT   (Escritura)
// 0x0C: SAMPLER_DONE  (Lectura)
// 0x10: ANGLE_OUT     (Lectura)
// 0x14: SPEED_OUT     (Lectura)
always @(*) begin
    case (addr)
        8'h04: begin s = (cs) ? 5'b00001 : 5'b00000; end // SAMPLER_INIT
        8'h08: begin s = (cs) ? 5'b00010 : 5'b00000; end // MODULE_INIT
        8'h0C: begin s = (cs) ? 5'b00100 : 5'b00000; end // SAMPLER_DONE
        8'h10: begin s = (cs) ? 5'b01000 : 5'b00000; end // ANGLE_OUT
        8'h14: begin s = (cs) ? 5'b10000 : 5'b00000; end // SPEED_OUT
        default: begin s = 5'b00000; end
    endcase
end

//------------------------------------ Registros de Entrada --------------------------
always @(posedge clk) begin
    sampler_init <= (s[0] & wr) ? d_in[0] : sampler_init;
    module_init  <= (s[1] & wr) ? d_in[0] : module_init;
end

//------------------------------------ Registros de Salida ---------------------------
always @(posedge clk) begin
    case (s)
        5'b00100: d_out <= {31'b0, sampler_done};
        5'b01000: d_out <= {18'b0, angle_out};
        5'b10000: d_out <= {16'b0, Speed_out};
        default:  d_out <= 32'b0;
    endcase
end

//------------------------------------ Instancia del Core Encoder --------------------
Encoder Enc0 (
    .clk(clk),
    .reset(reset),
    .sampler_init(sampler_init),
    .module_init(module_init),

    .x_in_11(x_in_11), .x_in_10(x_in_10), .x_in_9(x_in_9), .x_in_8(x_in_8),
    .x_in_7(x_in_7),   .x_in_6(x_in_6),   .x_in_5(x_in_5), .x_in_4(x_in_4),
    .x_in_3(x_in_3),   .x_in_2(x_in_2),   .x_in_1(x_in_1), .x_in_0(x_in_0),

    .y_in_11(y_in_11), .y_in_10(y_in_10), .y_in_9(y_in_9), .y_in_8(y_in_8),
    .y_in_7(y_in_7),   .y_in_6(y_in_6),   .y_in_5(y_in_5), .y_in_4(y_in_4),
    .y_in_3(y_in_3),   .y_in_2(y_in_2),   .y_in_1(y_in_1), .y_in_0(y_in_0),

    .angle_out(angle_out),
    .Speed_out(Speed_out),
    .clk_adc_A(clk_adc_A),
    .clk_adc_B(clk_adc_B),
    .sampler_done(sampler_done)
);

endmodule