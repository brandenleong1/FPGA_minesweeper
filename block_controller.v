`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input masterclk,
	input bright,
	input rst,
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
	wire [11:0] mineColor;
	
	parameter RED   = 12'b1111_0000_0000;
	initial begin
		background <= 12'b1111_1111_1111;
	end
	
	mine_rom mine(.clk(masterclk), .row(vCount-ypos), .col(hCount-xpos), .color_data(mineColor));
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill)
			rgb = 12'b1111_0000_0000;
		else if (grid_fill && mineColor != 12'b111100000000) 
			rgb = mineColor; 
		else	
			rgb=background;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos) && vCount<=(ypos+29) && hCount>=(xpos+1) && hCount<=(xpos+29);
	assign grid_fill=vCount>=(13) && hCount>=(144) && hCount<=(656);
	
	always@(*) 
	begin
		ypos <= y_pos * 32 + 13;
		xpos <= x_pos * 32 + 144;
	end
	
endmodule
