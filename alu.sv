//Adunare, Scadere, AND, OR => 2 biti de OPCODE
module alu #(
	parameter WIDTH = 8
) (
	input	logic [WIDTH-1:0] 	A,
	input	logic [WIDTH-1:0] 	B,
	input	logic [2:0]			opcode,
	output 	logic [WIDTH-1:0]	result,
	output	logic				carry_out,
	output	logic				zero_f,
	output	logic 				neg_f
);

localparam ADD 	= 3'b000;
localparam SUB 	= 3'b001;
localparam AND 	= 3'b010;
localparam OR 	= 3'b011;
localparam SHL	= 3'b100;
localparam SHR	= 3'b101;

assign carry_out = (opcode == ADD) ? (result < A) : 1'b0;
assign zero_f	= ~|result;
assign neg_f	= result[WIDTH-1]; 

always_comb begin
	result = 'x;
	
	case(opcode)
		ADD:	result = A + B;
		SUB:	result = A - B;
		AND:	result = A & B;
		OR:		result = A | B;
		SHL:	result = A << B;
		SHR:	result = A >> B;
	endcase
end

endmodule