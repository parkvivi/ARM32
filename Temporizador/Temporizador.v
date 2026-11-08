module Temporizador
(
	// Entradas :: Sinais de Controle
	input wire clock_processador,
	input wire reset,
	input wire escreve_quantum,
	input wire habilita_interrupcao,
    
	// Entradas :: Dados
	input wire [31:0] novo_quantum,
    
	// Saída :: Sinal de Interrupção
	output reg interrupcao
);

	reg [31:0] quantum;
	reg [31:0] contador;

	always @ (posedge clock_processador or posedge reset)
		begin
		if (reset == 1'b1)
			begin
			quantum <= 32'b0;
			contador <= 32'b0;
			interrupcao <= 1'b0;
			end 
		else
			begin
			if (escreve_quantum == 1'b1)
				begin
				quantum <= novo_quantum;
				contador <= 32'b0;
				interrupcao <= 1'b0;
            end 
			else
				begin
				if (quantum > 32'b0)
					begin
					if (contador >= quantum)
						begin
						contador <= 32'b0;
						interrupcao <= habilita_interrupcao;
						end 
					else
						begin
						contador <= contador + 1'b1;
						interrupcao <= 1'b0;
						end
					end
            else
					begin
					contador <= 32'b0;
					interrupcao <= 1'b0;
					end
				end
        end
    end

endmodule 