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
reg [6:0] s;             // Selector de registro (decodificador de direcciones)
reg sampler_init;        // Registro de entrada: inicio de muestreo
reg module_init;         // Registro de entrada: inicio de modulo
reg [11:0] test_x_in;
reg [11:0] test_y_in;

wire signed [13:0] angle_out;  // Salida de angulo del encoder
wire signed [13:0] Speed_out;         // Salida de velocidad del encoder
wire sampler_done;             // Flag de finalizacion de muestreo

//------------------------------------ Decodificador de Direcciones ------------------
// 0x04: SAMPLER_INIT  (Escritura)
// 0x08: MODULE_INIT   (Escritura)
// 0x0C: SAMPLER_DONE  (Lectura)
// 0x10: ANGLE_OUT     (Lectura)
// 0x14: SPEED_OUT     (Lectura)
always @(*) begin
    case (addr)
        8'h04: begin s = (cs) ? 7'b0000001 : 7'b0000000; end // SAMPLER_INIT
        8'h08: begin s = (cs) ? 7'b0000010 : 7'b0000000; end // MODULE_INIT
        8'h0C: begin s = (cs) ? 7'b0000100 : 7'b0000000; end // SAMPLER_DONE
        8'h10: begin s = (cs) ? 7'b0001000 : 7'b0000000; end // ANGLE_OUT
        8'h14: begin s = (cs) ? 7'b0010000 : 7'b0000000; end // SPEED_OUT
        8'h18: begin s = (cs) ? 7'b0100000 : 7'b0000000; end // Test_x_in
        8'h1C: begin s = (cs) ? 7'b1000000 : 7'b0000000; end // Test_y_in
        default: begin s = 7'b0000000; end
    endcase
end

//------------------------------------ Registros de Entrada --------------------------
always @(posedge clk) begin
    sampler_init <= (s[0] & wr) ? d_in[0] : sampler_init;
    module_init  <= (s[1] & wr) ? d_in[0] : module_init;
    test_x_in  <= (s[5] & wr) ? d_in[11:0] : test_x_in;
    test_y_in  <= (s[6] & wr) ? d_in[11:0] : test_y_in;
end

//------------------------------------ Registros de Salida ---------------------------
always @(posedge clk) begin
    case (s)
        7'b0000100: d_out <= {31'b0, sampler_done};
        7'b0001000: d_out <= {18'b0, angle_out};
        7'b0010000: d_out <= {18'b0, Speed_out};
        default:  d_out <= 32'b0;
    endcase
end

//------------------------------------ Instancia del Core Encoder --------------------
Encoder Enc0 (
    .clk(clk),
    .reset(reset),
    .sampler_init(sampler_init),
    .module_init(module_init),
    .test_x_in(test_x_in),
    .test_y_in(test_y_in),

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