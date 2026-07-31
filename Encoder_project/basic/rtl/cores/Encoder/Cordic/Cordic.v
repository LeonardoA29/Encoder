module Cordic( 
    input clk,
    input reset,
    input init,
    input sh,
    input calc,
    input [11:0] x_in, 
    input [11:0] y_in, 
    output [13:0] angle_out, 
    output [12:0] amplitude_out 
); 

wire signed [12:0] expanded_x_in;
wire signed [12:0] expanded_y_in;

assign expanded_x_in = {x_in[11], x_in};
assign expanded_y_in = {y_in[11], y_in};




wire [12:0] X0_out; 
wire [12:0] Y0_out; 
wire [13:0] angle0_out; 

wire [12:0] X1_out; 
wire [12:0] Y1_out; 
wire [13:0] angle1_out; 

wire [12:0] X2_out; 
wire [12:0] Y2_out; 
wire [13:0] angle2_out; 

wire [12:0] X3_out; 
wire [12:0] Y3_out; 
wire [13:0] angle3_out; 

wire [12:0] X4_out; 
wire [12:0] Y4_out; 
wire [13:0] angle4_out; 

wire [12:0] X5_out; 
wire [12:0] Y5_out; 
wire [13:0] angle5_out; 

wire [12:0] X6_out; 
wire [12:0] Y6_out; 
wire [13:0] angle6_out; 

wire [12:0] X7_out; 
wire [12:0] Y7_out; 
wire [13:0] angle7_out; 

wire [12:0] X8_out; 
wire [12:0] Y8_out; 
wire [13:0] angle8_out; 

wire [12:0] X9_out; 
wire [12:0] Y9_out; 
wire [13:0] angle9_out; 

wire [12:0] Xend_out; 
wire [12:0] Yend_out; 

// Tabla de atan(2^-i) en grados, formato Q9.3 (×8)

localparam signed [11:0] ATAN0 = 14'd360;
localparam signed [11:0] ATAN1 = 14'd213;
localparam signed [11:0] ATAN2 = 14'd112;
localparam signed [11:0] ATAN3 = 14'd57;
localparam signed [11:0] ATAN4 = 14'd29;
localparam signed [11:0] ATAN5 = 14'd14;
localparam signed [11:0] ATAN6 = 14'd7;
localparam signed [11:0] ATAN7 = 14'd4;
localparam signed [11:0] ATAN8 = 14'd2;
localparam signed [11:0] ATAN9 = 14'd1;



first_Cordic_iteration first_iter (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(Offset_x),
    .y_in(Offset_y),
    .X_out(X0_out),
    .Y_out(Y0_out),
    .angle_out(angle0_out)
);

Cordic_iteration #(
    .tan_value(ATAN0),
    .N_iteration(0)
) iter1 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X0_out),
    .y_in(Y0_out),
    .angle_in(angle0_out),
    .X_out(X1_out),
    .Y_out(Y1_out),
    .angle_out(angle1_out)
);

Cordic_iteration #(
    .tan_value(ATAN1),
    .N_iteration(1)
) iter2 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X1_out),
    .y_in(Y1_out),
    .angle_in(angle1_out),
    .X_out(X2_out),
    .Y_out(Y2_out),
    .angle_out(angle2_out)
);

Cordic_iteration #(
    .tan_value(ATAN2),
    .N_iteration(2)
) iter3 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X2_out),
    .y_in(Y2_out),
    .angle_in(angle2_out),
    .X_out(X3_out),
    .Y_out(Y3_out),
    .angle_out(angle3_out)
);

Cordic_iteration #(
    .tan_value(ATAN3),
    .N_iteration(3)
) iter4 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X3_out),
    .y_in(Y3_out),
    .angle_in(angle3_out),
    .X_out(X4_out),
    .Y_out(Y4_out),
    .angle_out(angle4_out)
);

Cordic_iteration #(
    .tan_value(ATAN4),
    .N_iteration(4)
) iter5 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X4_out),
    .y_in(Y4_out),
    .angle_in(angle4_out),
    .X_out(X5_out),
    .Y_out(Y5_out),
    .angle_out(angle5_out)
);

Cordic_iteration #(
    .tan_value(ATAN5),
    .N_iteration(5)
) iter6 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X5_out),
    .y_in(Y5_out),
    .angle_in(angle5_out),
    .X_out(X6_out),
    .Y_out(Y6_out),
    .angle_out(angle6_out)
);

Cordic_iteration #(
    .tan_value(ATAN6),
    .N_iteration(6)
) iter7 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X6_out),
    .y_in(Y6_out),
    .angle_in(angle6_out),
    .X_out(X7_out),
    .Y_out(Y7_out),
    .angle_out(angle7_out)
);

