module control_unit #(
	parameter DATA_W = 16
) (
	input logic					clk,
	input logic					rst_n,
	input logic 				zero_f,
	input logic [DATA_W-1:0] 	instruction,
	input logic					irq,
	input logic					mem_ready,
	output logic 				write_en,
	output logic 				jump_en,
	output logic				use_imm,
	output logic [2:0]			alu_opcode,
	output logic				mem_write_en,
	output logic				mem_read_en,
	output logic 				mem_to_reg,
	output logic				pc_en,
	output logic				save_pc_en,
	output logic				restore_pc_en,
	output logic				isr_active
);

typedef enum logic [2:0] {
	FETCH,
	EXECUTE,
	ISR,
	STALL
} state_t;
state_t current_state;

logic [3:0] opcode;
logic 		zero_flag_reg;
logic 		gie;
logic 		irq_reg;
logic 		is_add, is_sub, is_and	,
			is_or, is_jmp, is_jmpz	,
			is_ldi, is_load, is_store,
			is_shl, is_shr, is_reti;
logic 		zero_flag_backup;

assign opcode 	= instruction[DATA_W-1:DATA_W-4];
assign is_add 	= (opcode == 4'b0000);
assign is_sub 	= (opcode == 4'b0001);
assign is_and 	= (opcode == 4'b0010);
assign is_or 	= (opcode == 4'b0011);
assign is_shl	= (opcode == 4'b0100);
assign is_shr	= (opcode == 4'b0101);
assign is_ldi	= (opcode == 4'b0110);
assign is_load	= (opcode == 4'b0111);
assign is_store	= (opcode == 4'b1000);
assign is_jmp	= (opcode == 4'b1001);
assign is_jmpz	= (opcode == 4'b1010);
assign is_reti 	= (opcode == 4'b1011);


assign write_en 		= 	(current_state == EXECUTE) & (is_add | is_sub | is_and | is_or | is_ldi |
							is_shl | is_shr | is_load) & mem_ready;
assign jump_en 			= 	is_jmp | (is_jmpz & zero_flag_reg) | (current_state == ISR);
assign alu_opcode 		= 	opcode[2:0];
assign use_imm 			= 	is_ldi;
assign mem_write_en 	= 	(current_state == EXECUTE) & is_store;
assign mem_read_en		= 	(current_state == EXECUTE) & is_load;
assign mem_to_reg		= 	is_load;
assign pc_en        	= 	((current_state == EXECUTE) & mem_ready) | (current_state == ISR);
assign save_pc_en		= 	(current_state == ISR);
assign restore_pc_en	= 	(current_state == EXECUTE) & is_reti;
assign isr_active 		= 	(current_state == ISR);

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) 										current_state <= FETCH;	else
	case (current_state)
		FETCH:      								current_state <= EXECUTE;
		EXECUTE:
			if ((is_load | is_store) & ~mem_ready)	current_state <= EXECUTE;	else
			if (irq_reg && gie) 					current_state <= ISR;		else
													current_state <= FETCH;
		ISR:  		current_state <= FETCH;
		default:    current_state <= FETCH;
	endcase
end

always_ff @(posedge clk or negedge rst_n) begin
	if (~rst_n) 			zero_flag_backup <= 1'b0;
	else if (save_pc_en) 	zero_flag_backup <= zero_flag_reg;
end

always_ff @(posedge clk or negedge rst_n) begin
	if (~rst_n) 				zero_flag_reg <= 1'b0;				else
	if (restore_pc_en) 			zero_flag_reg <= zero_flag_backup;	else
	if ((current_state == EXECUTE) & mem_ready) begin
		if (is_add | is_sub | is_and | is_or | is_shl | is_shr)
								zero_flag_reg <= zero_f;
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n)								gie <= 1;	else
	if(current_state == ISR) 				gie <= 0;	else
	if(current_state == EXECUTE & is_reti)	gie <= 1;
end

always_ff @(posedge clk or negedge rst_n) begin
	if (~rst_n) 					irq_reg <= 1'b0;	else
	if (irq) 						irq_reg <= 1'b1;	else
	if (current_state == ISR) 		irq_reg <= 1'b0;
end

endmodule