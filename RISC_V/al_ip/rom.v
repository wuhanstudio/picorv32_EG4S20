/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	E:/WORK/RISC_V_TEST/picorv32_EG4S20/RISC_V/al_ip/rom.v
 ** Date	:	2020 08 01
 ** TD version	:	4.3.633
\************************************************************/

`timescale 1ns / 1ps

module rom ( doa, addra, clka, rsta );

	output [31:0] doa;

	input  [12:0] addra;
	input  clka;
	input  rsta;




	EG_LOGIC_BRAM #( .DATA_WIDTH_A(32),
				.ADDR_WIDTH_A(13),
				.DATA_DEPTH_A(8192),
				.DATA_WIDTH_B(32),
				.ADDR_WIDTH_B(13),
				.DATA_DEPTH_B(8192),
				.MODE("SP"),
				.REGMODE_A("NOREG"),
				.RESETMODE("SYNC"),
				.DEBUGGABLE("NO"),
				.PACKABLE("NO"),
				.INIT_FILE("../../RISC_V.mif"),
				.FILL_ALL("NONE"))
			inst(
				.dia({32{1'b0}}),
				.dib({32{1'b0}}),
				.addra(addra),
				.addrb({13{1'b0}}),
				.cea(1'b1),
				.ceb(1'b0),
				.ocea(1'b0),
				.oceb(1'b0),
				.clka(clka),
				.clkb(1'b0),
				.wea(1'b0),
				.web(1'b0),
				.bea(1'b0),
				.beb(1'b0),
				.rsta(rsta),
				.rstb(1'b0),
				.doa(doa),
				.dob());


endmodule