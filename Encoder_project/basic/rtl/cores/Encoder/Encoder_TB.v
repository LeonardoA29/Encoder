`timescale 1ns/1ps

module Encoder_tb;

    localparam CLK_PERIOD = 10; // 100 MHz

    // -----------------------------------------------------------------
    // Señales de conexión con el DUT
    // -----------------------------------------------------------------
    reg clk;
    reg reset;
    reg sampler_init;
    reg module_init;
    reg  [11:0] x_in;
    reg  [11:0] y_in;

    wire signed [13:0] angle_out;
    wire [15:0] Speed_out;
    wire clk_adc_A;
    wire clk_adc_B;
    wire sampler_done;

    // -----------------------------------------------------------------
    // Control interno del testbench
    // -----------------------------------------------------------------
    integer rot_index; // índice 0..5 dentro de la LUT de 60°
    integer rot_count; // rotaciones (pasos de 60°) realizadas

    // LUT para magnitud constante = 2048, pasos de 60°
    // (valores clampeados a rango signed de 12 bits: -2048..2047)
    reg signed [11:0] x_lut [0:5];
    reg signed [11:0] y_lut [0:5];

    initial begin
        x_lut[0] =  2047; y_lut[0] =     0; //   0°
        x_lut[1] =  1024; y_lut[1] =  1775; //  60°
        x_lut[2] = -1024; y_lut[2] =  1775; // 120°
        x_lut[3] = -2048; y_lut[3] =     0; // 180°
        x_lut[4] = -1024; y_lut[4] = -1775; // 240°
        x_lut[5] =  1024; y_lut[5] = -1775; // 300°
    end

    // -----------------------------------------------------------------
    // DUT
    // -----------------------------------------------------------------
    Encoder DUT (
        .clk(clk),
        .reset(reset),
        .sampler_init(sampler_init),
        .module_init(module_init),

        // Se conecta cada pin individual del ADC al bit correspondiente
        // del bus interno x_in/y_in del testbench (x_in[11] = MSB, x_in[0] = LSB)
        .x_in_11(x_in[11]), .x_in_10(x_in[10]), .x_in_9(x_in[9]), .x_in_8(x_in[8]),
        .x_in_7(x_in[7]),   .x_in_6(x_in[6]),   .x_in_5(x_in[5]), .x_in_4(x_in[4]),
        .x_in_3(x_in[3]),   .x_in_2(x_in[2]),   .x_in_1(x_in[1]), .x_in_0(x_in[0]),

        .y_in_11(y_in[11]), .y_in_10(y_in[10]), .y_in_9(y_in[9]), .y_in_8(y_in[8]),
        .y_in_7(y_in[7]),   .y_in_6(y_in[6]),   .y_in_5(y_in[5]), .y_in_4(y_in[4]),
        .y_in_3(y_in[3]),   .y_in_2(y_in[2]),   .y_in_1(y_in[1]), .y_in_0(y_in[0]),

        .angle_out(angle_out),
        .Speed_out(Speed_out),
        .clk_adc_A(clk_adc_A),
        .clk_adc_B(clk_adc_B),
        .sampler_done(sampler_done)
    );

    // -----------------------------------------------------------------
    // Reloj principal del sistema
    // -----------------------------------------------------------------
    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // -----------------------------------------------------------------
    // Actualización de x_in / y_in en cada flanco positivo de clk_adc
    // (simula la entrega de datos de los 2 ADCs)
    // -----------------------------------------------------------------
    always @(posedge clk_adc_B) begin
        if (module_init) begin
            rot_index = (rot_index + 1) % 6;
            x_in = x_lut[rot_index];
            y_in = y_lut[rot_index];
            rot_count = rot_count + 1;
            $display("[%0t] clk_adc posedge -> rot_count=%0d rot_index=%0d x_in=%0d y_in=%0d",
                       $time, rot_count, rot_index, x_in, y_in);
        end
    end

    // -----------------------------------------------------------------
    // Disparo de sampler_init tras la rotación 15
    // (pulso de 1 ciclo, baja, espera 4 ciclos, y otro pulso)
    // -----------------------------------------------------------------
    initial begin
        sampler_init = 1'b0;
        wait (rot_count == 15);
        @(posedge clk);
        sampler_init = 1'b1;
        $display("[%0t] Primer pulso de sampler_init", $time);
        @(posedge clk);
        sampler_init = 1'b0;

        repeat (4) @(posedge clk);

        @(posedge clk);
        sampler_init = 1'b1;
        $display("[%0t] Segundo pulso de sampler_init", $time);
        @(posedge clk);
        sampler_init = 1'b0;
    end

    // -----------------------------------------------------------------
    // Secuencia principal de estímulos
    // -----------------------------------------------------------------
    initial begin
        // Valores iniciales
        reset        = 1'b1;
        module_init  = 1'b0;
        x_in         = 12'sd0;
        y_in         = 12'sd0;
        rot_index    = 0;
        rot_count    = 0;

        // 1) Reset
        repeat (5) @(posedge clk);
        reset = 1'b0;
        repeat (5) @(posedge clk);
        $display("[%0t] Reset liberado", $time);

        // 2) Enviar datos x/y SIN inicializar el módulo (module_init = 0)
        $display("[%0t] Enviando datos x/y sin module_init activo (deben ser ignorados)", $time);
        x_in = x_lut[0]; y_in = y_lut[0];
        repeat (3) @(posedge clk);
        x_in = x_lut[1]; y_in = y_lut[1];
        repeat (3) @(posedge clk);
        x_in = x_lut[2]; y_in = y_lut[2];
        repeat (3) @(posedge clk);

        // 3) Activar module_init y comenzar la rotación real del vector
        $display("[%0t] Activando module_init: comienza rotacion de vector (mag=2048, paso=60deg)", $time);
        rot_index   = 0;
        rot_count   = 0;
        x_in        = x_lut[0];
        y_in        = y_lut[0];
        module_init = 1'b1;

        // El bloque always @(posedge clk_adc) se encarga de ir
        // actualizando x_in/y_in y de contar las rotaciones.
        // Esperamos aquí a que se completen las ~20 rotaciones de 60°.
        wait (rot_count >= 40);
        $display("[%0t] Se completaron %0d rotaciones de 60 grados", $time, rot_count);

        repeat (5) @(posedge clk);

        // 5) Apagar el módulo
        module_init = 1'b0;
        $display("[%0t] module_init desactivado: apagando el modulo", $time);
        repeat (10) @(posedge clk);

        $display("[%0t] Fin de la simulacion", $time);
        $finish;
    end

    // -----------------------------------------------------------------
    // Monitor / dump de forma de onda
    // -----------------------------------------------------------------
    initial begin
        $dumpfile("Encoder_TB.vcd");
        $dumpvars(0, Encoder_tb);
    end

    initial begin
        $monitor("[%0t] reset=%b module_init=%b sampler_init=%b clk_adc=%b x_in=%0d y_in=%0d angle_out=%0d Speed_out=%0d sampler_done=%b",
                  $time, reset, module_init, sampler_init, clk_adc_B, x_in, y_in, angle_out, Speed_out, sampler_done);
    end

endmodule
