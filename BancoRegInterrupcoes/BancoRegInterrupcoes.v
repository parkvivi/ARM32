module BancoRegInterrupcoes
(	
	// Entradas :: Dados para Escrita
	input wire [31:0] DadoEscritaIR0, DadoEscritaIR1, DadoEscritaIR2,
	
	// Entradas :: Sinais de Controle
	input wire [1:0] CTRLEscritaIR,
	input wire CLK, CLKFPGA,
	
	// Saídas :: Dados de Leitura
	output reg [31:0] DadoLeituraIR0, DadoLeituraIR1, DadoLeituraIR2
);

	reg [31:0] DadoIR0, DadoIR1, DadoIR2;
	
always @ (posedge CLKFPGA)
	begin
	DadoLeituraIR0 <= DadoIR0;
	DadoLeituraIR1 <= DadoIR1;
	DadoLeituraIR2 <= DadoIR2;
	end
	
always @ (posedge CLK)
	begin
	case (CTRLEscritaIR[1:0])
		2'b01:	begin
					DadoIR0 <= DadoEscritaIR0;
					end
		2'b10:	begin
					DadoIR1 <= DadoEscritaIR1;
					end
		2'b11:	begin
					DadoIR2 <= DadoEscritaIR2;
					end
		default:	begin
					end
	endcase
	end

endmodule 