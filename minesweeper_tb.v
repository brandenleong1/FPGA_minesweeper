`timescale 1ns / 1ps

module minesweeper_tb;
// Inputs
    reg BtnU, BtnD, BtnR, BtnL, BtnC;
    reg Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw9, Sw8;
    reg Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0;

    // Outputs
    wire hSync, vSync;
    wire [3:0] vgaR, vgaG, vgaB;
    wire QuadSpiFlashCS;
    wire Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0;
    wire Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
    wire An7, An6, An5, An4, An3, An2, An1, An0;
	/* == INPUTS == */
	reg			Clk;
	reg			Reset;
	wire		BtnL_Pulse, BtnU_Pulse, BtnD_Pulse, BtnR_Pulse, BtnC_Pulse;
	reg [26:0]	DIV_CLK;

/* == OUTPUTS == */

/* == PARAMETERS == */
	parameter debounce_N_dc = 24;
	parameter x_size = 16;
	parameter y_size = 16;
	parameter x_coord_bits = 4;
	parameter y_coord_bits = 4;

/* == LOCAL SIGNALS == */
	wire bright;
	wire[9:0] hc, vc;
	wire [11:0] rgb;
	wire [11:0] background;
	wire [(x_coord_bits - 1):0] x_coord;
	wire [(y_coord_bits - 1):0] y_coord;
	reg [(x_coord_bits - 1):0] x_pos;
	reg [(y_coord_bits - 1):0] y_pos;
	reg flag, open;
	wire [4:0] cell_val_board;
	wire [1:0] cell_val_cover;
	wire [4:0] cell_val_apparent;
	wire [(x_coord_bits + y_coord_bits):0] num_mines, num_non_mines;
	reg [(x_coord_bits + y_coord_bits):0] cells_to_open;
	
	wire opened_cell;
	wire play_pulse;
	reg [3:0] state;
	wire [1:0] is_init;
	wire [31:0] rand, seed;
	wire game_over_wire;
	wire [(x_coord_bits - 1):0] init_x;
	wire [(y_coord_bits - 1):0] init_y;
	wire board_clk, sys_clk;
/* == INITIALIZE == */
	localparam
		INIT =	4'b0001,
		PLAY =	4'b0010,
		WIN	=	4'b0100,
		LOSE =	4'b1000;
	reg glob_reset, reset;
	assign game_over_wire = (cell_val_cover[0] != 0) && (cell_val_board[4] != 0);

	assign cell_val_apparent = (|cell_val_cover == 0) ? 5'b10000 : ((cell_val_cover[1] == 1) ? 5'b10001 : cell_val_board);
	// assign cell_val_apparent = ((cell_val_cover[1] == 1) ? 5'b10001 : cell_val_board);

	assign board_clk = Clk;
	always @ (posedge board_clk, posedge glob_reset) begin
		if (glob_reset)
			DIV_CLK <= 0;
		else
			DIV_CLK <= DIV_CLK + 1'b1;
	end
	
	// assign sys_clk = board_clk;
	assign sys_clk = DIV_CLK[0];
	
	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];
		
	initial begin
		Reset = 1;
		BtnL = 0;
		glob_reset = 1;
		x_pos = 0;
		y_pos = 0;
		flag = 0;
		state = INIT;
		BtnC = 0;

		#20;
		Reset = 0;
		glob_reset = 0;

		#103;
		BtnC = 1;

		#(16 * 16 * 20 * 2 + 100);
		BtnC = 0;
		
		#100;
		x_pos = 5'b00001;
		open = 1'b1;
		#20;
		open = 1'b0;
		#20;
	end

	initial begin
		Clk = 0;
		forever begin
			#10
			Clk = ~ Clk;
		end
	end
		
	always @ (posedge sys_clk, posedge reset) begin
		if (reset) begin
			state <= INIT;
		end else begin
			case (state)
				INIT: begin
					if (|is_init == 0) begin
						state <= PLAY;
						cells_to_open <= num_non_mines;
					end
				end

				PLAY: begin
					if ((opened_cell == 1'b1) && (cell_val_apparent != 5'b11111)) begin
						cells_to_open <= cells_to_open - 1;
					end

					if ((BtnL_Pulse == 1'b1) && (x_pos != 0)) begin
						x_pos <= x_pos - 1;
					end

					if ((BtnU_Pulse == 1'b1) && (y_pos != 0)) begin
						y_pos <= y_pos - 1;
					end

					if ((BtnD_Pulse == 1'b1) && ((y_pos + 1) < y_size)) begin
						y_pos <= y_pos + 1;
					end

					if ((BtnR_Pulse == 1'b1) && ((x_pos + 1) < x_size)) begin
						x_pos <= x_pos + 1;
					end

					if (cell_val_apparent == 5'b11111) begin
						state <= LOSE;
					end else if (cells_to_open == 0) begin
						state <= WIN;
					end
				end

				WIN: begin
					if (BtnC_Pulse == 1'b1) begin
						state <= INIT;
					end
				end

				LOSE: begin
					if (BtnC_Pulse == 1'b1) begin
						state <= INIT;
					end
				end
			endcase
		end
	end
	/* == DESIGN == */
	debouncer #(.N_dc(debounce_N_dc)) debouncer_L(
		.CLK(sys_clk), .RESET(glob_reset), .PB(BtnL), .DPB( ), 
		.SCEN(BtnL_Pulse), .MCEN( ), .CCEN( )
	);

	debouncer #(.N_dc(debounce_N_dc)) debouncer_U(
		.CLK(sys_clk), .RESET(glob_reset), .PB(BtnU), .DPB( ), 
		.SCEN(BtnU_Pulse), .MCEN( ), .CCEN( )
	);

	debouncer #(.N_dc(debounce_N_dc)) debouncer_D(
		.CLK(sys_clk), .RESET(glob_reset), .PB(BtnD), .DPB( ), 
		.SCEN(BtnD_Pulse), .MCEN( ), .CCEN( )
	);

	debouncer #(.N_dc(debounce_N_dc)) debouncer_R(
		.CLK(sys_clk), .RESET(glob_reset), .PB(BtnR), .DPB( ), 
		.SCEN(BtnR_Pulse), .MCEN( ), .CCEN( )
	);

	debouncer #(.N_dc(debounce_N_dc)) debouncer_C(
		.CLK(sys_clk), .RESET(glob_reset), .PB(BtnC), .DPB( ), 
		.SCEN(BtnC_Pulse), .MCEN( ), .CCEN( )
	);

	board board_arr(
		.clk(sys_clk), .reset(reset),
		.x_coord(x_coord), .y_coord(y_coord),
		.cell_val(cell_val_board), .seed(seed), .rand(rand),
		.num_mines(num_mines), .num_non_mines(num_non_mines),
		.is_init(is_init), .init_x(init_x), .init_y(init_y)
	);

	board_cover board_cover_arr(
		.clk(sys_clk), .reset(reset),
		.flag(flag), .open(open),
		.x_coord(x_coord), .y_coord(y_coord),
		.x_pos(x_pos), .y_pos(y_pos),
		.cell_val(cell_val_cover), .opened_cell(opened_cell)
	);
	
	display_controller dc(.clk(Clk), .hSync(hSync), .x_coord(x_coord),
		.y_coord(y_coord),
		.vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
	block_controller sc(.masterclk(Clk), .bright(bright), .rst(reset),
		.cell_apparent(cell_val_apparent), .x_coord(x_coord), .y_coord(y_coord),
		.x_pos(x_pos), .y_pos(y_pos), .hCount(hc), .vCount(vc),
		.rgb(rgb), .background(background));

endmodule