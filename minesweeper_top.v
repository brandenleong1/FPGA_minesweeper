module minesweeper_top (
		QuadSpiFlashCS,									// disable the memory chip
		ClkPort,										// the 100 MHz incoming clock signal
		BtnL, BtnU, BtnD, BtnR,							// the Left, Up, Down, and the Right buttons
		BtnC,											// the Center button
		Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw9, Sw8,	// left 8 switches
		Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0,			// right 8 switches
		Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0,			// 8 LEDs
		An7, An6, An5, An4, An3, An2, An1, An0,			// 8 anodes
		Ca, Cb, Cc, Cd, Ce, Cf, Cg,						// 7 cathodes
		Dp												// Dot Point Cathode on SSDs
	);

	/* == INPUTS == */
		input		ClkPort;
		input		BtnL, BtnU, BtnD, BtnR, BtnC;
		input		Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw9, Sw8;
		input		Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0;

	/* == OUTPUTS == */
		output		QuadSpiFlashCS;
		output		Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0;
		output		Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
		output		An7, An6, An5, An4, An3, An2, An1, An0;

	/* == PARAMETERS == */
		parameter x_size = 16;
		parameter y_size = 16;
		parameter x_coord_bits = 4;
		parameter y_coord_bits = 4;

	/* == LOCAL SIGNALS == */
		wire		reset, ClkPort;
		wire		board_clk, sys_clk;
		wire [2:0]	ssdscan_clk;
		reg [26:0]	DIV_CLK;

		wire		BtnL_Pulse, BtnU_Pulse, BtnD_Pulse, BtnR_Pulse, BtnC_Pulse;
		reg [3:0]	SSD;
		wire [3:0]	SSD7, SSD6, SSD5, SSD4, SSD3, SSD2, SSD1, SSD0;
		reg [7:0]	SSD_CATHODES;
		wire [4:0]	btns; // L, U, D, R, C

		reg [(x_coord_bits - 1):0] x_coord;
		reg [(y_coord_bits - 1):0] y_coord;
		// wire [(x_coord_bits - 1):0] x_coord;
		// wire [(y_coord_bits - 1):0] y_coord;
		wire [4:0] cell_val_board;
		wire [1:0] cell_val_cover;
		wire [(x_coord_bits + y_coord_bits - 1):0] num_mines;
		wire [31:0] rand, seed;
		wire flag, open;

		wire is_init;
		reg test;

	/* == ASSIGNMENTS == */
		assign {QuadSpiFlashCS} = 1'b1;
		assign reset = BtnC && Sw0;

		assign btns = {BtnL_Pulse, BtnU_Pulse, BtnD_Pulse, BtnR_Pulse, BtnC_Pulse};

		// assign y_coord = {Sw15, Sw14, Sw13, Sw12};
		// assign x_coord = {Sw11, Sw10, Sw9, Sw8};

		assign flag = BtnC_Pulse && Sw1 && ~Sw0;
		assign open = BtnC_Pulse && ~Sw1 && ~Sw0;

	/* == CLOCK DIVISION == */
		BUFGP BUFGP1(board_clk, ClkPort);

		always @ (posedge board_clk, posedge reset) begin
			if (reset)
				DIV_CLK <= 0;
			else
				DIV_CLK <= DIV_CLK + 1'b1;
		end

		assign sys_clk = board_clk;
		// assign sys_clk = DIV_CLK[0];

	/* == DEBOUNCING == */
		debouncer #(.N_dc(28)) debouncer_L(
			.CLK(sys_clk), .RESET(reset), .PB(BtnL), .DPB( ), 
			.SCEN(BtnL_Pulse), .MCEN( ), .CCEN( )
		);

		debouncer #(.N_dc(28)) debouncer_U(
			.CLK(sys_clk), .RESET(reset), .PB(BtnU), .DPB( ), 
			.SCEN(BtnU_Pulse), .MCEN( ), .CCEN( )
		);

		debouncer #(.N_dc(28)) debouncer_D(
			.CLK(sys_clk), .RESET(reset), .PB(BtnD), .DPB( ), 
			.SCEN(BtnD_Pulse), .MCEN( ), .CCEN( )
		);

		debouncer #(.N_dc(28)) debouncer_R(
			.CLK(sys_clk), .RESET(reset), .PB(BtnR), .DPB( ), 
			.SCEN(BtnR_Pulse), .MCEN( ), .CCEN( )
		);

		debouncer #(.N_dc(28)) debouncer_C(
			.CLK(sys_clk), .RESET(reset), .PB(BtnC), .DPB( ), 
			.SCEN(BtnC_Pulse), .MCEN( ), .CCEN( )
		);

	/* == INITIALIZATION == */
		initial begin
			x_coord = 0;
			y_coord = 0;
			test = 1'b0;
		end

		always @ (sys_clk) begin
			if (reset) begin

				x_coord = 0;
				y_coord = 0;
				test = 1'b0;

			end else begin

				if (BtnC_Pulse || BtnL_Pulse) begin
					test = ~test;
				end

				case (btns)
					5'b10000: begin // LEFT
						x_coord = x_coord - 1;
						// if (x_coord >= x_size) begin
						// 	x_coord = x_size - 1;
						// end
					end

					5'b01000: begin // UP
						y_coord = y_coord - 1;
						// if (y_coord >= y_size) begin
						// 	y_coord = y_size - 1;
						// end
					end

					5'b00100: begin // DOWN
						y_coord = y_coord + 1;
						// if (y_coord >= y_size) begin
						// 	y_coord = y_size - 1;
						// end
					end

					5'b00010: begin // RIGHT
						x_coord = x_coord + 1;
						// if (x_coord >= x_size) begin
						// 	x_coord = x_size - 1;
						// end
					end
				endcase

			end
		end

	/* == DESIGN == */
		board board_arr(
			.clk(sys_clk), .reset(reset),
			.btnC_Pulse(BtnC_Pulse),
			.x_coord(x_coord), .y_coord(y_coord),
			.cell_val(cell_val_board), .num_mines(num_mines),
			.seed(seed), .rand(rand), .is_init(is_init)
		);

		board_cover board_cover_arr(
			.clk(sys_clk), .reset(reset),
			.flag(flag), .open(open),
			.x_coord(x_coord), .y_coord(y_coord),
			.cell_val(cell_val_cover), .is_init()
		);

	/* == OUTPUT: LEDs == */
		assign {Ld7, Ld6, Ld5, Ld4} = {1, reset, test, BtnC};
		assign {Ld3, Ld2, Ld1, Ld0} = {BtnL, BtnU, BtnR, BtnD};

	/* == OUTPUT: SSDs == */
		assign SSD7 = y_coord[3:0];
		assign SSD6 = x_coord[3:0];
		assign SSD5 = {3'b000, cell_val_board[4]};
		assign SSD4 = cell_val_board[3:0];
		assign SSD3 = rand[7:4];
		assign SSD2 = rand[3:0];
		assign SSD1 = seed[7:4];
		assign SSD0 = seed[3:0];

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