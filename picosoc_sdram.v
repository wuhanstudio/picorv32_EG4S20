
module picosoc_sdram (
    //  cpu port
	input clk,
	input resetn,
	input  valid,
	input  [3:0]  wen,
	input  [23:0]  addr,
	input  [31:0] wdata,
	output [31:0] rdata,
	output ready,
	// avalone port
	output   [ 23: 0] az_addr,
	output   [  3: 0] az_be_n,
	output            az_cs,
	output   [ 31: 0] az_data,
	output            az_rd_n,
	output            az_wr_n,
	
	input  [ 31: 0] za_data,
	input           za_valid,
	input           za_waitrequest
                         )
;
	reg read_stat = 0;
	assign az_wr_n = valid ? ~(|wen) : 1; 
	assign az_rd_n = valid ? (read_stat || (|wen)) : 1;
	assign az_addr = addr;
	assign az_be_n = az_wr_n? (4'b0000) : ~wen[3:0];
	assign az_data = wdata[ 31: 0];
	assign rdata   = za_data;
	assign az_cs   = 1;
	assign ready = 	(!az_wr_n) ? ~za_waitrequest :
					(read_stat) ? za_valid		: 
					0;
	
always @(posedge clk )begin
	if(!resetn)	
		read_stat <= 0;
	else begin
		if(!read_stat && (!az_rd_n) && (za_waitrequest == 0))
			read_stat =1;
		else if (za_valid == 1)
			read_stat =0;
			
		end
	end
endmodule

