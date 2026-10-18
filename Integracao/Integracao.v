module Integracao
(
// Entradas
input wire [7:0] ChaveDado,
input wire CLKFPGA, ChaveClock, ChaveReset,

// Saídas
output wire [27:0] Segmentos, SegmentosEntrada,
output wire LEDIN, LEDOUT,

// Saídas :: LCD
output wire LCD_RS, LCD_E, LCD_RW,
inout wire [7:0] DATA_BUS
);

	// Conexões Intermediárias
	wire [31:0] NovoEndereco, EnderecoAtual, ProximoEndereco, Instrucao, EndSelecionado, Imediato, FlagsNZCVEstendidas;
	wire [31:0] DadoEntrada, DadoRegLeitura1, DadoRegLeitura2, DadoSelecionado, DadoMemoria, DadoRegEscrita, SaidaULA, DadoCPSREscrita, DadoHD;
	wire [31:0] DadoLeituraIR0, DadoLeituraIR1, DadoLeituraIR2;
	wire [7:0] Opcode;
	wire [4:0] RN, RM, RD;
	wire [3:0] Cond, NovasFlags, FlagsNZCV;
	wire Inibe;
	
	// Conexões Intermediárias: Sinais de Controle
	wire [3:0] CTRLOpULA;
	wire [2:0] CTRLDesvio, CTRLDadoImediato, CTRLEndMem, CTRLDadoReg, CTRLDadoCPSR;
	wire [1:0] CTRLEscritaIR;
	wire CTRLEscritaReg, CTRLEscritaCPSR, CTRLEscritaMem, CTRLEscritaInstr, CTRLEscritaHD;
	wire CTRLHalt, CTRLSaida, CTRLCLK, CTRLLCD;
	
	// Conexões Intermediárias: Clock
	wire CLK, CLKManual;

	localparam Zero = 32'b0, Um = 32'b00000000000000000000000000000001;
		
	PC PC	(	.CTRLHalt(CTRLHalt),
				.CLK(CLK),
				.Reset(ChaveReset),
				.NovoEndereco(NovoEndereco),
				.EnderecoAtual(EnderecoAtual)
				);
			
	Adder ADD	(	.Dado1(EnderecoAtual),
						.Dado2(Um),
						.Soma(ProximoEndereco)
						);		
						
	MUX MUX1	(	.Dado1(ProximoEndereco),
					.Dado2(Imediato),
					.Dado3(DadoRegLeitura1),
					.Dado4(Zero),
					.Dado5(Zero),
					.Dado6(Zero),
					.Dado7(Zero),
					.Dado8(Zero),
					.Selecao(CTRLDesvio),
					.DadoSaida(NovoEndereco)
					);
					
	MemInstrucoes MemInstrucoes	(	.EnderecoAtual(EnderecoAtual), 
												.EnderecoEscrita(DadoRegLeitura1),
												.DadoEscrita(DadoHD),
												.CTRLEscritaInstr(CTRLEscritaInstr),
												.CLK(CLK),
												.CLKFPGA(CLKFPGA), 
												.Instrucao(Instrucao)
												);			
												
	UnidadeDecodificacao UnidadeDecodificacao	(	.Instrucao(Instrucao),
																.Cond(Cond),
																.Opcode(Opcode),
																.RN(RN),
																.RM(RM),
																.RD(RD),
																.Imediato(Imediato)
																);
																
	BancoRegistradores BancoRegistradores	(	.RN(RN),
															.RM(RM),
															.RD(RD),
															.DadoRegEscrita(DadoRegEscrita),	
															.CTRLEscritaReg(CTRLEscritaReg),
															.CLK(CLK),
															.CLKFPGA(CLKFPGA),
															.DadoRegLeitura1(DadoRegLeitura1),
															.DadoRegLeitura2(DadoRegLeitura2)
															);
															
	Entrada Entrada	(	.Chaves(ChaveDado),
								.Dado(DadoEntrada),
								.Segmentos(SegmentosEntrada)
								);
								
	MUX MUX2	(	.Dado1(DadoRegLeitura2),
					.Dado2(Imediato),
					.Dado3(DadoEntrada),
					.Dado4(Zero),
					.Dado5(Zero),
					.Dado6(Zero),
					.Dado7(Zero),
					.Dado8(Zero),
					.Selecao(CTRLDadoImediato),
					.DadoSaida(DadoSelecionado)
					);	
					
	Saida Saida	(	.DadoEntrada(DadoRegLeitura1),
						.CTRLSaida(CTRLSaida),
						.Segmentos(Segmentos)
						);
						
	ULA ULA	(	.Dado1(DadoRegLeitura1),
					.Dado2(DadoSelecionado),
					.CTRLOpULA(CTRLOpULA),
					.SaidaULA(SaidaULA),
					.NovasFlags(NovasFlags)
					);
	
	CPSR CPSR	(	.NovasFlags(DadoCPSREscrita),
						.CTRLEscritaCPSR(CTRLEscritaCPSR),
						.CLK(CLK),
						.FlagsNZCV(FlagsNZCV)
						);
	
	MUX MUX3	(	.Dado1(Imediato),
					.Dado2(DadoRegLeitura1),
					.Dado3(Zero),
					.Dado4(SaidaULA),
					.Dado5(Zero),
					.Dado6(Zero),
					.Dado7(Zero),
					.Dado8(Zero),
					.Selecao(CTRLEndMem),
					.DadoSaida(EndSelecionado)
					);
				
	MemPrincipal MemPrincipal	(	.EndLeitura(EndSelecionado),
											.EndEscrita(EndSelecionado),
											.DadoMemEscrita(DadoRegLeitura2),
											.CTRLEscritaMem(CTRLEscritaMem),
											.CLK(CLK),
											.CLKFPGA(CLKFPGA),
											.DadoMemoria(DadoMemoria)
											);
										
	MUX MUX4	(	.Dado1(DadoMemoria),
					.Dado2(SaidaULA),
					.Dado3(DadoSelecionado),
					.Dado4(ProximoEndereco),
					.Dado5(FlagsNZCVEstendidas),
					.Dado6(DadoLeituraIR0),
					.Dado7(DadoLeituraIR1),
					.Dado8(DadoLeituraIR2),
					.Selecao(CTRLDadoReg),
					.DadoSaida(DadoRegEscrita)
					);
				
	UnidadeValidacao UnidadeValidacao	(	.Cond(Cond),
														.FlagsNZCV(FlagsNZCV),
														.Inibe(Inibe)
														);
	
	UnidadeControle UnidadeControle	(	.Opcode(Opcode),
													.Inibe(Inibe),
													.CTRLDesvio(CTRLDesvio),
													.CTRLDadoImediato(CTRLDadoImediato),
													.CTRLEndMem(CTRLEndMem),
													.CTRLDadoReg(CTRLDadoReg),
													.CTRLEscritaReg(CTRLEscritaReg),
													.CTRLEscritaCPSR(CTRLEscritaCPSR),
													.CTRLEscritaMem(CTRLEscritaMem),
													.CTRLOpULA(CTRLOpULA),
													.CTRLHalt(CTRLHalt),
													.CTRLSaida(CTRLSaida),
													.CTRLCLK(CTRLCLK),
													.CTRLDadoCPSR(CTRLDadoCPSR),
													.CTRLEscritaInstr(CTRLEscritaInstr),
													.CTRLEscritaHD(CTRLEscritaHD),
													.CTRLEscritaIR(CTRLEscritaIR),
													.CTRLLCD(CTRLLCD),
													.LEDIN(LEDIN),
													.LEDOUT(LEDOUT)
													);
												
	SeletorClock SeletorClock	(	.CLKFPGA(CLKFPGA),
											.CLKManual(CLKManual),
											.CTRLCLK(CTRLCLK),
											.CLK(CLK)
											);
	
	Debounce Debounce	(	.CLKFPGA(CLKFPGA),
								.ChaveClock(ChaveClock),
								.CLKManual(CLKManual)
								);
	
	EstensorSinal EstensorSinal (	.FlagsNZCV(FlagsNZCV),
											.FlagsNZCVEstendidas(FlagsNZCVEstendidas)
											);
	
	MUX MUX5 (	.Dado1(NovasFlags),
					.Dado2(DadoRegLeitura1),
					.Dado3(Zero),
					.Dado4(Zero),
					.Dado5(Zero),
					.Dado6(Zero),
					.Dado7(Zero),
					.Dado8(Zero),
					.Selecao(CTRLDadoCPSR),
					.DadoSaida(DadoCPSREscrita)
				);
	
	DiscoRigido DiscoRigido (	.EndLeitura(DadoRegLeitura2),
										.EndEscrita(DadoRegLeitura2),
										.DadoEscrita(DadoRegLeitura1),
										.CTRLEscritaHD(CTRLEscritaHD),
										.CLKFPGA(CLKFPGA),
										.CLK(CLK),
										.DadoHD(DadoHD)
									);
	
	BancoRegInterrupcoes BancoRegInterrupcoes (	.DadoEscritaIR0(Imediato),
																.DadoEscritaIR1(NovoEndereco),
																.DadoEscritaIR2(ProximoEndereco),
																.CTRLEscritaIR(CTRLEscritaIR),
																.CLKFPGA(CLKFPGA),
																.CLK(CLK),
																.DadoLeituraIR0(DadoLeituraIR0),
																.DadoLeituraIR1(DadoLeituraIR1),
																.DadoLeituraIR2(DadoLeituraIR2),
															);
	
	//LCD LCD (	.CLKFPGA(CLKFPGA),
	//				.ChaveReset(ChaveReset),
	//				.CTRLLCD(CTRLLCD),
	//				.EnderecoLCD(Imediato),
	//				.DadoLCD(DadoRegLeitura1),
	//				.LCD_RS(LCD_RS),
	//				.LCD_E(LCD_E),
	//				.LCD_RW(LCD_RW),
	//				.DATA_BUS(DATA_BUS)
	//			);

endmodule 