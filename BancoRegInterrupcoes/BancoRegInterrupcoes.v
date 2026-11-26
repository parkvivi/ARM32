module BancoRegInterrupcoes
(	
	// Entradas :: Dados para Escrita
	input wire [31:0] DadoEscritaIR1, DadoEscritaIR2,
	
	// Entradas :: Sinais de Controle
	input wire [2:0] CTRLEscritaIR,
	input wire CLK, CLKFPGA, Interrupcao, Reset,
	
	// Saídas :: Dados de Leitura
	output reg [31:0] DadoLeituraIR1, DadoLeituraIR2,
	output reg DadoLeituraIR0, DadoLeituraIR3
);
	
	reg [31:0] DadoIR1, DadoIR2;
	reg DadoIR0, DadoIR3;
	
	localparam	BUP = 3'b001, QTM = 3'b010, RK = 3'b011, RUP = 3'b100, SVC = 3'b101,
					USUARIO = 1'b0, KERNEL = 1'b1, PREEMPCAO = 1'b1;
	
	initial
		begin
		DadoIR0 = KERNEL;
		DadoIR3 = ~PREEMPCAO;
		end
	
	always @ (posedge CLKFPGA)
		begin
		DadoLeituraIR0 <= DadoIR0;	// flags USUÁRIO (0) / KERNEL (1)
		DadoLeituraIR1 <= DadoIR1;	// PC do PROGRAMA
		DadoLeituraIR2 <= DadoIR2;	// PC do KERNEL
		DadoLeituraIR3 <= DadoIR3;	// flag PREEMPÇÃO (1)
		end
		
	always @ (posedge CLK)
		begin
		if (Reset == 1'b1)
			begin
			DadoIR0 <= KERNEL;
			DadoIR1 <= 32'd0;
			DadoIR2 <= 32'd0;
			DadoIR3 <= ~PREEMPCAO;
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
				case (CTRLEscritaIR[2:0])
					BUP:	begin
							DadoIR0 <= USUARIO;
							DadoIR2 <= DadoEscritaIR2;
							end
					QTM:	begin
							DadoIR3 <= PREEMPCAO;
							end
					RK:	begin
							DadoIR0 <= KERNEL; // tirar daqui depois!
							DadoIR3 <= ~PREEMPCAO;
							end
//					RUP:	begin
//							DadoIR0 <= USUARIO;
//							end
//					SVC:	begin
//							DadoIR0 <= KERNEL;
//							end
					default:	begin end
				endcase
				end
			end
		end

endmodule 