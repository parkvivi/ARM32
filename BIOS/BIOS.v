module BIOS
(
	// Entrada :: Sinais de Controle
	input wire clock_leitura,
	
	// Entrada :: Endereço de Leitura
	input wire [31:0] endereco,
	
	// Saída :: Instrução
	output reg [31:0] instrucao
);

	reg [31:0] bios[2047:0];
	
	initial
		begin
		$readmemb("BIOS.txt", bios);
		end
		
	always @ (clock_leitura)
		begin
		instrucao <= bios[endereco];
		end

endmodule 