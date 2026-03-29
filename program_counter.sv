module program_counter #(
	parameter PC_W = 8
) (
	input logic clk,
	input logic rst_n,
	input logic jump_en,
	input logic pc_en,
	input logic [PC_W-1:0] jump_addr,
	output logic [PC_W-1:0] pc_out
);

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)		pc_out <= 0;			else
	if(pc_en)
	if(jump_en)		pc_out <= jump_addr;	else
					pc_out <= pc_out + 1;
end

endmodule