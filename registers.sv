module registers #(
	parameter WIDTH = 8,
	parameter ADDR_W = 4
) (
	input logic clk,
	input logic rst_n,
	input logic write_en,
	input logic [ADDR_W-1:0] 	read_addr_1,
	input logic [ADDR_W-1:0] 	read_addr_2,
	input logic [ADDR_W-1:0] 	write_addr,
	input logic [WIDTH-1:0] 	write_data,
	output logic [WIDTH-1:0] 	read_data_1,
	output logic [WIDTH-1:0] 	read_data_2
);

logic [WIDTH-1:0] reg_block [2**ADDR_W];

assign read_data_1 	= reg_block[read_addr_1];
assign read_data_2 	= reg_block[read_addr_2];

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)	begin
					for(int i = 0; i < (2**ADDR_W); i++)
						reg_block[i] <= '0;
				end	else
	if(write_en)	reg_block[write_addr] <= write_data;
end

endmodule