Cordic_iteration #(
    .tan_value(ATAN7),
    .N_iteration(7)
) iter8 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X7_out),
    .y_in(Y7_out),
    .angle_in(angle7_out),
    .X_out(X8_out),
    .Y_out(Y8_out),
    .angle_out(angle8_out)
);

Cordic_iteration #(
    .tan_value(ATAN8),
    .N_iteration(8)
) iter9 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X8_out),
    .y_in(Y8_out),
    .angle_in(angle8_out),
    .X_out(X9_out),
    .Y_out(Y9_out),
    .angle_out(angle9_out)
);

Cordic_iteration #(
    .tan_value(ATAN9),
    .N_iteration(9)
) iter10 (
    .clk(clk),
    .reset(reset),
    .sh(sh),
    .calc(calc),
    .x_in(X9_out),
    .y_in(Y9_out),
    .angle_in(angle9_out),
    .X_out(Xend_out),
    .Y_out(Yend_out),
    .angle_out(angle_out)
);

escale_magnitude escale (
    .clk(clk),
    .reset(reset),
    .x_in(Xend_out),
    .mag_out(amplitude_out)
);
endmodule


module Cordic_iteration #(parameter tan_value = 12'd45, parameter N_iteration = 1) (
    input clk,
    input reset,
    input sh,
    input calc,
    input signed [12:0] x_in,
    input signed [12:0] y_in,
    input signed [13:0] angle_in,
    output reg signed [12:0] X_out,
    output reg signed [12:0] Y_out,
    output reg signed [13:0] angle_out
);

reg d;
reg signed [12:0] X_in_reg;
reg signed[12:0] Y_in_reg;
reg signed[13:0] angle_in_reg;


always @(negedge clk or posedge reset) begin
    if (reset) begin
        X_out <= 12'b0;
        Y_out <= 12'b0;
        angle_out <= 12'b0;
        X_in_reg <= 0;
        Y_in_reg <= 0;
        angle_in_reg <= 0;
    end else if (calc) begin
        if (d == 1'b1) begin
            X_out <= X_in_reg + (Y_in_reg >>> N_iteration);
            Y_out <= Y_in_reg - (X_in_reg >>> N_iteration);
            angle_out <= angle_in_reg + tan_value;
        end else begin
            X_out <= X_in_reg - (Y_in_reg >>> N_iteration);
            Y_out <= Y_in_reg + (X_in_reg >>> N_iteration);
            angle_out <= angle_in_reg - tan_value;
        end
    end else if (sh) begin
        X_in_reg <= x_in;
        Y_in_reg <= y_in;
        angle_in_reg <= angle_in;
    end
    
end

always @(*) begin
    d = (!Y_in_reg[12]) ? 1'b1 : 1'b0;
end

endmodule


module first_Cordic_iteration (
    input clk,
    input reset,
    input sh,
    input calc,
    input signed [12:0] x_in,
    input signed [12:0] y_in,
    output reg signed [12:0] X_out,
    output reg signed [12:0] Y_out,
    output reg signed [13:0] angle_out
);
wire signed[12:0] x_neg;
wire signed[12:0] y_neg;
assign x_neg = ~x_in + 1'b1;
assign y_neg = ~y_in + 1'b1;

always @(negedge clk or posedge reset) begin
    if (reset) begin
        X_out <= 13'b0;
        Y_out <= 13'b0;
        angle_out <= 13'b0;
    end else begin
        if (calc)begin     
            case (y_in[12])
                1'b0: begin
                    case (x_in[12])
                        1'b0: begin
                            angle_out <= 13'd0;
                            X_out <= x_in;
                            Y_out <= y_in;
                        end
                        1'b1: begin
                            angle_out <= 13'd720;
                            X_out <= y_in;
                            Y_out <= x_neg;
                        end
                    endcase
                end
                1'b1: begin
                    case (x_in[12])
                        1'b0: begin
                            angle_out <= 13'd2160;
                            X_out <= y_neg;
                            Y_out <= x_in;
                        end
                        1'b1: begin
                            angle_out <= 13'd1440;
                            X_out <= x_neg;
                            Y_out <= y_neg;
                        end
                    endcase
                end
            endcase
        end  
    end
end

endmodule


module escale_magnitude(
    input clk,
    input reset,
    input signed [12:0] x_in,
    output signed [12:0] mag_out
);


reg signed [12:0] mag_out_reg;
assign mag_out = mag_out_reg;

localparam [11:0] K_SCALE = 12'd622;

// 13 bits × 12 bits = 25 bits
reg signed [24:0] product;

always @(*) begin
    product = x_in * K_SCALE;
    mag_out_reg = product[22:10];   // >>10
end

endmodule