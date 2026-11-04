/*
------------------------------------------------------------------- 
--                        ASCII HEX TABLE
--  Hex						Low Hex Digit
-- Value  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
------\----------------------------------------------------------------
--H  2 |  SP  !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /
--i  3 |  0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?
--g  4 |  @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
--h  5 |  P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _
--   6 |  `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o
--   7 |  p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~ DEL
-----------------------------------------------------------------------
-- Example "A" is row 4 column 1, so hex value is 8'h41"
-- *see LCD Controller's Datasheet for other graphics characters available
*/
		
module LCD_Display
(
	iCLK_50MHZ, iRST_N, write_clock, write_lcd,
	lcd_addr, lcd_data,
	LCD_RS, LCD_E, LCD_RW,
	DATA_BUS
);

// Entradas :: Sinais de Controle
input	iCLK_50MHZ, iRST_N, write_clock, write_lcd;

// Entradas :: Dados
input [4:0] lcd_addr;
input [7:0]	lcd_data;

// Saídas :: LCD
output	LCD_RS, LCD_E, LCD_RW;
inout [7:0] DATA_BUS;

parameter	HOLD = 4'h0, FUNC_SET = 4'h1, DISPLAY_ON = 4'h2, MODE_SET = 4'h3, Print_String = 4'h4,
				LINE2 = 4'h5, RETURN_HOME = 4'h6, DROP_LCD_E = 4'h7, RESET1 = 4'h8, RESET2 = 4'h9,
				RESET3 = 4'ha, DISPLAY_OFF = 4'hb, DISPLAY_CLEAR = 4'hc;

reg [19:0] CLK_COUNT_400HZ;
reg [7:0] DATA_BUS_VALUE;
reg [4:0] CHAR_COUNT;
reg [3:0] state, next_command;
reg CLK_400HZ, LCD_RW_INT, LCD_E, LCD_RS;

wire [7:0] Next_Char;

