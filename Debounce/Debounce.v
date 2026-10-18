module Debounce
(
input wire CLKFPGA, ChaveClock,
output reg CLKManual
);
	
	reg [16:0] Contador;
	
	initial
		begin
		Contador = 16'b0;
		end
	
	always @ (posedge CLKFPGA)
		begin
		if (ChaveClock == 1'b1)
			begin
			if (Contador == 16'd100000)
				begin
				CLKManual <= 1'b1;
				Contador <= 16'b0;
				end
			else
				begin
				Contador <= Contador + 1'b1;
				end
			end
		else
			begin
			CLKManual <= 1'b0;
			Contador <= 16'b0;
			end
		end
		
endmodule 