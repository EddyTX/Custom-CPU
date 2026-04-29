module data_memory #(
	parameter ADDR_W = 8,
	parameter DATA_W = 8
) (
	input logic 				clk,
	input logic 				write_en,
	input logic [ADDR_W-1:0] 	addr,
	input logic [DATA_W-1:0]	write_data,
	output logic [DATA_W-1:0]	read_data
);

logic [DATA_W-1:0] ram [2**ADDR_W];

assign read_data = ram[addr];

always_ff @(posedge clk) begin
	if(write_en)	ram[addr] <= write_data;
end

endmodule