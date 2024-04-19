module board(
	clk, reset,
	btnC_Pulse,
	x_coord, y_coord,
	cell_val, num_mines, seed, rand, is_init
);

	parameter x_size = 16, y_size = 16;
	parameter x_coord_bits = 4, y_coord_bits = 4;
	parameter cutoff = 32'h2AAAAAAA;

	input clk, reset;
	input btnC_Pulse;
	input [(x_coord_bits - 1):0] x_coord;
	input [(y_coord_bits - 1):0] y_coord;
	output reg [4:0] cell_val;
	output reg [(x_coord_bits + y_coord_bits - 1):0] num_mines = 0;

	reg [4:0] board_arr [0:(y_size - 1)][0:(x_size - 1)];

	output reg [31:0] seed;
	output reg is_init = 1'b0;
	reg [(x_coord_bits - 1):0] init_x;
	reg [(y_coord_bits - 1):0] init_y;
	output wire [31:0] rand;

	xor_shift rand1(.seed(seed), .rand(rand));

	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			seed = 32'h12345678;
			is_init = 1'b1;
			init_x = 0;
			init_y = 0;
			num_mines = 0;
		end else begin
			if (btnC_Pulse) begin
				seed = rand;
			end

			if (is_init == 1'b1) begin
				if (rand <= cutoff) begin
					board_arr[init_y][init_x] <= -1;
					num_mines <= num_mines + 1;
				end else begin
					board_arr[init_y][init_x] <= 0;
				end
				seed <= rand;
				if (init_x == (x_size - 1)) begin
					init_x <= 0;
					if (init_y == (y_size - 1)) begin
						is_init <= 1'b0;
						init_y <= 0;
					end else begin
						init_y <= init_y + 1;
					end
				end else begin
					init_x <= init_x + 1;
				end
			end

			cell_val <= board_arr[y_coord][x_coord];
		end
	end

	// always @ (x_coord, y_coord, board_arr[y_coord][x_coord]) begin
	// 	cell_val <= board_arr[y_coord][x_coord];
	// end

endmodule