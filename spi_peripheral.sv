module spi_peripheral #(
	parameter DATA_W 		= 8,
	parameter SPI_ADDR_W 	= 6
) (
	input logic 					clk_50,          // Ceasul rapid al CPU
	input logic 					clk_1,           // Ceasul lent (1MHz)
	input logic 					clk_1_shifted,   // Ceasul lent defazat (220 deg)
	input logic 					rst_n,
	
	// Interfața Bus Controller
	input logic [SPI_ADDR_W-1:0]	spi_addr,
	input logic						spi_read_en,
	input logic						spi_write_en,
	input logic [DATA_W-1:0]		write_data,
	output logic [DATA_W-1:0]		read_data,
	output logic					spi_ack,         // Ack sincronizat la 50MHz
	
	// Pinii fizici
	input logic						miso,
	output logic					mosi,
	output logic					sclk,
	output logic					cs_n,
	output logic					spi_oe
);

	logic req_wire;
	logic rw_n_wire;
	logic ack_from_phy;
	logic [2:0] sync_pipe; // <-- Extins la 3 biți pentru stocarea istoricului

	assign req_wire = spi_read_en | spi_write_en;
	assign rw_n_wire = spi_read_en;

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

	// Sincronizator + Istoric pentru Edge Detector
	always_ff @(posedge clk_50 or negedge rst_n) begin
		if (!rst_n) begin
			sync_pipe <= 3'b000;
		end else begin
			sync_pipe[0] <= ack_from_phy; // Captură asincronă
			sync_pipe[1] <= sync_pipe[0]; // Sincronizare pe 50MHz
			sync_pipe[2] <= sync_pipe[1]; // Stocarea stării din ciclul anterior
		end
	end

	// RISING EDGE DETECTOR: 
	// Dă '1' doar când semnalul tocmai s-a făcut '1' (sync_pipe[1]), 
	// dar în ciclul precedent era '0' (~sync_pipe[2]).
	assign spi_ack = sync_pipe[1] & ~sync_pipe[2];

endmodule