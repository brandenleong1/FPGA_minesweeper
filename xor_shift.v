module xor_shift(seed, rand);

	input [31:0] seed;
	output [31:0] rand;
	wire [31:0] temp = seed ^ seed >> 7;
	wire [31:0] temp2 = temp ^ temp << 9;
	wire [31:0] temp3 = temp2 ^ temp2 >> 13;
	wire [31:0] rand_out = temp3;

	assign rand = rand_out;

endmodule