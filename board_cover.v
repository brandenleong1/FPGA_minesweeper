module board_cover(
	clk, reset,
	flag, open,
	x_coord, y_coord,
<<<<<<< HEAD
=======
	x_pos, y_pos,
>>>>>>> map
	cell_val, opened_cell
);

	parameter x_size = 16, y_size = 16;
	parameter x_coord_bits = 4, y_coord_bits = 4;

	input clk, reset;
	input flag, open;
	input [(x_coord_bits - 1):0] x_coord;
	input [(y_coord_bits - 1):0] y_coord;
	input [(x_coord_bits - 1):0] x_pos;
	input [(y_coord_bits - 1):0] y_pos;
	output reg [1:0] cell_val;
	output reg opened_cell;

	reg [1:0] board_arr [0:(y_size - 1)][0:(x_size - 1)];

	reg is_init;
	reg [(x_coord_bits - 1):0] init_x;
	reg [(y_coord_bits - 1):0] init_y;
	reg [1:0] change_cell;

	initial begin
		is_init = 1'b0;
		opened_cell = 1'b0;
		change_cell = 2'b00;
	end

	initial begin
		is_init = 1'b0;
		opened_cell = 1'b0;
	end

	always @ (posedge clk, posedge reset) begin
		opened_cell <= 1'b0;
		
		if (reset) begin
			is_init <= 1'b1;
			init_x <= 0;
			init_y <= 0;
<<<<<<< HEAD
=======
			change_cell = 2'b00;
>>>>>>> map
		end else begin
			if (flag) begin
				change_cell <= 2'b10;
			end
			else if (open) begin
				change_cell <= 2'b01;
			end
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
			end else if ((y_pos == y_coord) && (x_pos == x_coord)) begin
				case (board_arr[y_coord][x_coord])
					2'b00: begin // Unopened, unflagged
						if (change_cell == 2'b10) begin
							board_arr[y_coord][x_coord] <= 2'b10;
						end else if (change_cell == 2'b01) begin
							board_arr[y_coord][x_coord] <= 2'b01;
							opened_cell <= 1'b1;
						end
					end

					2'b01: begin // Opened
					end

					2'b10: begin // Flagged
						if (change_cell == 2'b10) begin
							board_arr[y_coord][x_coord] <= 2'b00;
						end
					end
				endcase
				change_cell <= 2'b00;
			end

			cell_val <= board_arr[y_coord][x_coord];
		end
	end

endmodule