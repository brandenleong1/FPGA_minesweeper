`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:27:11 12/07/2017 
// Design Name: 
// Module Name:    DisplayController 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created

// Additional Comments:  https://learn.digilentinc.com/Documents/269
// - Use Bahavioural Modelling (always, initial)
// - Use the Following: clock divider, two counters(horizontal counter, vertical
// counter), 
//////////////////////////////////////////////////////////////////////////////////
module display_controller(
	clk, hSync, vSync,
	x_coord, y_coord,
	bright, hCount, vCount // Covers 800, width of the screen, because it's 2^10
	);
	
	parameter x_coord_bits = 4, y_coord_bits = 4;
	
	input clk;
	output hSync, vSync;
	output reg[(x_coord_bits - 1):0] x_coord;
	output reg[(y_coord_bits - 1):0] y_coord;
	output reg[9:0] hCount; 
	output reg [9:0] vCount; // Covers 800, width of the screen, because it's 2^10
	output reg bright;
	reg pulse;
	reg clk25;
	
	initial begin // Set all of them initially to 0
		clk25 = 0;
		pulse = 0;
	end
	
	always @(posedge clk)
		pulse = ~pulse;
	always @(posedge pulse)
		clk25 = ~clk25;
		
	always @ (posedge clk25)
		begin
		if (hCount < 10'd799)
			begin
			hCount <= hCount + 1;
			end
		else if (vCount < 10'd524)
			begin
			hCount <= 0;
			vCount <= vCount + 1;
			end
		else
			begin
			hCount <= 0;
			vCount <= 0;
			end
		
		if (vCount>=(13) && hCount>=(176) && hCount<=(656) && ((hCount-176)%32 == 0) && (x_coord != 15))
			begin
				x_coord <= x_coord + 1;
			end
		else if (vCount>=(13) && hCount>=(176) && hCount<=(656) && ((hCount-176)%32 == 0) && (x_coord == 15))
			begin
				x_coord <= 0;
			end
		if (vCount>=(13) && hCount>=(144) && hCount<=(656) && ((vCount-13)%32 == 0) && (y_coord != 15))
			begin
				y_coord <= y_coord + 1;
			end
		else if (vCount>=(13) && hCount>=(144) && hCount<=(656) && ((vCount-13)%32 == 0) && (y_coord == 15))
			begin
				y_coord <= 0;
			end
		else
			begin
			x_coord <= 0;
			y_coord <= 0;
			end
		end
		
	assign hSync = (hCount < 96) ? 0:1;
	assign vSync = (vCount < 2) ? 0:1;
		
	always @(posedge clk25)
		begin
		if(hCount > 10'd143 && hCount < 10'd784 && vCount > 10'd34 && vCount < 10'd516)
			bright <= 1;
		else
			bright <= 0;
		end	
		
endmodule
