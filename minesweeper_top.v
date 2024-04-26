module minesweeper_top (
		QuadSpiFlashCS,									// disable the memory chip
		ClkPort,										// the 100 MHz incoming clock signal
		BtnL, BtnU, BtnD, BtnR,							// the Left, Up, Down, and the Right buttons
		BtnC,											// the Center button
		Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw9, Sw8,	// left 8 switches
		Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0,			// right 8 switches
		Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0,			// right 8 LEDs
		An7, An6, An5, An4, An3, An2, An1, An0,			// 8 anodes
		Ca, Cb, Cc, Cd, Ce, Cf, Cg,						// 7 cathodes
		Dp,												// Dot Point Cathode on SSDs
		vgaR, vgaG, vgaB,
		hSync, vSync
	);

	/* == INPUTS == */
		input		ClkPort;
		input		BtnL, BtnU, BtnD, BtnR, BtnC;
		input		Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw9, Sw8;
		input		Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0;

	/* == OUTPUTS == */
		output		hSync, vSync;
		output		[3:0] vgaR, vgaG, vgaB;
		output		QuadSpiFlashCS;
		output		Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0;
		output		Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
		output		An7, An6, An5, An4, An3, An2, An1, An0;

	/* == PARAMETERS == */
		parameter debounce_N_dc = 24;

		parameter x_size = 16;
		parameter y_size = 16;
		parameter x_coord_bits = 4;
		parameter y_coord_bits = 4;

		localparam
			INIT =	4'b0001,
			PLAY =	4'b0010,
			WIN	=	4'b0100,
			LOSE =	4'b1000;

	/* == LOCAL SIGNALS == */
<<<<<<< HEAD
=======
		wire bright;
		wire[9:0] hc, vc;
		wire [11:0] rgb;
		wire [11:0] background;
	
>>>>>>> map
		wire		glob_reset, reset, ClkPort;
		wire		board_clk, sys_clk;
		wire [2:0]	ssdscan_clk;
		reg [26:0]	DIV_CLK;

		wire		BtnL_Pulse, BtnU_Pulse, BtnD_Pulse, BtnR_Pulse, BtnC_Pulse;
		reg [3:0]	SSD;
		wire [3:0]	SSD7, SSD6, SSD5, SSD4, SSD3, SSD2, SSD1, SSD0;
		reg [7:0]	SSD_CATHODES;

<<<<<<< HEAD
		reg [(x_coord_bits - 1):0] x_coord;
		reg [(y_coord_bits - 1):0] y_coord;
=======
		wire [(x_coord_bits - 1):0] x_coord;
		wire [(y_coord_bits - 1):0] y_coord;
		reg [(x_coord_bits - 1):0] x_pos;
		reg [(y_coord_bits - 1):0] y_pos;
>>>>>>> map
		wire [4:0] cell_val_board;
		wire [1:0] cell_val_cover;
		wire [4:0] cell_val_apparent;
		wire [(x_coord_bits + y_coord_bits):0] num_mines, num_non_mines;
		reg [(x_coord_bits + y_coord_bits):0] cells_to_open;
		reg [3:0] state;

		wire flag, open;
		wire opened_cell;
		wire play_pulse;
<<<<<<< HEAD
=======
		
		reg [1:0]splash_screen;
>>>>>>> map

		wire [1:0] is_init;
		wire [31:0] rand, seed;
		wire [(x_coord_bits - 1):0] init_x;
		wire [(y_coord_bits - 1):0] init_y;

	/* == ASSIGNMENTS == */
		assign {QuadSpiFlashCS} = 1'b1;
		assign glob_reset = Sw15;
		assign reset = BtnC_Pulse && Sw0;

		assign flag = BtnC_Pulse && Sw1 && ~Sw0 && (state == PLAY);
		assign open = BtnC_Pulse && ~Sw1 && ~Sw0 && (state == PLAY);

		assign cell_val_apparent = (|cell_val_cover == 0) ? 5'b10000 : ((cell_val_cover[1] == 1) ? 5'b10001 : cell_val_board);
<<<<<<< HEAD

	/* == CLOCK DIVISION == */
		BUFGP BUFGP1(board_clk, ClkPort);

