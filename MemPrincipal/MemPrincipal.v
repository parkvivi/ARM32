module MemPrincipal
(	// Entradas :: Endereços para Leitura e Escrita
	input [31:0] EndLeitura, EndEscrita,	

	// Entradas :: Dado para Escrita
	input [31:0] DadoMemEscrita,
	
	// Entradas :: Sinais de Controle
	input CTRLEscritaMem, CLK, CLKFPGA,
	
	// Saída :: Dado Lido
	output reg [31:0] DadoMemoria
);
	
	// Variáveis Auxiliares :: Memória
	reg [31:0] ram[1023:0];
	
	always @ (posedge CLKFPGA)
		begin
		DadoMemoria = ram[EndLeitura];
		end
		
	always @ (posedge CLK)
		begin
		if (CTRLEscritaMem == 1'b1)
			ram[EndEscrita] <= DadoMemEscrita;
		end
	
endmodule 