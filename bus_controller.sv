module bus_controller #(
	parameter ADDR_W 		= 8,
	parameter DATA_W 		= 8,
	parameter SPI_ADDR_W 	= 6
) (
	//CPU Interface
	input logic	[ADDR_W-1:0]	cpu_addr,
	input logic 				cpu_read_en,
	input logic					cpu_write_en,
	output logic [DATA_W-1:0]	cpu_read_data,
	output logic				cpu_mem_ready,
	
	//RAM Interface
	input logic [DATA_W-1:0]	ram_read_data,
	output logic				ram_write_en,
	
	//SPI Interface (Sensor)
	input logic		[DATA_W-1:0]			spi_read_data,
	input logic								spi_ack,
	output logic 	[SPI_ADDR_W-1:0]		spi_addr,
	output logic							spi_read_en,
	output logic							spi_write_en,
	
	// GPIO & Timer Interface - ACUM CURATATE
    input  logic [DATA_W-1:0] timer_read_data,
    input  logic [DATA_W-1:0] switch_read_data,
    input  logic [DATA_W-1:0] led_read_data,      // Port dedicat LED
    input  logic [DATA_W-1:0] gpio_ext_read_data, // Port dedicat pini externi
    
    output logic              timer_write_en,
    output logic              led_write_en,
    output logic              gpio_ext_write_en   // Enable dedicat
);

// --- LOGICA DE SCRIERE (Write Enables) ---
assign ram_write_en      = (cpu_write_en & ~cpu_addr[7]);
assign spi_write_en      = (cpu_write_en & (cpu_addr[7] & ~cpu_addr[6]));

// Harta de memorie pentru periferice (Zona 0xF8 - 0xFF)
assign timer_write_en    = (cpu_write_en & (cpu_addr == 8'hF8 | cpu_addr == 8'hF9));
assign led_write_en      = (cpu_write_en & (cpu_addr == 8'hFC | cpu_addr == 8'hFD));
assign gpio_ext_write_en = (cpu_write_en & (cpu_addr == 8'hFE | cpu_addr == 8'hFF));

assign spi_read_en 		= (cpu_read_en & (cpu_addr[7] & ~cpu_addr[6]));
assign spi_addr			= cpu_addr[SPI_ADDR_W-1:0];
assign cpu_mem_ready = ((cpu_addr[7] & ~cpu_addr[6]) & (cpu_read_en | cpu_write_en)) ? spi_ack : 1'b1;

always_comb begin
   cpu_read_data = 0;
   if(cpu_read_en)
       casez(cpu_addr)
           8'b0???????:    cpu_read_data = ram_read_data;
           8'b10??????:    cpu_read_data = spi_read_data;
           // Adresele 1111_XXXX (0xF0 - 0xFF)
           8'b1111_100?:   cpu_read_data = timer_read_data;    // 0xF8, 0xF9
           8'b1111_101?:   cpu_read_data = switch_read_data;   // 0xFA, 0xFB
           8'b1111_110?:   cpu_read_data = led_read_data;      // 0xFC, 0xFD
           8'b1111_111?:   cpu_read_data = gpio_ext_read_data; // 0xFE, 0xFF
           default:        cpu_read_data = 8'h00;
       endcase
end

endmodule