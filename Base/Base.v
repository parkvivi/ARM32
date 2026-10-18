module Base
(
// Entradas :: Novo Endereço Base
input wire [31:0] NovaBase,

// Entradas :: Sinais de Controle
input wire CTRLEscritaBase,
input wire CLK,

// Saídas :: Endereço Base
output reg [31:0] EnderecoBase
);
	initial	begin
				EnderecoBase <= 32'b0;
				end
					
	always @ (posedge CLK)
		begin
		if (CTRLEscritaBase == 1'b1)
			begin
			EnderecoBase <= NovaBase;
			end
		end
		
endmodule 