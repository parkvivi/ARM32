module LCD
(
	// Entradas :: Sinais de Controle
	input CLOCK_50, write_clock, write_lcd,
	
	// Entradas :: Dados
	input [4:0] lcd_addr,
	input [7:0] lcd_data,
  
	// Saídas :: LCD
	output LCD_ON,
	output LCD_BLON,
	output LCD_RW,
	output LCD_EN,
	output LCD_RS,
	inout [7:0] LCD_DATA
);

wire DLY_RST;

assign	LCD_ON	=	1'b1;
assign	LCD_BLON	=	1'b1;

Reset_Delay r0 (	.iCLK(CLOCK_50),
						.oRESET(DLY_RST)
					);

LCD_Display u1 (	.iCLK_50MHZ(CLOCK_50),
						.write_clock(write_clock),
						.iRST_N(DLY_RST),
						.lcd_data(lcd_data),
						.lcd_addr(lcd_addr),
						.write_lcd(write_lcd),
						.DATA_BUS(LCD_DATA),
						.LCD_RW(LCD_RW),
						.LCD_E(LCD_EN),
						.LCD_RS(LCD_RS)
					);

endmodule 