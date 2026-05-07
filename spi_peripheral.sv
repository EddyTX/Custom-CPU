module spi_peripheral #(
	parameter DATA_W 		= 8,
	parameter SPI_ADDR_W 	= 6
) (
	input logic 					clk_50,          // CPU 50MHz clk
	input logic 					clk_1,           // 1MHz clk
	input logic 					clk_1_shifted,   // 1MHz 220 degrees shifted clk
	input logic 					rst_n,
	input logic [SPI_ADDR_W-1:0]	spi_addr,
	input logic						spi_read_en,
	input logic						spi_write_en,
	input logic [DATA_W-1:0]		write_data,
	output logic [DATA_W-1:0]		read_data,
	output logic					spi_ack,
	input logic						miso,
	output logic					mosi,
	output logic					sclk,
	output logic					cs_n,
	output logic					spi_oe
);

logic 		req_wire;
logic 		rw_n_wire;
logic 		ack_from_phy;
logic [2:0] sync_pipe;

assign req_wire 	= spi_read_en | spi_write_en;
assign rw_n_wire 	= spi_read_en;
assign spi_ack 		= sync_pipe[1] & ~sync_pipe[2];

spi_phy phy_inst (
	.rst_ni		(rst_n),
	.clk_i		(clk_1),
	.spi_clk_i	(clk_1_shifted),
	.req_i		(req_wire),
	.rw_ni		(rw_n_wire),
	.addr_i		(spi_addr),
	.wr_data_i	(write_data),
	.ack_o		(ack_from_phy),
	.rd_data_o	(read_data),
	.spi_cs_no	(cs_n),
	.spi_clk_o	(sclk),
	.spi_data_o	(mosi),
	.spi_data_i	(miso),
	.spi_oe_o	(spi_oe)
);

always_ff @(posedge clk_50 or negedge rst_n) begin
	if (!rst_n)		sync_pipe 		<= 3'b000; else
	begin			sync_pipe[0] 	<= ack_from_phy;
		            sync_pipe[1] 	<= sync_pipe[0];
					sync_pipe[2] 	<= sync_pipe[1];
	end
end

endmodule