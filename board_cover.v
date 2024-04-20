module board_cover(
	clk, reset,
	flag, open,
	x_coord, y_coord,
	cell_val
);

	parameter x_size = 16, y_size = 16;
	parameter x_coord_bits = 4, y_coord_bits = 4;

	input clk, reset;
	input flag, open;
	input [(x_coord_bits - 1):0] x_coord;
	input [(y_coord_bits - 1):0] y_coord;
	output reg [1:0] cell_val;

	reg [1:0] board_arr [0:(y_size - 1)][0:(x_size - 1)];

	reg is_init;
	reg [(x_coord_bits - 1):0] init_x;
	reg [(y_coord_bits - 1):0] init_y;

	initial begin
		is_init = 1'b0;
	end

	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			is_init = 1'b1;
			init_x = 0;
			init_y = 0;
		end else begin
			if (is_init == 1'b1) begin
				board_arr[init_y][init_x] <= 2'b00;
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
			end else begin
				case (board_arr[y_coord][x_coord])
					2'b00: begin // Unopened, unflagged
						if (flag & ~open) begin
							board_arr[y_coord][x_coord] <= 2'b10;
						end else if (~flag & open) begin
							board_arr[y_coord][x_coord] <= 2'b01;
						end
					end

					2'b01: begin // Opened
					end

					2'b10: begin // Flagged
						if (flag && ~open) begin
							board_arr[y_coord][x_coord] <= 2'b00;
						end
					end
				endcase
			end

			cell_val <= board_arr[y_coord][x_coord];
		end
	end

endmodule