assign DATA_BUS = (LCD_RW_INT? 8'bZZZZZZZZ: DATA_BUS_VALUE);
assign LCD_RW = LCD_RW_INT;

LCD_display_string u1 (	.write_clock(write_clock),
								.index(CHAR_COUNT),
								.out(Next_Char),
								.lcd_data(lcd_data),
								.lcd_addr(lcd_addr),
								.write_lcd(write_lcd)
							);

always @ (posedge iCLK_50MHZ or negedge iRST_N)
	if (!iRST_N)
	begin
	   CLK_COUNT_400HZ <= 20'h00000;
	   CLK_400HZ <= 1'b0;
	end
	else if (CLK_COUNT_400HZ < 20'h0F424)
	begin
	   CLK_COUNT_400HZ <= CLK_COUNT_400HZ + 1'b1;
	end
	else
	begin
	  CLK_COUNT_400HZ <= 20'h00000;
	  CLK_400HZ <= ~CLK_400HZ;
	end

always @ (posedge CLK_400HZ or negedge iRST_N)
	if (!iRST_N)
	begin
	 state <= RESET1;
	end
	else
	case (state)
	RESET1:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h38;
	  state <= DROP_LCD_E;
	  next_command <= RESET2;
	  CHAR_COUNT <= 5'b00000;
	end
	RESET2:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h38;
	  state <= DROP_LCD_E;
	  next_command <= RESET3;
	end
	RESET3:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h38;
	  state <= DROP_LCD_E;
	  next_command <= FUNC_SET;
	end

	FUNC_SET:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h38;
	  state <= DROP_LCD_E;
	  next_command <= DISPLAY_OFF;
	end

	DISPLAY_OFF:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h08;
	  state <= DROP_LCD_E;
	  next_command <= DISPLAY_CLEAR;
	end

	DISPLAY_CLEAR:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h01;
	  state <= DROP_LCD_E;
	  next_command <= DISPLAY_ON;
	end

	DISPLAY_ON:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h0C;
	  state <= DROP_LCD_E;
	  next_command <= MODE_SET;
	end

	MODE_SET:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h06;
	  state <= DROP_LCD_E;
	  next_command <= Print_String;
	end

	Print_String:
	begin
	  state <= DROP_LCD_E;
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b1;
	  LCD_RW_INT <= 1'b0;
	  if (Next_Char[7:4] != 4'h0)
		DATA_BUS_VALUE <= Next_Char;
	  else if (Next_Char[3:0] >9)
		 DATA_BUS_VALUE <= {4'h4,Next_Char[3:0]-4'h9};
	  else
		 DATA_BUS_VALUE <= {4'h3,Next_Char[3:0]};
	  if ((CHAR_COUNT < 31) && (Next_Char != 8'hFE))
	     CHAR_COUNT <= CHAR_COUNT + 1'b1;
	  else
	     CHAR_COUNT <= 5'b00000;
	  if (CHAR_COUNT == 15)
	    next_command <= LINE2;
	  else if ((CHAR_COUNT == 31) || (Next_Char == 8'hFE))
	    next_command <= RETURN_HOME;
	  else
	    next_command <= Print_String;
	end

	LINE2:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'hC0;
	  state <= DROP_LCD_E;
	  next_command <= Print_String;
	end

	RETURN_HOME:
	begin
	  LCD_E <= 1'b1;
	  LCD_RS <= 1'b0;
	  LCD_RW_INT <= 1'b0;
	  DATA_BUS_VALUE <= 8'h80;
	  state <= DROP_LCD_E;
	  next_command <= Print_String;
	end

	DROP_LCD_E:
	begin
	  LCD_E <= 1'b0;
	  state <= HOLD;
	end
	
	HOLD:
	begin
	  state <= next_command;
	end
	endcase
endmodule

module LCD_display_string
(
	write_clock, write_lcd,
	lcd_data, lcd_addr,
	index, out
);

// Entrada :: Sinais de Controle
input write_lcd, write_clock;

// Entrada :: Dados
input [7:0] lcd_data; 
input [4:0] index, lcd_addr;

// Saída :: Dados
output [7:0] out;


// Memória LCD
reg [7:0] lcd_reg_data[31:0];

initial begin
	lcd_reg_data[0] = 8'h20;
	lcd_reg_data[1] = 8'h20;
	lcd_reg_data[2] = 8'h20;
	lcd_reg_data[3] = 8'h20;
	lcd_reg_data[4] = 8'h20;
	lcd_reg_data[5] = 8'h20;
	lcd_reg_data[6] = 8'h20;
	lcd_reg_data[7] = 8'h20;
	lcd_reg_data[8] = 8'h20;
	lcd_reg_data[9] = 8'h20;
	lcd_reg_data[10] = 8'h20;
	lcd_reg_data[11] = 8'h20;
	lcd_reg_data[12] = 8'h20;
	lcd_reg_data[13] = 8'h20;
	lcd_reg_data[14] = 8'h20;
	lcd_reg_data[15] = 8'h20;
	lcd_reg_data[16] = 8'h20;
	lcd_reg_data[17] = 8'h20;
	lcd_reg_data[18] = 8'h20;
	lcd_reg_data[19] = 8'h20;
	lcd_reg_data[20] = 8'h20;
	lcd_reg_data[21] = 8'h20;
	lcd_reg_data[22] = 8'h20;
	lcd_reg_data[23] = 8'h20;
	lcd_reg_data[24] = 8'h20;
	lcd_reg_data[25] = 8'h20;
	lcd_reg_data[26] = 8'h20;
	lcd_reg_data[27] = 8'h20;
	lcd_reg_data[28] = 8'h20;
	lcd_reg_data[29] = 8'h20;
	lcd_reg_data[30] = 8'h20;
	lcd_reg_data[31] = 8'h20;
end

always @ (posedge write_clock)
	begin
	if (write_lcd == 1'b1)
		begin
		lcd_reg_data[lcd_addr] <= lcd_data;
		end
	end
	
assign out = lcd_reg_data[index];
	
endmodule 