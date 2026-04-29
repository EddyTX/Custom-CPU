module rom #(
    parameter ADDR_W = 8,
    parameter DATA_W = 16
)(
    input  logic              clk,
    input  logic [ADDR_W-1:0] read_addr,
    output logic [DATA_W-1:0] instruction
);

    // Atributul magic care leaga memoria hardware de fisierul MIF
    (* ram_init_file = "program.mif" *) logic [DATA_W-1:0] rom_array [0:(2**ADDR_W)-1];

    always_ff @(posedge clk) begin
        instruction <= rom_array[read_addr];
    end

endmodule