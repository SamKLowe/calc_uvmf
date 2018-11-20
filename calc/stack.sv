
module stack #(parameter WIDTH = 36, parameter DEPTH = 10) (
	input signed [WIDTH-1:0] d,
	output reg signed [WIDTH-1:0] q1,
	output reg signed [WIDTH-1:0] q2,
	input push,
	input pop,
	output logic [9:0] ptr,
	input reset,
	input clk

);

parameter SCAN = 2'b00;
parameter PUSH = 2'b01;
parameter POP = 2'b10;

byte stack_depth;

logic [1:0] state;

reg [WIDTH - 1:0] stack [0: DEPTH - 1];
integer i = 0;

// //cpverage
// covergroup stack_cv () @ (posedge clk);
// 	c_push: coverpoint push;
// 	c_pop: coverpoint pop;
// 	c_depth: coverpoint stack_depth{
// 		bins two_deep = {2};
// 	}
//
// endgroup
//
// stack_cv stack_cov1 = new();

//state machine
always @(posedge clk) begin
	stack_depth = ptr;
	if (reset)begin
		ptr <= 0;
		q1 <= 0;
		q2 <= 0;
		for(i = 0; i < DEPTH; i = i+1)
		begin
			stack[i] <= 0;
		end
	end
	else
		if(push == 1'b1)begin
			stack[ptr+1] <= d;
			ptr <= ptr + 1;
		end
		else if(pop && (ptr > 0))begin
			if(ptr == 1)begin //if only one member
				q1 <= stack[ptr];
				q2 <= 0;
				ptr <= 0;
			end
			else begin
				q1 <= stack[ptr];
				q2 <= stack[ptr-1];
				ptr <= ptr - 2;
			end
		end
		else if(pop && (ptr < 1)) begin
			q1 <= 0;
			q2 <= 0;
		end
end
endmodule
