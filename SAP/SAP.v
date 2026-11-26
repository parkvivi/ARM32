module SAP
(
	// Entrada :: Dado de Escrita
	input wire [31:0] novo_endereco,
	
	// Entradas :: Sinais de Controle
	input wire clock_processador, clock_leitura, escreve_endereco,
	
	// Saída :: Dado de Leitura
	output reg [31:0] endereco
);
	
	reg [31:0] endereco_sap;

always @ (posedge clock_leitura)
	begin
	endereco <= endereco_sap;
	end
	
always @ (posedge clock_processador)
	begin
	if (escreve_endereco == 1'b1)
		begin
		endereco_sap <= novo_endereco;
		end
	end
	
endmodule 