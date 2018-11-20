

module main_control (
	input [3:0] col,
	input [3:0] row,
	input ev,
	output reg disp_en,
	output reg valid,
	output reg [35:0] disp,
	output div0,
	input clk,
	input reset

);
//non-integer buttons
parameter plus = 10, minus = 11, mult = 12, div = 13, enter = 14, clr = 15, no_button = 16;
//states
//parameter error = 0, sit = 1, clear = 2, store = 3, pushdigit = 4, popload1 = 5, popload2 = 6, pushans = 7, compans = 8;

typedef enum{
	SCAN =  0,
	CLEAR = 1,
	PUSH_DIG = 2,
	PUSH_MEM1 = 3,
	PUSH_MEM2 = 4,
	LOAD = 5,
	STORE = 6,
	POP_MEM = 7,
	PUSH_MEM3 = 8,
	WAIT_POP_MEM = 9,
	LOAD2 = 10,
	STORE2 = 11
} state_type;

logic [11:0] state, next;

//ALU
reg [1:0] operator;
logic signed [35:0] A;
logic signed [35:0] B;
logic signed [35:0] Y;

//stack wires/regs
reg push_digit;
reg pop_digit;
wire [9:0] dig_ptr;
reg push_mem;
reg pop_mem;
wire [9:0] mem_ptr;
wire [3:0] out_dig1;
wire [3:0] out_dig2;
wire [35:0] out_mem1;
wire [35:0] out_mem2;
reg [35:0] in_mem;
reg stack_reset;


reg [1:0] push_count;


//concat the two col and row values then map them to digits or operators
//may move this to input block or its own
wire [8:0] colrow_i;
wire [3:0] state_check;
reg [31:0] digit_i;
assign colrow_i = {col, row};

initial begin
	state = 12'b1;
end

//col and row lut
always @(colrow_i) begin
	case (colrow_i)
		8'b01110111:
			digit_i = 7;
		8'b10110111:
			digit_i = 8;
		8'b11010111:
			digit_i = 9;
		8'b11100111:
			digit_i = plus;
		8'b01111011:
			digit_i = 4;
		8'b10111011:
			digit_i = 5;
		8'b11011011:
			digit_i = 6;
		8'b11101011:
			digit_i = minus;
		8'b01111101:
			digit_i = 1;
		8'b10111101:
			digit_i = 2;
		8'b11011101:
			digit_i = 3;
		8'b11101101:
			digit_i = mult;
		8'b01111110:
			digit_i = clr;
		8'b10111110:
			digit_i = 0;
		8'b11011110:
			digit_i = enter;
		8'b11101110:
			digit_i = div;
		8'b11111111:
			digit_i = no_button;
		default:
			digit_i = 0;
	endcase
end

//going for a "one hot" state machine

//sequential state transition
always @(posedge clk or posedge reset) begin
	if(reset) begin
		state <= 13'b1; //default assign;
	end
	else
		state <= next;
end

//combinational next state logic
always_comb begin
	next = '0; //make sure no mistakes
	unique case(1'b1)
		state[SCAN] : begin

			if(ev == 1'b1) begin
				if(digit_i < plus)begin //digit
					next[PUSH_DIG] = 1'b1;
				end
				else if(digit_i == clr) begin
					next[CLEAR] = 1'b1;
				end
				else if(digit_i == enter) begin
					next[PUSH_MEM1] = 1'b1;
				end
				// else if(digit_i == no_button) begin //nothing
				// 	next[SCAN] = 1'b1;
				// end
				else //operator
					next[POP_MEM] = 1'b1;
			end
			else
				next[SCAN] = 1'b1; //nothing happens
		end
		state[CLEAR]: begin
			next[SCAN] = 1'b1;
		end
		state[PUSH_DIG]: begin
			next[SCAN] = 1'b1;
		end
		state[PUSH_MEM1]: begin
			next[PUSH_MEM2] = 1'b1;
		end
		state[PUSH_MEM2]: begin
			next[PUSH_MEM3] = 1'b1;
		end
		state[PUSH_MEM3]: begin
			next[SCAN] = 1'b1;
		end
		state[POP_MEM]: begin
			next[WAIT_POP_MEM] = 1'b1;
		end
		state[WAIT_POP_MEM]: begin
			next[LOAD] = 1'b1;
		end
		state[LOAD]: begin
			next[LOAD2] = 1'b1;
		end
		state[LOAD2]: begin
			next[STORE] = 1'b1;
		end
		state[STORE]: begin
			next[STORE2] = 1'b1;
		end
		state[STORE2]:begin
			next[SCAN] = 1'b1;
		end
		default:
			next[SCAN] = 1'b1;
	endcase
end

always @ (posedge(clk) or posedge reset)
begin
	if(reset == 1'b1)begin

		disp_en <= 0;
		operator <= 0;
		A <= 0;
		B <= 0;
		pop_digit <= 0;
		push_count <= 0;
		pop_mem <= 0;
		stack_reset <= 1;
		push_digit <= 0;
		in_mem <= 0;
		push_mem <= 0;
		disp <= 0;
		valid <= 0;

	end
	else begin
		disp_en <= 1;
		unique case(1'b1)
			state[SCAN]: begin
				push_mem <= 0;
				push_digit <= 0;
				pop_digit <= 0;
				pop_mem <= 0;
				stack_reset <= 0;
				valid <= 0;
			end
			state[CLEAR]: begin
				stack_reset <= 1;
				disp <= 0;
				valid <= 0;
			end
			state[PUSH_DIG]: begin
				push_digit <= 1;
			end
			state[PUSH_MEM1]: begin
				pop_digit <= 1;
			end
			state[PUSH_MEM2]: begin
				pop_digit <= 1;
			end
			state[PUSH_MEM3]: begin
				pop_digit = 0;
				in_mem <= out_dig1 + (out_dig2 * 10);
				push_mem <= 1;
			end
			state[POP_MEM]: begin
				pop_mem <= 1;
				operator <= digit_i -10;
			end
			state[WAIT_POP_MEM]: begin
				pop_mem <= 0;
			end
			state[LOAD]: begin
				B <= out_mem1;
				A <= out_mem2;
			end
			state[LOAD2]: begin
				//nothing

			end
			state[STORE]: begin
				in_mem <= Y;
				disp <= Y;
				valid <= 1;
			end
			state[STORE2]: begin
				push_mem <= 1;
			end
			default: begin
				push_mem = 0;
				pop_mem = 0;
				push_digit = 0;
				pop_digit = 0;
				stack_reset = 0;
			end


		endcase


	end


end


//alu
alu calc(
	.op(operator),
	.A(A),
	.B(B),
	.Y(Y),
	.error(div0),
	.clk(clk),
	.reset(reset)
);

//instantiate my two stacks
//digit stack


stack #(.WIDTH(4), .DEPTH(10))digit(
	.d(digit_i[3:0]),
	.q1(out_dig1),
	.q2(out_dig2),
	.push(push_digit),
	.pop(pop_digit),
	.ptr(dig_ptr),
	.clk(clk),
	.reset(stack_reset)
);
stack #(.WIDTH(36), .DEPTH(10))memory(
	.d(in_mem),
	.q1(out_mem1),
	.q2(out_mem2),
	.push(push_mem),
	.pop(pop_mem),
	.ptr(mem_ptr),
	.clk(clk),
	.reset(stack_reset)
);



endmodule
