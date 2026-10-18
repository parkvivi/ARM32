module EstensorSinal
(
// Entradas :: Flags NZCV
input wire [3:0] FlagsNZCV,

// Saídas :: Sinal estendido
output reg [31:0] FlagsNZCVEstendidas
);

	always @ (*)
		begin
		FlagsNZCVEstendidas <= {28'b0, FlagsNZCV};
		end
					
endmodule 