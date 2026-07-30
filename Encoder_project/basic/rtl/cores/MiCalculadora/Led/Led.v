module Led(
    input clk,
    input reset,
    input init,
    input [31:0]in_Bcd,
    output DIO,
    output clk_com,
    output STB,
    output done
);

wire w_init_send;
wire [3:0] w_nibble;
wire [7:0] w_out_siete_seg;
wire w_transmision_done;

reg cs_operador[1:0];
reg div_done;
reg raiz_done;
reg [27:0]in_Bin;

parameter divider = 20;

   frac_bcd #(.divider(divider)) frac_bcd0(
      .clk(clk), 
      .reset(reset), 
      .init(init),
      .transmision_done(w_transmision_done), 
      .in_Bcd(in_Bcd), 
      .nibble(w_nibble),
      .init_send(w_init_send),
      .STB(STB), 
      .done(done)
   );
    Com #(.divider(divider)) Com0(
      .clk(clk), 
      .reset(reset), 
      .init(w_init_send), 
      .data_cmd(w_out_siete_seg), 
      .DIO(DIO),
      .clk_com(clk_com), 
      .done(w_transmision_done)
   );

   bcd_siete_seg bcd_siete_seg0(
      .nibble(w_nibble),
      .out_siete_seg(w_out_siete_seg));

   
    
endmodule
