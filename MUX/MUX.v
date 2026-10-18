module MUX
(
// Entradas :: Dados
input wire [31:0] Dado1, Dado2, Dado3, Dado4, Dado5, Dado6, Dado7, Dado8,

// Entradas :: Entrada de Seleção
input wire [2:0] Selecao,

// Saídas :: Dado de Saída
output reg [31:0] DadoSaida
);

	always @ (*)
		begin
		case (Selecao[2:0])
			3'b000:	DadoSaida <= Dado1;
			3'b001:	DadoSaida <= Dado2;
			3'b010:	DadoSaida <= Dado3;
			3'b011:	DadoSaida <= Dado4;
			3'b100:	DadoSaida <= Dado5;
			3'b101:	DadoSaida <= Dado6;
			3'b110:	DadoSaida <= Dado7;
			3'b111:	DadoSaida <= Dado8;
		endcase
		end
					
endmodule 