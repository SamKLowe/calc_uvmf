//sseg decoder, clk divider, cathode signals

module display(
	input clk,
	input signed [35:0] binary,
	input disp_en,
	input div0,
	output reg [6:0] sseg_a,
	output reg [9:0] sseg_c,
	output reg neg,
	input reset

);

wire [3:0] d0;
wire [3:0] d1;
wire [3:0] d2;
wire [3:0] d3;
wire [3:0] d4;
wire [3:0] d5;
wire [3:0] d6;
wire [3:0] d7;
wire [3:0] d8;
wire [3:0] d9;

parameter E = 10;
parameter r = 11;
parameter o = 12;
parameter off = 13;

// covergroup display_cv () @ (posedge clk);
// 	neg_input: coverpoint binary {
// 		bins neg_values = {[$:-1]};
// 	}
// endgroup
//
// display_cv disp_cov1 = new();

//check for twos copliment
reg [35:0] unsigned_bin;
always @(binary, reset) begin
	if(reset) begin
		unsigned_bin = 0;
		neg = 0;
	end
	else if(binary[35] == 1'b1) begin//negative
		unsigned_bin = ~binary;
		unsigned_bin = unsigned_bin + 1;
		neg = 1;
	end
	else begin//positive
		unsigned_bin = binary;
		neg = 0;
	end
end


//instantiate BCD conversion
bcd convert(
	.binary(unsigned_bin),
	.ones(d0),
	.tens(d1),
	.hundreds(d2),
	.thousands(d3),
	.tenthousands(d4),
	.hundredthousands(d5),
	.millions(d6),
	.tenmillions(d7),
	.hundredmillions(d8),
	.billions(d9)
);

//clock divider to create sseg clk
reg [3:0] count;
//my gated clock
reg clk_div;

//clk divider value will need to be slower for real world
parameter divider = 1;

always @ (posedge clk) begin
	if(reset) begin
		count <= 0;
		clk_div <= 0;
	end
	else begin
		if(count < divider)
			count <= count + 1;
		else begin
			count <= 0;

			clk_div <= ~clk_div;

		end
	end
end


reg [3:0] output_dig;
reg [3:0] sel_count;
//shift register to select output cathode
//4 bit counter for selection
always @(posedge clk_div or posedge reset)begin
	if(reset) begin
		sseg_c <= 10'b1111111110;
		sel_count <= 0;
	end
	else begin
		sseg_c = {sseg_c[8:0], sseg_c[9]};
		if(sel_count == 9)
			sel_count <= 0;
		else
			sel_count++;
	end
end

//mux for display out using sel count
always @(sel_count, div0) begin
	if(div0 == 0)begin
		case(sel_count)
			0:
				output_dig = d0;
			1:
				output_dig = d1;
			2:
				output_dig = d2;
			3:
				output_dig = d3;
			4:
				output_dig = d4;
			5:
				output_dig = d5;
			6:
				output_dig = d6;
			7:
				output_dig = d7;
			8:
				output_dig = d8;
			9:
				output_dig = d9;
			default:
				output_dig = 0;

		endcase
	end
	else begin
		case(sel_count)
			0:
				output_dig = r;
			1:
				output_dig = o;
			2:
				output_dig = r;
			3:
				output_dig = r;
			4:
				output_dig = E;
			5:
				output_dig = off;
			6:
				output_dig = off;
			7:
				output_dig = off;
			8:
				output_dig = off;
			9:
				output_dig = off;
			default:
				output_dig = 0;

		endcase
	end

end

//mux for relating digits to sseg
always @(output_dig, disp_en) begin
    if(disp_en == 1)begin
        case(output_dig)
            0:
                sseg_a = 7'b1000000;
            1:
                sseg_a = 7'b1111001;
            2:
                sseg_a = 7'b0100100;
            3:
                sseg_a = 7'b0110000;
            4:
                sseg_a = 7'b0011001;
            5:
                sseg_a = 7'b0010010;
            6:
                sseg_a = 7'b0000010;
            7:
                sseg_a = 7'b1111000;
            8:
                sseg_a = 7'b0000000;
            9:
                sseg_a = 7'b0011000;
            E:
                sseg_a = 7'b0000110;
            r:
                sseg_a = 7'b0101111;
            o:
                sseg_a = 7'b0100011;
						off:
								sseg_a = 7'b1111111;
            default:
								sseg_a = 7'b1000000;
        endcase
    end
    else
        sseg_a = 7'b0000000;
end



initial begin
	clk_div = 0;
	count = 0;
	sel_count = 0;
	output_dig = 0;
	sseg_c = 10'b1111111110;
	sseg_a = 0;

end

endmodule
