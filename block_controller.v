`timescale 1ns / 1ps

module block_controller(
	input masterclk,
	input bright,
	input rst,
	input [4:0] cell_apparent,
	input [3:0] x_coord,
	input [3:0] y_coord,
	input [3:0] x_pos,
	input [3:0] y_pos,
	input [9:0] hCount, vCount,
	input [1:0] splash_screen,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
	wire grid_fill;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	reg [9:0] xcoord, ycoord;
	wire [11:0] spriteColor;
	reg [9:0] spriteRow;
	reg [9:0] spriteCol;
	
	parameter CURSOR_COLOR   = 12'b1111_0000_0000;
	initial begin
		background <= 12'b1111_1111_1111;
	end
	all_sprites_rom sprites(.clk(masterclk), .row(spriteRow), .col(spriteCol), .color_data(spriteColor));
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (splash_screen == 2'b01 && start_fill) begin
			spriteRow <= vCount-136;
			spriteCol <= hCount-274;
		end
		else if (splash_screen == 2'b10 && lose_fill) begin
			spriteRow <= vCount-136;
			spriteCol <= hCount-274;
		end
		else if (splash_screen == 2'b11 && win_fill) begin
			spriteRow <= vCount-136;
			spriteCol <= hCount-274;
		end
		else if (block_fill)
			rgb = CURSOR_COLOR;
		else if (grid_fill) begin
			case (cell_apparent)
				5'b10000: begin // Cover
					spriteRow <= vCount-ycoord+30;
					spriteCol <= hCount-xcoord;
				end
				5'b10001: begin // flag
					spriteRow <= vCount-ycoord+30;
					spriteCol <= hCount-xcoord+30;
				end
				5'b00000: begin // open
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord;
				end
				5'b00001: begin // tile 1
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord+30;
				end
				5'b00010: begin // Tile 2
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord+60;
				end
				5'b00011: begin // Tile 3
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord+90;
				end
				5'b00100: begin // Tile 4
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord+120;
				end
				5'b00101: begin // Tile 5
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord+150;
				end
				5'b00110: begin // Tile 6
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord+180;
				end
				5'b00111: begin // Tile 7
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord+210;
				end
				5'b01000: begin // Tile 8
					spriteRow <= vCount-ycoord;
					spriteCol <= hCount-xcoord+240;
				end
				5'b11111: begin // Mine
					spriteRow <= vCount-ycoord+30;
					spriteCol <= hCount-xcoord+60;
				end
			endcase
			rgb = spriteColor;
		end
		else	
			rgb=background;
	end
		// Block fill is only a sliver around the cursor. CursorWidth is 3
	assign block_fill= (vCount>=(ypos) && vCount <= (ypos+3) && hCount<=(xpos+29) && hCount>=(xpos+1)) || 
	(vCount>=(ypos+26) && vCount <= (ypos+29) && hCount<=(xpos+29) && hCount>=(xpos+1)) ||
	(vCount>=(ypos) && vCount <= (ypos+29) && hCount<=(xpos+4) && hCount>=(xpos+1)) || 
	(vCount>=(ypos) && vCount <= (ypos+29) && hCount<=(xpos+29) && hCount>=(xpos+26));
	assign grid_fill=vCount>=(36) && hCount>=(224) && hCount<=(704);
	assign win_fill=vCount>=(136) && vCount <196 && hCount>=(274) && hCount<=(500);
	assign lose_fill=vCount>=(136) && vCount <196 && hCount>=(274) && hCount<=(500);
	assign start_fill=vCount>=(136) && vCount <196 && hCount>=(274) && hCount<=(550);
	
	always@(*) 
	begin
		ypos <= y_pos * 30 + 36;
		xpos <= x_pos * 30 + 224;
		ycoord <= y_coord * 30 + 36;
		xcoord <= x_coord * 30 + 224;
	end
	
endmodule
