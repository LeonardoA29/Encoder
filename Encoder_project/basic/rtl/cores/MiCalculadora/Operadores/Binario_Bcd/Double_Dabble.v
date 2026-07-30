//UNIÓN DE MODULOS
module Double_Dabble(
    input clk,
    input reset,
    input init,
    input [26:0]in_Bin,

    output reg[31:0] out_Bcd,
    output done
    
);

wire w_sh;
wire w_ld;
wire w_ld_Nib;
wire w_chk;
wire w_z;

wire w_MSBA;
wire w_MSBN0;
wire w_MSBN1;
wire w_MSBN2;
wire w_MSBN3;
wire w_MSBN4;
wire w_MSBN5;
wire w_MSBN6;

wire [3:0] w_bcd0;
wire [3:0] w_bcd1;
wire [3:0] w_bcd2;
wire [3:0] w_bcd3;
wire [3:0] w_bcd4;
wire [3:0] w_bcd5;
wire [3:0] w_bcd6;
wire [3:0] w_bcd7;

Control_DD Control_DD0(.clk(clk),.reset(reset),.init(init),.z(w_z),.dn(done),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk));
initial_reg initial_reg0(.reset(reset),.clk(clk),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.in_Bin(in_Bin),.MSB_A(w_MSBA),.z(w_z));
Nbl Nbl0(.reset(reset),.clk(clk),.MSB(w_MSBA),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),.Nibble_out(w_bcd0),.last_MSB(w_MSBN0));
Nbl Nbl1(.reset(reset),.clk(clk),.MSB(w_MSBN0),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),.Nibble_out(w_bcd1),.last_MSB(w_MSBN1));
Nbl Nbl2(.reset(reset),.clk(clk),.MSB(w_MSBN1),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),.Nibble_out(w_bcd2),.last_MSB(w_MSBN2));
Nbl Nbl3(.reset(reset),.clk(clk),.MSB(w_MSBN2),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),.Nibble_out(w_bcd3),.last_MSB(w_MSBN3));
Nbl Nbl4(.reset(reset),.clk(clk),.MSB(w_MSBN3),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),.Nibble_out(w_bcd4),.last_MSB(w_MSBN4));
Nbl Nbl5(.reset(reset),.clk(clk),.MSB(w_MSBN4),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),.Nibble_out(w_bcd5),.last_MSB(w_MSBN5));
Nbl Nbl6(.reset(reset),.clk(clk),.MSB(w_MSBN5),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),.Nibble_out(w_bcd6),.last_MSB(w_MSBN6));
Nbl7 Nbl70(.reset(reset),.clk(clk),.MSB_N6(w_MSBN6),.sh(w_sh), .chk(w_chk),.ld(w_ld),.Nibble_out(w_bcd7));

always @(negedge clk or posedge reset) begin
    if (reset) begin
        out_Bcd <= 32'd0;
    end else begin
        out_Bcd <= {w_bcd7, w_bcd6, w_bcd5, w_bcd4, w_bcd3, w_bcd2, w_bcd1, w_bcd0};
    end
end


endmodule

//REGISTRO PARA GUARDAR ENTRADA Y MANIPULARLA

module initial_reg(
    input reset,
    input clk,
    input ld,
    input ld_Nib,
    input sh,
    input [26:0] in_Bin,
    output reg MSB_A,
    output reg z
);

reg [26:0] Entrada;
reg [4:0] Shifts_cnt;

always @(posedge clk or posedge reset) begin
    if (reset)begin
        Entrada = 0;
        Shifts_cnt = 0;
        MSB_A = 0;
    end
    else begin
        if (ld)begin
            Entrada = in_Bin;
            Shifts_cnt = 27;   
        end 
        if (ld_Nib) MSB_A = Entrada[26];
        if (sh)begin
            Entrada = Entrada << 1;
            Shifts_cnt = Shifts_cnt - 1;
        end
    end
end
always @(*) begin
   z = Shifts_cnt == 0? 1:0; 
end
endmodule

// NIBBLE

module Nbl(
    input           reset,
    input           clk,
    input           MSB,
    input           ld,
    input           ld_Nib,
    input           sh,
    input           chk,
    
    output reg[3:0] Nibble_out,
    output reg  last_MSB
); 

always @(posedge clk or posedge reset) begin
    if(reset) begin
        Nibble_out = 0;
        last_MSB = 0;
    end
    else begin
        if (chk)begin 
            if (Nibble_out > 4) Nibble_out = Nibble_out + 3;
        end
        else if (ld) Nibble_out = 0;
        else if (ld_Nib) last_MSB = Nibble_out[3];
        else if (sh) Nibble_out = {Nibble_out[2:0],MSB};
    end
end 
endmodule


module Nbl7(
    input           reset,
    input           clk,
    input           MSB_N6,
    input           sh,
    input           chk,
    input           ld,
    
    output reg [3:0] Nibble_out
); 

always @(posedge clk or posedge reset) begin
    if(reset) begin
        Nibble_out = 0;
    end
    else begin
        if (chk)begin
            if (Nibble_out > 4) Nibble_out = Nibble_out + 3;
        end
        else if (ld) Nibble_out = 0;
        else if (sh) Nibble_out = {Nibble_out[2:0],MSB_N6};
    end
end 
endmodule

//MÁQUINA DE CONTROL

module Control_DD(
    input       clk,
    input       reset,
    input       init,
    input       z,

    output reg   dn,
    output reg   ld,
    output reg   ld_Nib,
    output reg   sh,
    output reg   chk

);
      			
parameter START = 3'b000, LOAD = 3'b001, SEND = 3'b010,SHIFT = 3'b011, CHECK= 3'b100, LOAD_NIBBLES = 3'b101;
reg [2:0] state;

always @(negedge clk or posedge reset) begin
    if (reset) state = START;
    else begin 
        case (state)
            START:
                if (init) state = LOAD;
                else state = START;   
            LOAD:state = LOAD_NIBBLES;
            LOAD_NIBBLES:state = SHIFT;
            SHIFT:
               if (z) state = START;
               else state = CHECK;    
            CHECK:state = LOAD_NIBBLES;
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
            ld_Nib = 0;
        end

        LOAD: begin
            sh = 0;
            ld = 1;
            chk = 0;
            dn = 0;
            ld_Nib = 0;
        end

        LOAD_NIBBLES: begin
            sh = 0;
            ld = 0;
            chk = 0;
            dn = 0;
            ld_Nib = 1;
        end


        SHIFT: begin 
            sh = 1;
            ld = 0;
            chk = 0;
            dn = 0;
            ld_Nib = 0;
        end  
        CHECK: begin
            sh = 0;
            ld = 0;
            chk = 1;
            dn = 0;
            ld_Nib = 0;
        end
        default:begin
            sh = 0;
            ld = 0;
            chk = 0;
            dn = 0;
            ld_Nib = 0;
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
    LOAD_NIBBLES: state_name = "LD_NBs";
  endcase
end
`endif
endmodule