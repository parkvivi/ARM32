module Temporizador
(
	// Entradas :: Sinais de Controle
	input wire clock_processador,
	input wire reset,
	input wire escreve_quantum,
	input wire habilita_interrupcao,
	input wire modo_processador,
    
	// Entradas :: Dados
	input wire [31:0] novo_quantum,
    
	// Saída :: Sinal de Interrupção
	output wire interrupcao
);

	reg [31:0] quantum;
	reg [31:0] contador;
	
	localparam USUARIO = 1'b0, PREEMPCAO = 1'b1;

	wire habilita_contador = (modo_processador == USUARIO) && (habilita_interrupcao == PREEMPCAO);
	wire estouro_quantum = (quantum > 32'b0) && (contador >= quantum - 32'd1);
	
	assign interrupcao = habilita_contador && estouro_quantum;
	
	always @ (posedge clock_processador)
		begin
		if (reset == 1'b1)
			begin
			quantum <= 32'b0;
			contador <= 32'b0;
			end 
		else
			begin
			if (escreve_quantum == 1'b1)
				begin
				quantum <= novo_quantum;
				contador <= 32'b0;
				end 
			else if ((habilita_contador == 1'b1) && (estouro_quantum == 1'b0))
				begin
				contador <= contador + 32'd1;
				end
			end
		end

endmodule 