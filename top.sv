module top #(
	parameter DATA_W = 8,    
	parameter INST_W = 16,   
	parameter REG_ADDR_W = 4,
	parameter MEM_ADDR_W = 8 
) (
	input logic clk,
	input logic rst_n,
	inout wire [DATA_W-1:0] gpio_pins,
	output logic [DATA_W-1:0] leds_red
);

logic use_imm_wire;
logic mem_to_reg_wire;
logic [DATA_W-1:0] reg_write_data_wire;

logic [MEM_ADDR_W-1:0] pc_wire;          
logic [INST_W-1:0]     instruction_wire; 

logic [DATA_W-1:0]     reg_data1_wire;
logic [DATA_W-1:0]     reg_data2_wire;
logic [DATA_W-1:0]     alu_result_wire;

logic                  zero_f_wire;
logic                  write_en_wire;
logic                  jump_en_wire;
logic [2:0]            alu_opcode_wire;
logic				   pc_en_wire;

logic                  mem_write_en;
logic [MEM_ADDR_W-1:0] mem_addr;
logic [DATA_W-1:0]     mem_write_data;
logic [DATA_W-1:0]     ram_read_data;
logic [DATA_W-1:0]     gpio_read_data;
logic [DATA_W-1:0]     	mem_read_data;
logic [DATA_W-1:0]  	led_read_data;

logic irq_wire;
logic save_pc_wire;
logic restore_pc_wire;
logic isr_active_wire;
logic [MEM_ADDR_W-1:0] final_jump_addr;

assign mem_read_data = (mem_addr == 8'hFD) ? led_read_data :  // LED-uri la 0xFD
                       (mem_addr >= 8'hFE) ? gpio_read_data : // GPIO la 0xFE/FF
                       ram_read_data;                         // Restul e RAM
assign reg_write_data_wire = mem_to_reg_wire ? mem_read_data : (use_imm_wire ? instruction_wire[7:0] : alu_result_wire);
assign mem_addr       = reg_data2_wire;
assign mem_write_data = reg_data1_wire;
assign final_jump_addr = isr_active_wire ? 8'h02 : instruction_wire[DATA_W-1:0];

alu #( 
	.WIDTH(DATA_W)
) alu_inst (
	.A(reg_data1_wire),
	.B(reg_data2_wire),
	.opcode(alu_opcode_wire),
	.result(alu_result_wire),
	.zero_f(zero_f_wire)
);

registers #( 
	.WIDTH(DATA_W), 
	.ADDR_W(REG_ADDR_W)
) registers_inst (
	.clk(clk), 
	.rst_n(rst_n), 
	.write_en(write_en_wire),
	.read_addr_1(instruction_wire[7:4]),
	.read_addr_2(instruction_wire[3:0]),
	.write_addr(instruction_wire[11:8]),
	.write_data(reg_write_data_wire),
	.read_data_1(reg_data1_wire),
	.read_data_2(reg_data2_wire)
);

program_counter #( 
.PC_W(MEM_ADDR_W)
) pc_inst (
	.clk(clk), 
	.rst_n(rst_n), 
	.jump_en(jump_en_wire),
	.jump_addr(final_jump_addr),
	.pc_out(pc_wire),
	.pc_en(pc_en_wire),
	.save_pc_en(save_pc_wire),
    .restore_pc_en(restore_pc_wire)
);

control_unit #( 
	.DATA_W(INST_W)
) cu_inst ( 
	.clk(clk),
	.rst_n(rst_n),
	.pc_en(pc_en_wire),
	.zero_f(zero_f_wire),
	.instruction(instruction_wire),
	.write_en(write_en_wire),
	.jump_en(jump_en_wire),
	.alu_opcode(alu_opcode_wire),
	.use_imm(use_imm_wire),
	.mem_write_en(mem_write_en),
	.mem_to_reg(mem_to_reg_wire),
	.irq(irq_wire),
    .save_pc_en(save_pc_wire),
    .restore_pc_en(restore_pc_wire),
    .isr_active(isr_active_wire)
);

rom #( 
	.ADDR_W(MEM_ADDR_W), 
	.DATA_W(INST_W)
) rom_inst (
	.clk(clk),
	.read_addr(pc_wire),
	.instruction(instruction_wire)
);

data_memory #( 
	.ADDR_W(MEM_ADDR_W), 
	.DATA_W(DATA_W) 
) ram_inst (
    .clk(clk), 
	.write_en(mem_write_en), 
	.addr(mem_addr),
    .write_data(mem_write_data), 
	.read_data(ram_read_data)
);

gpio_peripheral #(
	.WIDTH(DATA_W), 
	.ADDR_W(MEM_ADDR_W)
) gpio_inst (
    .clk(clk), 
	.rst_n(rst_n), 
	.mem_write_en(mem_write_en), 
	.mem_addr(mem_addr),
    .mem_write_data(mem_write_data), 
	.mem_read_data(gpio_read_data), 
	.gpio_pins(gpio_pins)
);

led_controller #(
    .DATA_W(DATA_W),
    .ADDR_W(MEM_ADDR_W)
) led_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .write_en       (mem_write_en),
    .mem_addr       (mem_addr),
    .mem_write_data (mem_write_data),
    .mem_read_data  (led_read_data),
    .leds           (leds_red)
);

timer #(
	.PRESCALER(49999),
	.DATA_W(DATA_W)
) timer_inst (
	.clk(clk),
	.rst_n(rst_n),
	.mem_write_en(mem_write_en),
	.mem_addr(mem_addr),
	.mem_write_data(mem_write_data),
	.timer_done(irq_wire)
);

endmodule