module timer #(
	parameter PRESCALER = 49999,			//assures that the timer increments every 1ms
	parameter DATA_W	= 8,
	parameter BASE_ADDR = 8'hFA
) (
	input logic 				clk,
	input logic 				rst_n,
	input logic 				mem_write_en,
	input logic [DATA_W-1:0] 	mem_addr,
	input logic [DATA_W-1:0] 	mem_write_data,
	output logic [DATA_W-1:0]	mem_read_data,
	output logic 				timer_done
);

localparam timer_high_address = BASE_ADDR;
localparam timer_low_address = BASE_ADDR + 1;

logic [15:0] 		tick_reg;
logic [15:0] 		timer;
logic [DATA_W-1:0] 	timer_target_h;
logic [DATA_W-1:0] 	timer_target_l;
logic [15:0] 		target;
logic 				tick;

assign tick 			=	(tick_reg == PRESCALER);
assign target 			= 	{timer_target_h, timer_target_l};
assign timer_done 		= 	(timer == target) && (target != 16'b0);
assign mem_read_data 	= 	(mem_addr == timer_high_address) ? timer_target_h :
							(mem_addr == timer_low_address)  ? timer_target_l : '0;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)					tick_reg <= '0;	else
	if(tick)					tick_reg <= '0;	else
								tick_reg <= tick_reg + 1;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)							timer_target_h <= '0;	else
	if(mem_write_en)
	if(mem_addr == timer_high_address)	timer_target_h <= mem_write_data;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)							timer_target_l <= '0;	else
	if(mem_write_en)
	if(mem_addr == timer_low_address)	timer_target_l <= mem_write_data;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)				timer <= '0;	else
	if(timer_done)			timer <= '0;	else
	if(tick)				timer <= timer + 1;
end

endmodule