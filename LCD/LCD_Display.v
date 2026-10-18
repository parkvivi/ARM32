module LCD_Display
(
    input wire iCLK_50MHZ, 
    input wire iRST_N, 
    
    input wire iWE,
    input wire [4:0] iAddr,
    input wire [7:0] iData,

    output reg LCD_RS, 
    output reg LCD_E, 
    output reg LCD_RW, 
    inout [7:0] DATA_BUS
);

	parameter
	HOLD = 4'h0,
	FUNC_SET = 4'h1,
	DISPLAY_ON = 4'h2,
	MODE_SET = 4'h3,
	Print_String = 4'h4,
	LINE2 = 4'h5,
	RETURN_HOME = 4'h6,
	DROP_LCD_E = 4'h7,
	RESET1 = 4'h8,
	RESET2 = 4'h9,
	RESET3 = 4'ha,
	DISPLAY_OFF = 4'hb,
	DISPLAY_CLEAR = 4'hc;

reg [3:0] state, next_command;
reg [7:0] DATA_BUS_VALUE;
wire [7:0] Next_Char;
reg [19:0] CLK_COUNT_400HZ;
reg [4:0] CHAR_COUNT;
reg CLK_400HZ, LCD_RW_INT;
reg [7:0] display_ram [0:31]; 
integer i;

assign DATA_BUS = (LCD_RW_INT ? 8'bZZZZZZZZ : DATA_BUS_VALUE);

always @ (*) 
	begin
	LCD_RW <= LCD_RW_INT;
	end
	
always @ (posedge iCLK_50MHZ or negedge iRST_N) begin
    if (!iRST_N) begin
        for (i = 0; i < 32; i = i + 1)
            display_ram[i] <= 8'h20;
    end
    else if (iWE) begin
        display_ram[iAddr] <= iData;
    end
end

assign Next_Char = display_ram[CHAR_COUNT];

always @ (posedge iCLK_50MHZ or negedge iRST_N)
    if (!iRST_N) begin
       CLK_COUNT_400HZ <= 20'h00000;
       CLK_400HZ <= 1'b0;
    end
    else if (CLK_COUNT_400HZ < 20'h0F424) begin
       CLK_COUNT_400HZ <= CLK_COUNT_400HZ + 1'b1;
    end
    else begin
      CLK_COUNT_400HZ <= 20'h00000;
      CLK_400HZ <= ~CLK_400HZ;
    end

always @ (posedge CLK_400HZ or negedge iRST_N)
    if (!iRST_N) begin
        state <= RESET1;
    end
    else case (state)
    RESET1: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h38;
      state <= DROP_LCD_E;
      next_command <= RESET2;
      CHAR_COUNT <= 5'b00000;
    end
    RESET2: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h38;
      state <= DROP_LCD_E;
      next_command <= RESET3;
    end
    RESET3: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h38;
      state <= DROP_LCD_E;
      next_command <= FUNC_SET;
    end
    FUNC_SET: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h38;
      state <= DROP_LCD_E;
      next_command <= DISPLAY_OFF;
    end
    DISPLAY_OFF: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h08;
      state <= DROP_LCD_E;
      next_command <= DISPLAY_CLEAR;
    end
    DISPLAY_CLEAR: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h01;
      state <= DROP_LCD_E;
      next_command <= DISPLAY_ON;
    end
    DISPLAY_ON: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h0C;
      state <= DROP_LCD_E;
      next_command <= MODE_SET;
    end
    MODE_SET: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h06;
      state <= DROP_LCD_E;
      next_command <= Print_String;
    end
    Print_String: begin
      state <= DROP_LCD_E;
      LCD_E <= 1'b1;
      LCD_RS <= 1'b1;
      LCD_RW_INT <= 1'b0;
      
      if (Next_Char[7:4] != 4'h0)
        DATA_BUS_VALUE <= Next_Char;
      else if (Next_Char[3:0] > 9)
         DATA_BUS_VALUE <= {4'h4, Next_Char[3:0] - 4'h9};
      else
         DATA_BUS_VALUE <= {4'h3, Next_Char[3:0]};

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
    LINE2: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'hC0;
      state <= DROP_LCD_E;
      next_command <= Print_String;
    end
    RETURN_HOME: begin
      LCD_E <= 1'b1;
      LCD_RS <= 1'b0;
      LCD_RW_INT <= 1'b0;
      DATA_BUS_VALUE <= 8'h80;
      state <= DROP_LCD_E;
      next_command <= Print_String;
    end
    DROP_LCD_E: begin
      LCD_E <= 1'b0;
      state <= HOLD;
    end
    HOLD: begin
      state <= next_command;
    end
    endcase
endmodule