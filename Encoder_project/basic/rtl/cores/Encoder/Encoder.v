module Encoder(
    input clk,
    input reset,
    input sampler_init,
    input module_init,

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

    output signed [13:0] angle_out,
    output signed [15:0] Speed_out,
    output clk_adc_A,
    output clk_adc_B,
    output sampler_done
);
// Formato de ángulos: Q9.3 (12 bits con signo, 1 LSB = 0.125)
// Formato de magnitud: Q11.0 con bit de signo (12 bits enteros)

// Bloque combinacional: arma los buses internos x_in / y_in
// a partir de las 12 entradas individuales de cada ADC.
// x_in_11 / y_in_11 se toman como el bit mas significativo (MSB).
wire [11:0] x_in;
wire [11:0] y_in;


assign clk_adc_A = clk_adc;
assign clk_adc_B = clk_adc;

assign x_in = {x_in_11, x_in_10, x_in_9, x_in_8, x_in_7, x_in_6,
               x_in_5,  x_in_4,  x_in_3, x_in_2, x_in_1, x_in_0};

assign y_in = {y_in_11, y_in_10, y_in_9, y_in_8, y_in_7, y_in_6,
               y_in_5,  y_in_4,  y_in_3, y_in_2, y_in_1, y_in_0};

wire signed [13:0] angle_out_cordic;
wire [12:0] amplitude_out_cordic;
wire signed [15:0] Speed_out_derivator;
wire w_sh;
wire w_calc;

reg clk_div;
reg [7:0] Cnt_div;
localparam Divider = 8'd10;

always @(posedge clk or posedge reset) begin

    if (reset)begin
        clk_div = 0;
        Cnt_div = 0;
    end else begin
        if (!Cnt_div)begin
            clk_div = ~clk_div;
            Cnt_div = Divider;
        end else begin
            Cnt_div = Cnt_div - 1;
        end      
    end  
end

Cordic Cordic0 (
    .clk(clk_div),
    .reset(reset),
    .calc(w_calc),
    .sh(w_sh),
    .x_in(x_in),
    .y_in(y_in),
    .angle_out(angle_out_cordic),
    .amplitude_out(amplitude_out_cordic)
);

Derivator Derivator0 (
    .clk(clk_div),
    .reset(reset),
    .calc(w_calc),
    .sh(w_sh),
    .Angle_in(angle_out_cordic),
    .Speed_out(Speed_out_derivator)
);

Control Control0 (
    .clk(clk_div),
    .reset(reset),
    .init(module_init),
    .calc(w_calc),
    .sh(w_sh),
    .clk_adc(clk_adc)
);
// assign angle_out =  angle_out_cordic;
// assign Speed_out = Speed_out_derivator;
assign angle_out =  Offset_y;
assign Speed_out = Offset_x;

reg signed [13:0] Offset_x;
reg signed [15:0] Offset_y;

always @(negedge clk or posedge reset) begin
    if (reset)begin
        offset_x <= 0;
        offset_y <= 0;
    end else begin
        Offset_x <= x_in - 11'd2048;
        Offset_y <= y_in - 11'd2048;
    end
end


// Sampler Sampler0 (
//     .clk(clk_div),
//     .reset(reset),
//     .init(sampler_init),
//     .angle_in(angle_out_cordic),
//     .Speed_in(Speed_out_derivator),
//     .angle_out(angle_out),
//     .Speed_out(Speed_out),
//     .done(sampler_done)
// );


endmodule
