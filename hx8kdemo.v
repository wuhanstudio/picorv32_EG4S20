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

module hx8kdemo (
	input clk_in,
	input reset_n,
	output ser_tx,
	input ser_rx,
	
	output flash_csb,
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,
	inout  flash_io2,
	inout  flash_io3,
	
	input key,
	output run_led 
//	output  [ 12: 0] zs_addr,
//  output  [  1: 0] zs_ba,
//  output           zs_cas_n,
//  output           zs_cke,
//  output           zs_cs_n,
//  inout   [ 15: 0] zs_dq,
//  output  [  1: 0] zs_dqm,
//  output           zs_ras_n,
//  output           zs_we_n,
//  output           sdram_clk
	
);

wire clk;
wire clk_100m;
wire sdram_clk;


	
 pll pll_logic(
    .reset(0),
	.refclk(clk_in),
	.clk0_out(clk),
	.clk1_out(sdram_clk));
	
	
reg [15:0] reset_cnt = 0;
wire resetn = (reset_cnt >= 1000);


always @(posedge clk) begin
	if(!reset_n)
		reset_cnt <= 0;
	else if(reset_cnt < 1000)
		reset_cnt <= reset_cnt + 1;	
	else 
	   reset_cnt <= reset_cnt;
end
reg [31:0]run_led_r;
always @(posedge clk)
begin
	if(!resetn)
		run_led_r =0;
	else	
		run_led_r = run_led_r +1'b1;
end
assign run_led = run_led_r[26];



wire flash_io0_oe, flash_io0_do, flash_io0_di;
wire flash_io1_oe, flash_io1_do, flash_io1_di;
wire flash_io2_oe, flash_io2_do, flash_io2_di;
wire flash_io3_oe, flash_io3_do, flash_io3_di;

assign flash_io0 = flash_io0_oe? flash_io0_do : 1'bZ;
assign flash_io1 = flash_io1_oe? flash_io1_do : 1'bZ;
assign flash_io2 = flash_io2_oe? flash_io2_do : 1'bZ;
assign flash_io3 = flash_io3_oe? flash_io3_do : 1'bZ;

assign flash_io0_di =flash_io0 ;
assign flash_io1_di =flash_io1 ;
assign flash_io2_di =flash_io2 ;
assign flash_io3_di =flash_io3 ;




wire        iomem_valid;
wire         iomem_ready;
wire [3:0]  iomem_wstrb;
wire [31:0] iomem_addr;
wire [31:0] iomem_wdata;
wire  [31:0] iomem_rdata;
wire init_done;

	picosoc32 soc (
		.clk          (clk       ),
		.resetn       (resetn     ),

		.ser_tx       (ser_tx      ),
		.ser_rx       (ser_rx      ),
		.ex_irq       (0           ),
		
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

		.iomem_valid  (iomem_valid ),
		.iomem_ready  (iomem_ready ),
		.iomem_wstrb  (iomem_wstrb ),
		.iomem_addr   (iomem_addr  ),
		.iomem_wdata  (iomem_wdata ), 
		.iomem_rdata  (iomem_rdata )
	);

	


 wire  [ 10: 0] zs_addr;
 wire  [  1: 0] zs_ba;
 wire           zs_cas_n;
 wire           zs_cke;
 wire           zs_cs_n;
 wire  [ 31: 0] zs_dq;
 wire  [  3: 0] zs_dqm;
 wire           zs_ras_n;
 wire           zs_we_n;

 wire  [ 31: 0] za_data;
 wire           za_valid;
 wire           za_waitrequest;
 wire  [ 23: 0] az_addr;
 wire  [  3: 0] az_be_n;
 wire           az_cs;
 wire  [ 31: 0] az_data;
 wire           az_rd_n;
 wire           az_wr_n;


picosoc_sdram bridge (
    //  cpu port
	.clk		(clk),
	.resetn		(resetn),
	.valid		( iomem_valid ),
	.wen		( iomem_wstrb),
	.addr		( iomem_addr[25:2]),
	.wdata		( iomem_wdata ),
	.rdata		( iomem_rdata),
	.ready		( iomem_ready),
	
	
	// avalone port
	.az_addr				(az_addr      ),
	.az_be_n				(az_be_n   ),
	.az_cs				    (az_cs),   
	.az_data				(az_data    ),
	.az_rd_n				(az_rd_n         ),
	.az_wr_n				(az_wr_n        ),
	.za_data				(za_data     ),
	.za_valid		 		(za_valid),
	.za_waitrequest 		(za_waitrequest)
                      );


	
		sdram_sdram sdram (
		.clk            (clk),           
		.reset_n        (resetn),        
		.az_addr        (az_addr),       
		.az_be_n        (az_be_n),       
		.az_cs          (az_cs),         
		.az_data        (az_data),       
		.az_rd_n        (az_rd_n),       
		.az_wr_n        (az_wr_n),       
		.za_data        (za_data),       
		.za_valid       (za_valid),      
		.za_waitrequest (za_waitrequest),
		
		.zs_addr        (zs_addr        ),   
		.zs_ba          (zs_ba          ),   
		.zs_cas_n       (zs_cas_n       ),   
		.zs_cke         (zs_cke         ),   
		.zs_cs_n        (zs_cs_n        ),   
		.zs_dq          (zs_dq          ),   
		.zs_dqm         (zs_dqm         ),   
		.zs_ras_n       (zs_ras_n       ),   
		.zs_we_n        (zs_we_n        ),   
		.init_done      (init_done)
	);
	
	
	
	sdram sdram_dev ( 
	.clk  (sdram_clk    ),
	.ras_n(zs_ras_n   ),
	.cas_n(zs_cas_n ),
	.we_n (zs_we_n  ), 
	.addr (zs_addr  ),
	.ba   (zs_ba    ),
	.dq   (zs_dq    ), 
	.cs_n (0 ),
	.dm0  (zs_dqm[0]),
	.dm1  (zs_dqm[1]),
	.dm2  (zs_dqm[2]),
	.dm3  (zs_dqm[3]), 
	.cke  (zs_cke   ));
	
	


endmodule

module pico_ram#(
	parameter integer WORDS = 4096
)
(
	input valid,
	input clk,
	input [3:0] wen,
	input [13:0] addr,
	input [31:0] wdata,
	output reg ready,
	output  [31:0] rdata
);
soc_mem mem (
    .rsta(0),
	.addra(addr[11:0]),
	.wea(valid? wen: 4'b0),
	.clka(clk),
	.dia(wdata),
	.doa(rdata));

	initial begin
		ready <= 1'b0;
	end
	always @(posedge clk) begin
		if(valid && !ready )begin
			ready <= 1'b1;  
		end
		else begin
			ready <= 1'b0;
		end
	end
endmodule

module pico_rom #(
	parameter integer WORDS = 4096
)(
	input valid,
	input clk,
	input [3:0] wen,
	input [13:0] addr,
	input [31:0] wdata,
	output reg ready,
	output  [31:0] rdata
);
rom  picrv_rom(
	.rsta(0),
	.addra(addr[12:0]),
	.clka(clk),
	.doa(rdata));
	initial begin
		ready <= 1'b0;
	end
	always @(posedge clk) begin
		if(valid && !ready )begin
			ready <= 1'b1;
		end
		else begin
			ready <= 1'b0;
		end
	end
endmodule

