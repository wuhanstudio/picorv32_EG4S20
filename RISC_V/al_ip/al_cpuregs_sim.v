// Verilog netlist created by TD v4.2.285
// Fri Jan 17 09:42:53 2020

`timescale 1ns / 1ps
module al_cpureg  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(14)
  (
  addra,
  addrb,
  cea,
  clka,
  clkb,
  dia,
  rsta,
  rstb,
  dob
  );

  input [5:0] addra;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(23)
  input [5:0] addrb;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(24)
  input cea;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(25)
  input clka;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(26)
  input clkb;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(27)
  input [31:0] dia;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(22)
  input rsta;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(28)
  input rstb;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(29)
  output [31:0] dob;  // E:/WORK/RISC_V_TEST/RISC_V/al_ip/al_cpuregs.v(19)


  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  // address_offset=0;data_offset=0;depth=64;width=18;num_section=1;width_per_section=18;section_size=32;working_depth=512;working_width=18;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEAMUX("1"),
    .CEBMUX("1"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("SIG"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("18"),
    .DATA_WIDTH_B("18"),
    .MODE("PDPW8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .WEAMUX("1"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_64x32_sub_000000_000 (
    .addra({3'b000,addra,4'b1111}),
    .addrb({3'b000,addrb,4'b1111}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n49,open_n50}),
    .dia(dia[8:0]),
    .dib(dia[17:9]),
    .rsta(rsta),
    .rstb(rstb),
    .doa(dob[8:0]),
    .dob(dob[17:9]));
  // address_offset=0;data_offset=18;depth=64;width=14;num_section=1;width_per_section=14;section_size=32;working_depth=512;working_width=18;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEAMUX("1"),
    .CEBMUX("1"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("SIG"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("18"),
    .DATA_WIDTH_B("18"),
    .MODE("PDPW8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .WEAMUX("1"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_64x32_sub_000000_018 (
    .addra({3'b000,addra,4'b1111}),
    .addrb({3'b000,addrb,4'b1111}),
    .clka(clka),
    .clkb(clkb),
    .csa({cea,open_n60,open_n61}),
    .dia(dia[26:18]),
    .dib({open_n65,open_n66,open_n67,open_n68,dia[31:27]}),
    .rsta(rsta),
    .rstb(rstb),
    .doa(dob[26:18]),
    .dob({open_n73,open_n74,open_n75,open_n76,dob[31:27]}));

endmodule 

