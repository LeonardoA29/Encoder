module Derivator (
    input clk,
    input reset,
    input calc,
    input sh,
    input signed [13:0] Angle_in,
    output signed [15:0] Speed_out
);

wire [13:0] Angle_t1_wire;
wire [13:0] Angle_t2_wire;
wire [13:0] Angle_t3_wire;
wire [13:0] Angle_t4_wire;
wire [13:0] Angle_t5_wire;

Angular_speed_calc Angular_speed_calc0 (
    .clk(clk),
    .reset(reset),
    .calc(calc),
    .sh(sh),
    .Angle_t1(Angle_t1_wire),
    .Angle_t2(Angle_t2_wire),
    .Angle_t3(Angle_t3_wire),
    .Angle_t4(Angle_t4_wire),
    .Angle_t5(Angle_t5_wire),
    .Speed_out(Speed_out)
);

unwrap unwrap0(
    .clk(clk),
    .reset(reset),
    .calc(calc),
    .sh(sh),
    .Angle_in(Angle_in),
    .Angle_t1(Angle_t1_wire),
    .Angle_t2(Angle_t2_wire),
    .Angle_t3(Angle_t3_wire),
    .Angle_t4(Angle_t4_wire),
    .Angle_t5(Angle_t5_wire)
);
    
endmodule


module Angular_speed_calc(
    input clk,
    input reset,
    input calc,
    input sh,
    input signed [13:0] Angle_t1,
    input signed [13:0] Angle_t2,
    input signed [13:0] Angle_t3,
    input signed [13:0] Angle_t4,
    input signed [13:0] Angle_t5,
    output reg [15:0] Speed_out
);

reg [15:0] Speed_out_reg;  
reg [15:0] diff1;
reg [15:0] diff2; 

always @(negedge clk or posedge reset) begin
    if (reset) begin
        Speed_out <= 16'b0;
        diff1 <= 16'b0;
        diff2 <= 16'b0;
        Speed_out_reg <= 16'b0;
    end else begin
        if (calc) begin
            diff1 <= Angle_t1 - Angle_t5;
            diff2 <= Angle_t2 - Angle_t4;
            Speed_out <= Speed_out_reg;  
            Speed_out_reg <= (diff1 + (diff2<<1)) >> 3;
            
        end

    end
end
endmodule


module unwrap (
    input clk,
    input reset,
    input calc,
    input sh,
    input signed [13:0] Angle_in,

    output signed [13:0] Angle_t1,
    output signed [13:0] Angle_t2,
    output signed [13:0] Angle_t3,
    output signed [13:0] Angle_t4,
    output signed [13:0] Angle_t5
);

reg signed [13:0] angle_reg1;
reg signed [13:0] angle_reg2;
reg signed [13:0] angle_reg3;
reg signed [13:0] angle_reg4;
reg signed [13:0] angle_reg5;

reg signed [13:0] offset;

// delta y delta_abs son ahora COMBINACIONALES (no registrados), asi
// siempre reflejan angle_reg1 (valor previo) vs Angle_in (valor recien
// calculado por el Cordic), disponibles sin esperar un flanco extra.
wire signed [13:0] delta     = angle_reg1 - Angle_in;
wire signed [13:0] delta_abs = delta[13] ? (~delta + 1'b1) : delta;

assign Angle_t1 = angle_reg1;
assign Angle_t2 = angle_reg2 + offset;
assign Angle_t3 = angle_reg3 + offset;
assign Angle_t4 = angle_reg4 + offset;
assign Angle_t5 = angle_reg5 + offset;


always @(negedge clk or posedge reset) begin

    if(reset) begin
        angle_reg1 <= 0;
        angle_reg2 <= 0;
        angle_reg3 <= 0;
        angle_reg4 <= 0;
        angle_reg5 <= 0;
        offset <= 0;
    end
    else begin
        if (sh) begin
            // delta / delta_abs ya estan "frescos" (combinacionales),
            // se pueden usar de inmediato, en el mismo ciclo.
            if (delta[12])begin
                if(delta_abs > 13'd1440) offset <= 13'd2880;
                else offset <= 13'd0;
            end else begin
                if(delta > 13'd1440) offset <= -13'd2880;
                else offset <= 13'd0;
            end

            angle_reg5 <= Angle_t4;
            angle_reg4 <= Angle_t3;
            angle_reg3 <= Angle_t2;
            angle_reg2 <= Angle_t1;
            angle_reg1 <= Angle_in;
            
        end
    end
end
endmodule
