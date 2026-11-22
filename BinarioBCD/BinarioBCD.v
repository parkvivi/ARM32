module BinarioBCD
(
// Entradas :: Dado de 16 bits
input wire [26:0] Dado,

// Saídas :: BCD
output reg [3:0] DezenaMilhao, Milhao, CentenaMilhar, DezenaMilhar, Milhar, Centena, Dezena, Unidade
);

	integer i;
	reg [31:0] bcd;

	always @ (*)
		begin
		bcd = 32'd0;
		for (i = 26; i >= 0; i = i - 1)
			begin
				if (bcd[3:0]   >= 5) bcd[3:0]   = bcd[3:0]   + 4'd3;
            if (bcd[7:4]   >= 5) bcd[7:4]   = bcd[7:4]   + 4'd3;
            if (bcd[11:8]  >= 5) bcd[11:8]  = bcd[11:8]  + 4'd3;
            if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 4'd3;
            if (bcd[19:16] >= 5) bcd[19:16] = bcd[19:16] + 4'd3;
            if (bcd[23:20] >= 5) bcd[23:20] = bcd[23:20] + 4'd3;
            if (bcd[27:24] >= 5) bcd[27:24] = bcd[27:24] + 4'd3;
            if (bcd[31:28] >= 5) bcd[31:28] = bcd[31:28] + 4'd3;

            bcd = {bcd[30:0], Dado[i]};
			end

        {DezenaMilhao, Milhao, CentenaMilhar, DezenaMilhar, Milhar, Centena, Dezena, Unidade} = bcd;
		end
		
endmodule 