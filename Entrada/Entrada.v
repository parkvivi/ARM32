module Entrada
(
// Entradas :: Sinais de Controle 
input wire CTRLEntrada,

// Entradas :: Chaves FPGA
input wire [15:0] Chaves,

// Saidas :: Dado
output reg [31:0] Dado
);
	
	always @ (*)
		begin
		if (CTRLEntrada == 1'b1)
			begin
			Dado <= {Chaves[15:0], 16'b0};
			end
		else
			begin
			Dado <= {16'b0, Chaves[15:0]};
			end
		end

endmodule 