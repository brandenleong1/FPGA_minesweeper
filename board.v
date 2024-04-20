module board(
	clk, reset,
	init_pulse,
	x_coord, y_coord,
	cell_val, num_mines, seed, rand,
	is_init, init_x, init_y
);

	parameter x_size = 16, y_size = 16;
	parameter x_coord_bits = 4, y_coord_bits = 4;
	parameter cutoff = 32'h2AAAAAAA;

	input clk, reset;
	input init_pulse;
	input [(x_coord_bits - 1):0] x_coord;
	input [(y_coord_bits - 1):0] y_coord;
	output reg [4:0] cell_val;
	output reg [(x_coord_bits + y_coord_bits - 1):0] num_mines = 0;

	reg [4:0] board_arr [0:(y_size - 1)][0:(x_size - 1)];

	output reg [31:0] seed;
	output reg [1:0] is_init;
	output reg [(x_coord_bits - 1):0] init_x;
	output reg [(y_coord_bits - 1):0] init_y;
	output wire [31:0] rand;

	wire [(x_coord_bits - 1):0] init_x_L, init_x_R;
	wire [(y_coord_bits - 1):0] init_y_U, init_y_D;

	assign init_x_L = init_x - 1;
	assign init_x_R = init_x + 1;
	assign init_y_U = init_y - 1;
	assign init_y_D = init_y + 1;

	xor_shift rand1(.seed(seed), .rand(rand));

	initial begin
		seed = 32'h12345678;
		is_init = 2'b00;
	end

	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			// seed = 32'h12345678;
			is_init = 2'b01;
			init_x = 0;
			init_y = 0;
			num_mines = 0;
		end else begin
			// if (init_pulse) begin
				// seed = rand;

				if (is_init == 2'b01) begin
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
							is_init <= 2'b10;
							init_y <= 0;
						end else begin
							init_y <= init_y + 1;
						end
					end else begin
						init_x <= init_x + 1;
					end
				end else if (is_init == 2'b10) begin
					if (board_arr[init_y][init_x][4] == 1) begin

						if ((init_y > 0) && (board_arr[init_y_U][init_x][4] != 1)) begin // U
							board_arr[init_y_U][init_x] <= board_arr[init_y_U][init_x] + 1;
						end

						if ((init_y < (y_size - 1)) && (board_arr[init_y_D][init_x][4] != 1)) begin // D
							board_arr[init_y_D][init_x] <= board_arr[init_y_D][init_x] + 1;
						end

						if ((init_x > 0) && (board_arr[init_y][init_x_L][4] != 1)) begin // L
							board_arr[init_y][init_x_L] <= board_arr[init_y][init_x_L] + 1;
						end

						if ((init_x < (x_size - 1)) && (board_arr[init_y][init_x_R][4] != 1)) begin // R
							board_arr[init_y][init_x_R] <= board_arr[init_y][init_x_R] + 1;
						end

						if ((init_y > 0) && (init_x > 0) && (board_arr[init_y_U][init_x_L][4] != 1)) begin // UL
							board_arr[init_y_U][init_x_L] <= board_arr[init_y_U][init_x_L] + 1;
						end

						if ((init_y > 0) && (init_x < (x_size - 1)) && (board_arr[init_y_U][init_x_R][4] != 1)) begin // UR
							board_arr[init_y_U][init_x_R] <= board_arr[init_y_U][init_x_R] + 1;
						end

						if ((init_y < (y_size - 1)) && (init_x > 0) && (board_arr[init_y_D][init_x_L][4] != 1)) begin // DL
							board_arr[init_y_D][init_x_L] <= board_arr[init_y_D][init_x_L] + 1;
						end

						if ((init_y < (y_size - 1)) && (init_x < (x_size - 1)) && (board_arr[init_y_D][init_x_R][4] != 1)) begin // DR
							board_arr[init_y_D][init_x_R] <= board_arr[init_y_D][init_x_R] + 1;
						end

					end

					if (init_x == (x_size - 1)) begin
						init_x <= 0;
						if (init_y == (y_size - 1)) begin
							is_init <= 2'b00;
							init_y <= 0;
						end else begin
							init_y <= init_y + 1;
						end
					end else begin
						init_x <= init_x + 1;
					end
				end
			// end

			cell_val <= board_arr[y_coord][x_coord];
		end
	end

endmodule