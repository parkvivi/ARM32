module PC 
(
// Entradas :: Endereço da Nova Instrução
input wire [31:0] NovoEndereco, EnderecoInterrupcao,

// Entradas :: Sinais de Controle
input wire CLK, CTRLHalt, Reset, Interrupcao,

// Saídas :: Endereço da Instrução Atual	
output reg [31:0] EnderecoAtual
);
	
	initial
		begin
		EnderecoAtual = 32'd0;
		end

	always @ (posedge CLK)
		begin
		if (Reset == 1'b1)
			begin
			EnderecoAtual <= 32'd0;
			end
		else
			begin
			if (Interrupcao == 1'b1)
				begin
				EnderecoAtual <= EnderecoInterrupcao;
				end
			else
				begin
				if (CTRLHalt == 1'b0)
					begin
					EnderecoAtual <= NovoEndereco;
					end
				end
			end
		end

endmodule 