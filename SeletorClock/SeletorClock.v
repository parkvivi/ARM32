module SeletorClock
(
// Entradas :: Alternativas de Clock
input wire CLKFPGA, CLKManual,

// Entradas :: Sinais de Controle
input wire CTRLCLK,

// Saída :: Clock
output reg CLK
);

	reg [24:0] Contador;
	reg CLKDividido;
	
	initial
		begin
		Contador = 25'b0;
		CLKDividido = 1'b0;
		end
	
	always @ (posedge CLKFPGA)
		begin
		if (CTRLCLK == 1'b1)
			begin
			Contador <= 25'b0;
			CLKDividido <= 1'b0;
			end
		else
			begin
			if (Contador == 25'd50)
				begin
				Contador <= 25'b0;
				CLKDividido <= ~CLKDividido;
				end
			else
				begin
				Contador <= Contador + 1'b1;
				end
			end
		end
		
	always @ (*)
		begin
		if (CTRLCLK == 1'b0) 
			begin
			CLK <= CLKDividido;
			end
		else
			begin
			CLK <= CLKManual;
			end
		end

endmodule 