=======
		// assign cell_val_apparent = ((cell_val_cover[1] == 1) ? 5'b10001 : cell_val_board);

		assign board_clk = ClkPort;

>>>>>>> map
		always @ (posedge board_clk, posedge glob_reset) begin
			if (glob_reset)
				DIV_CLK <= 0;
			else
				DIV_CLK <= DIV_CLK + 1'b1;
		end

		// assign sys_clk = board_clk;
		assign sys_clk = DIV_CLK[0];
<<<<<<< HEAD
=======
		
		assign vgaR = rgb[11 : 8];
		assign vgaG = rgb[7  : 4];
		assign vgaB = rgb[3  : 0];
>>>>>>> map

	/* == DEBOUNCING == */
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

		
		reg [4:0] test_apparent_val;
		
	/* == INITIALIZATION == */
		initial begin
<<<<<<< HEAD
			x_coord = 0;
			y_coord = 0;
=======
			splash_screen = 2'b01; // Start screen
			x_pos = 0;
			y_pos = 0;
>>>>>>> map
			state = INIT;
			// game_over = 0;
		end

		always @ (posedge sys_clk, posedge reset) begin
<<<<<<< HEAD
=======
			if ((y_pos == y_coord) && (x_pos == x_coord)) begin
				test_apparent_val <= cell_val_apparent;
			end
>>>>>>> map
			if (reset) begin
				state <= INIT;
			end else begin
				case (state)
					INIT: begin
<<<<<<< HEAD
						if (|is_init == 0) begin
=======
						if (|is_init == 0)begin
>>>>>>> map
							state <= PLAY;
							cells_to_open <= num_non_mines;
						end
					end

					PLAY: begin
						if ((opened_cell == 1'b1) && (cell_val_apparent != 5'b11111)) begin
							cells_to_open <= cells_to_open - 1;
