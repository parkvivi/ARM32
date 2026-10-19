module MemInstrucoes
(	// Entradas :: Endereço da Instrução Atual, Endereço de Escrita
	input [31:0] EnderecoAtual, EnderecoEscrita,
	
	// Entradas :: Dado para Escrita
	input [31:0] DadoEscrita,
	
	// Entradas :: Sinais de Controle
	input CTRLEscritaInstr, CLKFPGA, CLK,
	
	// Saídas :: Instrução Atual
	output reg [31:0] Instrucao
);

	// Variáveis Auxiliares :: Memória RAM
	reg [31:0] instr_ram[1023:0];

	initial
		begin
		$readmemb("MemInstrDados.txt", instr_ram);
		end

	always @ (posedge CLKFPGA)
		begin
		Instrucao <= instr_ram[EnderecoAtual];
		end
		
	always @ (posedge CLK)
		begin
		if (CTRLEscritaInstr == 1'b1)
			instr_ram[EnderecoEscrita] <= DadoEscrita;
		end

endmodule 