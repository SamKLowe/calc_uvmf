

module calc (
	output [3:0] col,
	input [3:0] row,
	output [6:0] sseg_A,
	output [9:0] sseg_C,
	output [35:0] value,
  output valid,
	output neg,


	input clk,
	input reset

);

//Input controller

wire ev;
wire [3:0] row_o;
wire [3:0] col_o;


wire [35:0] disp;
wire div0;

input_control input_controller(
	.key_col(col),
	.key_row(row),
	.ev(ev),
	.row_o(row_o),
	.col_o(col_o),
	.clk(clk),
	.reset(reset));

//main controller
wire disp_en;
main_control main_controller(
	.col(col_o),
	.row(row_o),
	.ev(ev),
	.disp_en(disp_en),
	.disp(disp),
  .valid(valid),
	.div0(div0),
	.clk(clk),
	.reset(reset)
);


//display components
display display_controller(
	.binary(disp),
	.disp_en(disp_en),
	.sseg_a(sseg_A),
	.sseg_c(sseg_C),
	.div0(div0),
	.neg(neg),
	.clk(clk),
	.reset(reset)
);

//wire out disp for scoreboard
assign value = disp;

endmodule
