module Saida
(
// Entradas :: Dado
input wire [31:0] DadoEntrada,

// Entradas :: Sinais de Controle
input wire CTRLSaida,

// Saídas :: LEDs dos Displays de 7 Segmentos
output wire [55:0] Segmentos
);
	
	wire [3:0] DezenaMilhaoBCD, MilhaoBCD, CentenaMilharBCD, DezenaMilharBCD, MilharBCD, CentenaBCD, DezenaBCD, UnidadeBCD;
	reg [31:0] DadoSaida;
	
	initial
		begin
		DadoSaida = 32'd0;
		end
		
	always @ (*)
		begin
		if (CTRLSaida == 1'b1)
			begin
			DadoSaida <= DadoEntrada;
			end
		else
			begin
			DadoSaida <= 32'd0;
			end
		end
	
	BinarioBCD BinarioBCD	(
									.Dado(DadoSaida[26:0]),
									.DezenaMilhao(DezenaMilhaoBCD),
									.Milhao(MilhaoBCD),
									.CentenaMilhar(CentenaMilharBCD),
									.DezenaMilhar(DezenaMilharBCD),
									.Milhar(MilharBCD),
									.Centena(CentenaBCD),
									.Dezena(DezenaBCD),
									.Unidade(UnidadeBCD)
									);
	
	BCD7Seg DezenaMilhao		(
							.BCD(DezenaMilhaoBCD),
							.Segmentos(Segmentos[55:49])
							);
							
	BCD7Seg Milhao		(
							.BCD(MilhaoBCD),
							.Segmentos(Segmentos[48:42])
							);
							
	BCD7Seg CentenaMilhar		(
							.BCD(CentenaMilharBCD),
							.Segmentos(Segmentos[41:35])
							);
							
	BCD7Seg DezenaMilhar		(
							.BCD(DezenaMilharBCD),
							.Segmentos(Segmentos[34:28])
							);
							
	BCD7Seg Milhar		(
							.BCD(MilharBCD),
							.Segmentos(Segmentos[27:21])
							);
	
	BCD7Seg Centena	(
							.BCD(CentenaBCD),
							.Segmentos(Segmentos[20:14])
							);
							
	BCD7Seg Dezena		(
							.BCD(DezenaBCD),
							.Segmentos(Segmentos[13:7])
							);
							
	BCD7Seg Unidade	(
							.BCD(UnidadeBCD),
							.Segmentos(Segmentos[6:0])
							);

endmodule 