//UNIÓN DE MODULOS
module Rev_Double_Dabble(
    input clk,
    input reset,
    input init,
    input [31:0]in_Bcd,

    output [26:0] out_Bin,
    output done    
);

wire w_sh;
wire w_ld;
wire w_ld_Nib;
wire w_chk;
wire w_z;


wire w_LSBN0;
wire w_LSBN1;
wire w_LSBN2;
wire w_LSBN3;
wire w_LSBN4;
wire w_LSBN5;
wire w_LSBN6;
wire w_LSB7;

Control Control0(.clk(clk),.reset(reset),.init(init),.z(w_z),.dn(done),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk));
out_reg out_reg0(.reset(reset),.clk(clk),.ld(w_ld),.sh(w_sh),.LSB_N0(w_LSBN0),.out_Bin(out_Bin),.z(w_z));

R_Nbl R_Nbl0(.reset(reset),.clk(clk),.LSB(w_LSBN1),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),
         .nibble_in(in_Bcd[3:0]),.last_LSB(w_LSBN0));
R_Nbl R_Nbl1(.reset(reset),.clk(clk),.LSB(w_LSBN2),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),
         .nibble_in(in_Bcd[7:4]),.last_LSB(w_LSBN1));
R_Nbl R_Nbl2(.reset(reset),.clk(clk),.LSB(w_LSBN3),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),
         .nibble_in(in_Bcd[11:8]),.last_LSB(w_LSBN2));
R_Nbl R_Nbl3(.reset(reset),.clk(clk),.LSB(w_LSBN4),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),
         .nibble_in(in_Bcd[15:12]),.last_LSB(w_LSBN3));
R_Nbl R_Nbl4(.reset(reset),.clk(clk),.LSB(w_LSBN5),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),
         .nibble_in(in_Bcd[19:16]),.last_LSB(w_LSBN4));
R_Nbl R_Nbl5(.reset(reset),.clk(clk),.LSB(w_LSBN6),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),
         .nibble_in(in_Bcd[23:20]),.last_LSB(w_LSBN5));
R_Nbl R_Nbl6(.reset(reset),.clk(clk),.LSB(w_LSBN7),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),
         .nibble_in(in_Bcd[27:24]),.last_LSB(w_LSBN6));
R_Nbl R_Nbl7(.reset(reset),.clk(clk),.LSB(1'b0),.ld(w_ld),.ld_Nib(w_ld_Nib),.sh(w_sh),.chk(w_chk),
         .nibble_in(in_Bcd[31:28]),.last_LSB(w_LSBN7));

endmodule

//REGISTRO PARA GUARDAR ENTRADA Y MANIPULARLA

module out_reg(
    input reset,
    input clk,
    input ld,
    input sh,
    input LSB_N0,
    output reg[26:0] out_Bin,
    output reg z
);
reg [4:0] Shifts_cnt;

always @(posedge clk or posedge reset) begin
    if (reset)begin
        Shifts_cnt <= 0;
        out_Bin <= 0;
    end
    else begin
        if (sh)begin
            out_Bin <= {LSB_N0,out_Bin[26:1]};
            Shifts_cnt <= Shifts_cnt - 1;
        end
        else if (ld) Shifts_cnt = 27;
    end
end
always @(*) begin
   z <= Shifts_cnt == 0? 1:0; 
end
endmodule

// NIBBLE

module R_Nbl(
    input           reset,
    input           clk,
    input           LSB,
    input           ld,
    input           ld_Nib,
    input           sh,
    input           chk,
    input wire[3:0] nibble_in,
    output reg      last_LSB
); 
reg [3:0] nibble;

always @(posedge clk or posedge reset) begin
    if(reset) begin
        last_LSB = 0;
        nibble = 0;
    end
    else begin
        if (chk)begin 
            if (nibble > 4) nibble = nibble - 3;
        end
        else if (ld_Nib) last_LSB = nibble[0];
        else if (ld) nibble = nibble_in;
        else if (sh) nibble = {LSB,nibble[3:1]};
    end
end 
endmodule


//MÁQUINA DE CONTROL

module Control(
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
        default: begin
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