/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`ifndef PICORV32_REGS
`ifdef PICORV32_V
`error "picosoc.v must be read before picorv32.v!"
`endif

`define PICORV32_REGS picosoc_regs
`endif

`ifndef PICOSOC_MEM
`define PICOSOC_MEM picosoc_mem
`endif

// this macro can be used to check if the verilog files in your
// design are read in the correct order.
`define PICOSOC_V

module picosoc32 (
	input clk,
	input resetn,

	output        iomem_valid,
	input         iomem_ready,
	output [ 3:0] iomem_wstrb,
	output [31:0] iomem_addr,
	output [31:0] iomem_wdata,
	input  [31:0] iomem_rdata,
	input  [23:0] ex_irq,

	output ser_tx,
	input  ser_rx,
	
	output trap,
	
	output flash_csb,
	output flash_clk,

	output flash_io0_oe,
	output flash_io1_oe,
	output flash_io2_oe,
	output flash_io3_oe,

	output flash_io0_do,
	output flash_io1_do,
	output flash_io2_do,
	output flash_io3_do,

	input  flash_io0_di,
	input  flash_io1_di,
	input  flash_io2_di,
	input  flash_io3_di

);

	reg [31:0] irq ;
	wire irq_stall;
	wire irq_uart ;

	always @(posedge clk) 
		if(!resetn)
		irq <= 31'b0;
		else
		begin
		irq[3] <= irq_stall;
		irq[4] <= irq_uart;
		irq[31:8]<= ex_irq;
	end

	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0]  mem_wstrb;
	wire  [31:0] mem_rdata;
	
	wire ram_valid;
	wire ram_ready;
	wire [31:0] ram_rdata;
	wire rom_valid;
	wire rom_ready;
	wire [31:0] rom_rdata;
	
	wire spimem_ready;
	wire [31:0] spimem_rdata;
	
	wire spimemio_cfgreg_sel = mem_valid && (mem_addr == 32'h 0200_0004);
	wire [31:0] spimemio_cfgreg_do;
	
	wire        simpleuart_reg_div_sel = mem_valid && (mem_addr == 32'h 0200_0000);
	wire [31:0] simpleuart_reg_div_do;

	wire        simpleuart_reg_dat_sel = mem_valid && (mem_addr == 32'h 0200_0008);
	wire [31:0] simpleuart_reg_dat_do;
	wire        simpleuart_reg_dat_wait;
	
	
	assign iomem_valid = mem_valid && (mem_addr[31:24] > 8'h 02);
	assign iomem_wstrb = mem_wstrb;
	assign iomem_addr = mem_addr;
	assign iomem_wdata = mem_wdata;
	
	assign mem_ready = (iomem_valid && iomem_ready) ||
						ram_ready ||
						rom_ready ||
						spimem_ready ||
						spimemio_cfgreg_sel ||
						simpleuart_reg_div_sel ||
						(simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait);
	assign mem_rdata = 	 (iomem_valid && iomem_ready) ? iomem_rdata :
						ram_ready ? ram_rdata :
						rom_ready ? rom_rdata : 
						spimem_ready ? spimem_rdata:
						spimemio_cfgreg_sel ? spimemio_cfgreg_do : 
						simpleuart_reg_div_sel ? simpleuart_reg_div_do :
						simpleuart_reg_dat_sel ? simpleuart_reg_dat_do :
						32'h 0000_0000;


	picorv32 #(
		.STACKADDR(4*4096),
		.PROGADDR_RESET(32'h 0002_0000),
		.PROGADDR_IRQ(32'h 0002_0400),
		.BARREL_SHIFTER(1),
		.COMPRESSED_ISA(1),
		.ENABLE_COUNTERS(1),
		.ENABLE_MUL(0),
		.ENABLE_DIV(0),
		.ENABLE_IRQ(1),
		.ENABLE_IRQ_QREGS(1)
	) cpu (
		.clk         (clk        ),
		.resetn      (resetn     ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  ),
		.trap        (trap       ),
		.irq         (irq        )
	);
	
	simpleuart simpleuart (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.ser_tx      (ser_tx      ),
		.ser_rx      (ser_rx      ),
		
		.reg_div_we  (simpleuart_reg_div_sel ? mem_wstrb : 4'b 0000),
		.reg_div_di  (mem_wdata),
		.reg_div_do  (simpleuart_reg_div_do),
		
		.reg_dat_we  (simpleuart_reg_dat_sel ? mem_wstrb[0] : 1'b 0),
		.reg_dat_re  (simpleuart_reg_dat_sel && !mem_wstrb),
		.reg_dat_di  (mem_wdata),
		.reg_dat_do  (simpleuart_reg_dat_do),
		.reg_dat_wait(simpleuart_reg_dat_wait),
		.irq(irq_uart)
	);



	
	localparam RAM_ORIGIN = 0;  // 16K RAM
	localparam RAM_SIZE = 16*1024;  // 16K RAM
	assign ram_valid = mem_valid  && (mem_addr >= RAM_ORIGIN )&&(mem_addr <= RAM_ORIGIN+RAM_SIZE);
	pico_ram #(
		.WORDS(RAM_SIZE)
	)ram(
	.valid(ram_valid),
	.clk(clk),
	.wen(ram_valid? mem_wstrb : 4'b0),
	.addr(mem_addr[15:2]),
	.wdata(mem_wdata),
	.ready(ram_ready),
	.rdata(ram_rdata)
	);

	localparam ROM_ORIGIN = 32'h20000;  //
	localparam ROM_SIZE = 32*1024;  // 16K ROM
    assign rom_valid = mem_valid && (mem_addr >= ROM_ORIGIN )&&(mem_addr <= ROM_ORIGIN+ROM_SIZE);
	pico_rom #(
		.WORDS(ROM_SIZE)
	)rom(
	.valid(rom_valid),
	.clk(clk),
	.wen(rom_valid? mem_wstrb : 4'b0),
	.addr(mem_addr[16:2]),
	.wdata(mem_wdata),
	.ready(rom_ready),
	.rdata(rom_rdata)
	);
	spimemio spimemio (
		.clk    (clk),
		.resetn (resetn),
		.valid  (mem_valid && mem_addr >= 32'h 0100_0000&& mem_addr < 32'h 0200_0000),
		.ready  (spimem_ready),
		.addr   (mem_addr[23:0]),
		.rdata  (spimem_rdata),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.cfgreg_we(spimemio_cfgreg_sel ? mem_wstrb : 4'b 0000),
		.cfgreg_di(mem_wdata),
		.cfgreg_do(spimemio_cfgreg_do)
	);




endmodule


module picosoc_regs (
	input clk, wen,
	input [5:0] waddr,
	input [5:0] raddr1,
	input [5:0] raddr2,
	input [31:0] wdata,
	output [31:0] rdata1,
	output [31:0] rdata2
);



 al_cpureg cpureg0 ( 
	.dia	(wdata),
	.addra	(waddr), 
	.clka	(clk), 
	.cea	(wen),
	.rsta	(0), 
	.dob	(rdata1), 
	.addrb	(raddr1), 
	.clkb	(clk), 
	.rstb   (0)
);

 al_cpureg cpureg1 ( 
	.dia	(wdata),
	.addra	(waddr), 
	.clka	(clk), 
	.cea	(wen),
	.rsta	(0), 
	.dob	(rdata2), 
	.addrb	(raddr2), 
	.clkb	(clk), 
	.rstb   (0)
);
//
//
//	reg [31:0] regs [0:63];
//
//
//
//
//	always @(posedge clk)
//		if (wen) regs[waddr[5:0]] <= wdata;
//
//	assign rdata1 = regs[raddr1[5:0]];
//	assign rdata2 = regs[raddr2[5:0]];
endmodule
