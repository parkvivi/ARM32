module LCD
(
    input wire CLKFPGA,
    input wire ChaveReset,

    input wire CTRLLCD,
    input wire [4:0] EnderecoLCD,
    input wire [7:0] DadoLCD,

    output wire LCD_RS,
    output wire LCD_E,
    output wire LCD_RW,
    inout wire [7:0] DATA_BUS
);

    wire w_delay_rst_n;
    wire w_global_rst_n = ChaveReset & w_delay_rst_n;

    Reset_Delay u_reset_delay (
        .iCLK(CLKFPGA),
        .oRESET(w_delay_rst_n)
    );

    LCD_Display u_lcd_display (
        .iCLK_50MHZ(CLKFPGA),
        .iRST_N(w_global_rst_n), 
        
        .iWE(CTRLLCD),
        .iAddr(EnderecoLCD),
        .iData(DadoLCD),
        
        .LCD_RS(LCD_RS),
        .LCD_E(LCD_E),
        .LCD_RW(LCD_RW),
        .DATA_BUS(DATA_BUS)
    );

endmodule