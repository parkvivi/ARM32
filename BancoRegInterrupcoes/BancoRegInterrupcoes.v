module BancoRegInterrupcoes
(	
	// Entradas :: Dados para Escrita
	input wire [31:0] DadoEscritaIR1, DadoEscritaIR2,
	
	// Entradas :: Sinais de Controle
	input wire [1:0] CTRLEscritaIR,
	input wire CLK, CLKFPGA, Interrupcao, Reset,
	
	// Saídas :: Dados de Leitura
	output reg [31:0] DadoLeituraIR0, DadoLeituraIR1, DadoLeituraIR2, DadoLeituraIR3
);

	reg [31:0] DadoIR0, DadoIR1, DadoIR2, DadoIR3;
	
	always @ (posedge CLKFPGA)
		begin
		DadoLeituraIR0 <= DadoIR0;
		DadoLeituraIR1 <= DadoIR1;
		DadoLeituraIR2 <= DadoIR2;
		DadoLeituraIR3 <= DadoIR3;
		end
		
	always @ (posedge CLK)
		begin
		if (Reset == 1'b1)
			begin
			DadoIR0 <= 32'd0;
			DadoIR1 <= 32'd0;
			DadoIR2 <= 32'd0;
			DadoIR3 <= 32'd0;
			end
		else
			begin
			if (Interrupcao == 1'b1)
				begin
				DadoIR0 <= 32'd1;
				DadoIR1 <= DadoEscritaIR1;
				DadoIR3 <= 32'd0;
				end
			else
				begin
				case (CTRLEscritaIR[1:0])
					2'b01:	begin
								DadoIR0 <= 32'b0;
								DadoIR2 <= DadoEscritaIR2;
								end
					2'b10:	begin
								DadoIR3 <= 32'd1;
								end
					2'b11:	begin
								DadoIR3 <= 32'd0;
								end
					default:	begin end
				endcase
				end
			end
		end

endmodule 