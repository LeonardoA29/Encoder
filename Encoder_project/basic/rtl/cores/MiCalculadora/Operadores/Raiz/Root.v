//UNIÓN DE MODULOS
module Root(
    input clk,
    input reset,
    input init,
    input [27:0]Radicando,

    output [13:0]Raiz,
    output [27:0] Residuo,
    output done
    
);

wire w_sh;
wire w_ld;
wire w_chk;
wire w_z;

Control_sqrt Control_sqrt0(.clk(clk),.reset(reset),.init(init),.z(w_z),.dn(done),.ld(w_ld),.sh(w_sh),.chk(w_chk));
Data_path_sqrt Data_path_sqrt0(.reset(reset),.clk(clk),.ld(w_ld),.sh(w_sh),.chk(w_chk),.Radicando(Radicando),.Residuo(Residuo),.Raiz(Raiz),.z(w_z));

endmodule

//REGISTRO PARA GUARDAR ENTRADA Y MANIPULARLA

module Data_path_sqrt(
    input reset,
    input clk,
    input ld,
    input sh,
    input chk,
    input [27:0] Radicando,
    output reg [27:0] Residuo,
    output reg [13:0] Raiz,
    output reg z
);

reg [4:0] Shifts_cnt;
reg [14:0] Raiz_Aux;
reg [27:0] Residuo_Aux;

always @(posedge clk or posedge reset) begin
    if (reset)begin
        Residuo = 0;
        Shifts_cnt = 0;
        Raiz = 0;
        Residuo_Aux= 0;
    end
    else begin
        if (ld)begin
            Residuo_Aux = Radicando;
            Shifts_cnt = 14;  
            Raiz = 0; 
            Residuo = 0;
        end 
        if (sh)begin
            Raiz <= Raiz << 1;
            Residuo <= {Residuo[25:0],Residuo_Aux[27:26]};
            Shifts_cnt <= Shifts_cnt - 1;
        end
        if (chk)begin
            if (Residuo >= Raiz_Aux) begin
                Residuo <= Residuo - Raiz_Aux;
                Raiz <= Raiz + 1;
            end
            Residuo_Aux = Residuo_Aux << 2;
        end
    end
end
always @(*) begin
   z = Shifts_cnt == 0? 1:0;
   Raiz_Aux = {Raiz[13:0],1'b1};

end
endmodule


//MÁQUINA DE CONTROL

module Control_sqrt(
    input       clk,
    input       reset,
    input       init,
    input       z,

    output reg   dn,
    output reg   ld,
    output reg   sh,
    output reg   chk

);
      			
parameter START = 2'b00, LOAD = 2'b01,SHIFT = 2'b10, CHECK= 2'b11;
reg [1:0] state;

always @(negedge clk or posedge reset) begin
    if (reset) state = START;
    else begin 
        case (state)
            START:
                if (init) state = LOAD;
                else state = START;   
            LOAD:state = SHIFT;
            CHECK:
                if (z) state = START; 
                else state = SHIFT;
            SHIFT:state = CHECK;    
            default:state = START;
        endcase
   end
end

always @(*) begin
    case (state)
        START: begin     
            sh = 0;
            ld = 0;
            chk = 0;
            dn = 1;
        end

        LOAD: begin
            sh = 0;
            ld = 1;
            chk = 0;
            dn = 0;
        end
        SHIFT: begin 
            sh = 1;
            ld = 0;
            chk = 0;
            dn = 0;
        end  
        CHECK: begin
            sh = 0;
            ld = 0;
            chk = 1;
            dn = 0;
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
    CHECK    : state_name = "CHECK";
  endcase
end
`endif
endmodule