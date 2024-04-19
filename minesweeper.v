module minesweeper(clk, reset, state);

	input clk, reset,;
	input [3:0] SCEN_Arrows;

	output reg [X:0] state; // TODO: fix bits of state

	localparam
		INIT = 4'b0001,
		IDLE = 4'b0010;

	always @ (posedge Clk, posedge Reset) begin : minesweeper_state_machine
		if (Reset) begin
			state <= INIT;
		end
		else begin
			case (state)
				INIT:
					begin
						integer i, j;
						for (i = 0; i < 16; i = i + 1)
							for (j = 0; j < 16; j = j + 1)
								board[i][j] = 0;

						// TODO: implement RNG for mines
					end
				IDLE:
					begin
						if (SCEN_Arrows == U) begin
							// TODO: Move up
						end
						else if (SCEN_Arrows == D) begin
							// TODO: Move down
						end
						else if (SCEN_Arrows == L) begin
							// TODO: Move left
						end
						else if (SCEN_Arrows == R) begin
							// TODO: Move right
						end
						else if (SCEN_M) begin
							state <= (Flag_Mode == 1'b0) ? OPEN : FLAG;
						end
					end
				FLAG:
					begin
					end
				OPEN:
					begin
					end
				
			endcase
		end
	end

endmodule