module Control (
    input clk,
    input reset,
    input init,
    output reg sh,
    output reg calc,
    output reg clk_adc
);
 parameter START          = 2'b00;
 parameter SHIFT_AND_CLOCK= 2'b01;
 parameter CALCULATE      = 2'b10;

 reg [1:0] state;

always @(posedge clk or posedge reset ) begin
    if (reset)begin
        state <= START;
        clk_adc <= 0;
    end else begin
        case (state)
            START:begin
                if (init) state <= CALCULATE;
                 clk_adc <= 0;
            end 
            CALCULATE:begin
                state <= SHIFT_AND_CLOCK;
                 clk_adc <= 0;
            end
            SHIFT_AND_CLOCK:begin
                if (init) state <= CALCULATE;
                else state <= START;
                clk_adc <= 1;
            end
            default: state <= START;
        endcase

    end
end

always @(*) begin
    case(state)
      START: begin
        calc = 0; sh = 0; 
      end

      CALCULATE: begin
        calc = 1; sh = 0;
      end

      SHIFT_AND_CLOCK: begin
        calc = 0; sh = 1; 
      end

      default: begin
        calc = 0; sh = 0; 
      end
    endcase
end
endmodule
