`timescale 1ns / 1ps

module minesweeper_tb;

	/* == INPUTS == */
		reg			Clk;
		reg			Reset;
		reg			btnL;
		wire		btnL_Pulse;

	/* == OUTPUTS == */
		wire		Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0;

	/* == PARAMETERS == */
		parameter x_size = 16;
		parameter y_size = 16;
		parameter x_coord_bits = 4;
		parameter y_coord_bits = 4;

	/* == LOCAL SIGNALS == */
		reg [(x_coord_bits - 1):0] x_coord;
		reg [(y_coord_bits - 1):0] y_coord;
		reg flag, open;
		wire [4:0] cell_val;
		wire [1:0] cell_val_cover;
		wire [(x_coord_bits + y_coord_bits - 1):0] num_mines;
		wire [31:0] rand;

	/* == INITIALIZE == */
		task print_board;
			begin: print
				integer i, j;
				for (i = 0; i < y_size; i = i + 1) begin
					for (j = 0; j < x_size; j = j + 1) begin
						y_coord = i;
						x_coord = j;
						#20
						$write("%d ", cell_val);
					end
					$write("| ");
				end
			end
		endtask

		initial begin
			Reset = 1;
			btnL = 0;
			x_coord = 0;
			y_coord = 0;
			flag = 0;
			open = 0;

			#20;
			Reset = 0;

			#103;

			#100
			btnL = 1;
			#200;
			btnL = 0;

			#(16 * 16 * 20 + 100);
			print_board();
		end

		initial begin
			Clk = 0;
			forever begin
				#10
				Clk = ~ Clk;
			end
		end

	/* == DESIGN == */
		debouncer #(.N_dc(7)) debouncer_L(
			.CLK(Clk), .RESET(Reset), .PB(btnL), .DPB( ), 
			.SCEN(btnL_Pulse), .MCEN( ), .CCEN( )
		);

		board board_arr(
			.clk(Clk), .reset(Reset),
			.x_coord(x_coord), .y_coord(y_coord),
			.cell_val(cell_val), .num_mines(num_mines), .rand(rand)
		);

		board_cover board_cover_arr(
			.clk(Clk), .reset(Reset),
			.flag(flag), .open(open),
			.x_coord(x_coord), .y_coord(y_coord),
			.cell_val(cell_val_cover)
		);

endmodule