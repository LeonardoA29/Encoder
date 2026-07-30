module Sampler (
    input clk,
    input reset,
    input init,
    input [13:0] angle_in,
    input [15:0] Speed_in,
    output reg [13:0] angle_out,
    output reg [15:0] Speed_out,
    output reg done
);
 parameter START       = 2'b00;
 parameter WAIT        = 2'b01;
 parameter SAMPLE      = 2'b10;

 reg [1:0] state;
 reg init_ff1, init_ff2;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        init_ff1 <= 1'b0;
        init_ff2 <= 1'b0;

        state <= START;
        angle_out <= 14'd0;
        Speed_out <= 16'd0;
    end else begin
        // Sincronizador de 2 FF
        init_ff1 <= init;
        init_ff2 <= init_ff1;

        case (state)
            START: begin
                if (init_ff2) state <= SAMPLE;
                else ;
                
            end

            SAMPLE: begin
                angle_out <= angle_in;
                Speed_out <= Speed_in;
                state <= WAIT;
            end

            WAIT: begin
                if (!init_ff2)
                    state <= START;
                else
                    state <= WAIT;
            end

            default: state <= START;
        endcase
    end
end

// done solo se activa cuando el dato realmente ya fue capturado
// (estado WAIT). En START/SAMPLE debe estar en 0, para que la CPU
// no confunda "todavia no muestree" con "ya termine".
always @(*) begin
    case(state)
      START: begin
        done = 0;
      end

      SAMPLE: begin
        done = 0;
      end

      WAIT: begin
        done = 1;
      end

      default: begin
        done = 0;
      end
    endcase
end
endmodule
