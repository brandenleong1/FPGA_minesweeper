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
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
	wire grid_fill;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	reg [9:0] xcoord, ycoord;
	wire [11:0] tile1Color;
	wire [11:0] tile2Color;
	wire [11:0] tile3Color;
	wire [11:0] tile4Color;
	wire [11:0] tile5Color;
	wire [11:0] tile6Color;
	wire [11:0] tile7Color;
	wire [11:0] tile8Color;
	wire [11:0] mineColor;
	wire [11:0] coverColor;
	wire [11:0] flagColor;
	wire [11:0] openColor;
	
	parameter CURSOR_COLOR   = 12'b1111_0000_0000;
	initial begin
		background <= 12'b1111_1111_1111;
	end
	
	tile001_rom tile1(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(tile1Color));
	tile002_rom tile2(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(tile2Color));
	tile003_rom tile3(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(tile3Color));
	tile004_rom tile4(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(tile4Color));
	tile005_rom tile5(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(tile5Color));
	tile006_rom tile6(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(tile6Color));
	tile007_rom tile7(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(tile7Color));
	tile008_rom tile8(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(tile8Color));
	open_rom open_(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(openColor));
	cover_rom cover_(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(coverColor));
	flag_rom flag(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(flagColor));
	mine_rom mine(.clk(masterclk), .row(vCount-ycoord), .col(hCount-xcoord), .color_data(mineColor));
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill)
			rgb = CURSOR_COLOR;
		else if (grid_fill) begin
			case (cell_apparent)
				5'b10000: rgb = coverColor;
				5'b10001: rgb = flagColor;
				5'b00000: rgb = openColor;
				5'b00001: rgb = tile1Color;
				5'b00010: rgb = tile2Color;
				5'b00011: rgb = tile3Color;
				5'b00100: rgb = tile4Color;
				5'b00101: rgb = tile5Color;
				5'b00110: rgb = tile6Color;
				5'b00111: rgb = tile7Color;
				5'b01000: rgb = tile8Color;
			endcase
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
	
	always@(*) 
	begin
		ypos <= y_pos * 30 + 36;
		xpos <= x_pos * 30 + 224;
		ycoord <= y_coord * 30 + 36;
		xcoord <= x_coord * 30 + 224;
	end
	
endmodule
