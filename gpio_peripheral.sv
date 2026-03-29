module gpio_peripheral #(
	parameter WIDTH = 8,
	parameter ADDR_W = 8
) (
	input logic 				clk,
	input logic 				rst_n,
	input logic 				mem_write_en,
	input logic [ADDR_W-1:0]	mem_addr,
	input logic [WIDTH-1:0]		mem_write_data,
	output logic [WIDTH-1:0]	mem_read_data,
	inout wire	[WIDTH-1:0]		gpio_pins
);

localparam DDR_ADDRESS = 8'hFE;
localparam PORT_ADDRESS = 8'hFF;

logic [WIDTH-1:0] ddr_reg, port_reg;

assign mem_read_data = (mem_addr == DDR_ADDRESS) ? ddr_reg : (mem_addr == PORT_ADDRESS) ? gpio_pins : '0;

genvar i;
generate
    for (i = 0; i < WIDTH; i++) begin : gpio_tristate
        assign gpio_pins[i] = ddr_reg[i] ? port_reg[i] : 1'bz;
    end
endgenerate

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)					ddr_reg <= '0;				else
	if(mem_write_en)
	if(mem_addr == DDR_ADDRESS)	ddr_reg <= mem_write_data;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)						port_reg <= '0;				else
	if(mem_write_en)
	if(mem_addr == PORT_ADDRESS)	port_reg <= mem_write_data;
end

endmodule