module led_controller #(
	parameter DATA_W = 8,
	parameter ADDR_W = 8
) (
	input logic 				clk,
	input logic 				rst_n,
	input logic 				write_en,
	input logic [ADDR_W-1:0]	mem_addr,
	input logic [DATA_W-1:0] 	mem_write_data,
	output logic [DATA_W-1:0]	mem_read_data, 
	output logic [DATA_W-1:0]	leds           
);

localparam LEDS_ADDR = 8'hFD;

logic [DATA_W-1:0] leds_reg;

assign mem_read_data = (mem_addr == LEDS_ADDR) ? leds_reg : '0;
assign leds = leds_reg;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)					leds_reg <= '0;
	else if(write_en && (mem_addr == LEDS_ADDR))
		leds_reg <= mem_write_data;
end

endmodule