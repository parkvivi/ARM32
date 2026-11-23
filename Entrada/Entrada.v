module Entrada
(
// Entradas :: Chaves FPGA
input wire [7:0] Chaves,

// Saidas :: Dado
output reg [31:0] Dado,

// Saídas :: LEDs dos Displays de 7 Segmentos
output wire [27:0] Segmentos
);
	
	wire [3:0] MilharBCD, CentenaBCD, DezenaBCD, UnidadeBCD;
	
	always @ (*)
		begin
		Dado <= {24'b0, Chaves[7:0]};
		end
		
	BinarioBCD BinarioBCD	(
									.Dado(Dado[13:0]),
									.Milhar(MilharBCD),
									.Centena(CentenaBCD),
									.Dezena(DezenaBCD),
									.Unidade(UnidadeBCD)
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