<<<<<<< HEAD
						end

						if ((BtnL_Pulse == 1'b1) && (x_coord != 0)) begin
							x_coord <= x_coord - 1;
						end

						if ((BtnU_Pulse == 1'b1) && (y_coord != 0)) begin
							y_coord <= y_coord - 1;
						end

						if ((BtnD_Pulse == 1'b1) && ((y_coord + 1) < y_size)) begin
							y_coord <= y_coord + 1;
						end

						if ((BtnR_Pulse == 1'b1) && ((x_coord + 1) < x_size)) begin
							x_coord <= x_coord + 1;
=======
							splash_screen <= 2'b00;
						end

						if ((BtnL_Pulse == 1'b1) && (x_pos != 0)) begin
							x_pos <= x_pos - 1;
							splash_screen <= 2'b00;
						end

						if ((BtnU_Pulse == 1'b1) && (y_pos != 0)) begin
							y_pos <= y_pos - 1;
							splash_screen <= 2'b00;
						end

						if ((BtnD_Pulse == 1'b1) && ((y_pos + 1) < y_size)) begin
							y_pos <= y_pos + 1;
							splash_screen <= 2'b00;
						end

						if ((BtnR_Pulse == 1'b1) && ((x_pos + 1) < x_size)) begin
							x_pos <= x_pos + 1;
							splash_screen <= 2'b00;
>>>>>>> map
						end

						if (cell_val_apparent == 5'b11111) begin
							state <= LOSE;
<<<<<<< HEAD
						end else if (cells_to_open == 0) begin
							state <= WIN;
=======
							splash_screen <= 2'b10; // Gameover screen
						end else if (cells_to_open == 0) begin
							state <= WIN;
							splash_screen <= 2'b11; // You Win screen
>>>>>>> map
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
<<<<<<< HEAD
=======
			.x_pos(x_pos), .y_pos(y_pos),
>>>>>>> map
			.cell_val(cell_val_cover), .opened_cell(opened_cell)
		);
		
		display_controller dc(.clk(ClkPort), .hSync(hSync), .x_coord(x_coord),
			.y_coord(y_coord),
			.vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
		block_controller sc(.masterclk(ClkPort), .bright(bright), .rst(reset),
			.cell_apparent(cell_val_apparent), .x_coord(x_coord), .y_coord(y_coord),
			.x_pos(x_pos), .y_pos(y_pos), .hCount(hc), .vCount(vc), .splash_screen(splash_screen),
			.rgb(rgb), .background(background));
		

	/* == OUTPUT: LEDs == */
		assign {Ld7, Ld6, Ld5, Ld4}		=	{0, 0, 0, BtnC};
		assign {Ld3, Ld2, Ld1, Ld0}		=	{BtnL, BtnU, BtnR, BtnD};

	/* == OUTPUT: SSDs == */
<<<<<<< HEAD
		assign SSD7 = Sw14 ?	num_non_mines[7:4]	:	y_coord[3:0];
		assign SSD6 = Sw14 ?	num_non_mines[3:0]	:	x_coord[3:0];
=======
		assign SSD7 = Sw14 ?	num_non_mines[7:4]	:	y_pos[3:0];
		assign SSD6 = Sw14 ?	num_non_mines[3:0]	:	x_pos[3:0];
>>>>>>> map
		assign SSD5 = Sw14 ?	num_mines[7:4]		:	cells_to_open[7:4];
		assign SSD4 = Sw14 ?	num_mines[3:0]		:	cells_to_open[3:0];
		assign SSD3 = Sw14 ?	rand[7:4]			:	4'b0000;
		assign SSD2 = Sw14 ?	rand[3:0]			:	state[3:0];
<<<<<<< HEAD
		assign SSD1 = Sw14 ?	seed[7:4]			:	{3'b000, cell_val_apparent[4]};
		assign SSD0 = Sw14 ?	seed[3:0]			:	cell_val_apparent[3:0];
=======
		assign SSD1 = Sw14 ?	seed[7:4]			:	{3'b000, test_apparent_val[4]};
		assign SSD0 = Sw14 ?	seed[3:0]			:	test_apparent_val[3:0];
>>>>>>> map

		assign ssdscan_clk = DIV_CLK[19:17];
		assign An0 = !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));
		assign An1 = !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));
		assign An2 = !(~(ssdscan_clk[2]) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]));
		assign An3 = !(~(ssdscan_clk[2]) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]));
		assign An4 = !( (ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));
		assign An5 = !( (ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));
		assign An6 = !( (ssdscan_clk[2]) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]));
		assign An7 = !( (ssdscan_clk[2]) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]));

		always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3, SSD4, SSD5, SSD6, SSD7) begin : SSD_SCAN_OUT
			case (ssdscan_clk) 
					3'b000: SSD = SSD0;
					3'b001: SSD = SSD1;
					3'b010: SSD = SSD2;
					3'b011: SSD = SSD3;
					3'b100: SSD = SSD4;
					3'b101: SSD = SSD5;
					3'b110: SSD = SSD6;
					3'b111: SSD = SSD7;
			endcase
		end

		assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};

		always @ (SSD) begin : HEX_TO_SSD
			case (SSD)
				4'b0000: SSD_CATHODES = 8'b00000011; // 0
				4'b0001: SSD_CATHODES = 8'b10011111; // 1
				4'b0010: SSD_CATHODES = 8'b00100101; // 2
				4'b0011: SSD_CATHODES = 8'b00001101; // 3
				4'b0100: SSD_CATHODES = 8'b10011001; // 4
				4'b0101: SSD_CATHODES = 8'b01001001; // 5
				4'b0110: SSD_CATHODES = 8'b01000001; // 6
				4'b0111: SSD_CATHODES = 8'b00011111; // 7
				4'b1000: SSD_CATHODES = 8'b00000001; // 8
				4'b1001: SSD_CATHODES = 8'b00001001; // 9
				4'b1010: SSD_CATHODES = 8'b00010001; // A
				4'b1011: SSD_CATHODES = 8'b11000001; // B
				4'b1100: SSD_CATHODES = 8'b01100011; // C
				4'b1101: SSD_CATHODES = 8'b10000101; // D
				4'b1110: SSD_CATHODES = 8'b01100001; // E
				4'b1111: SSD_CATHODES = 8'b01110001; // F
				default: SSD_CATHODES = 8'bXXXXXXXX; // default
			endcase
		end

endmodule