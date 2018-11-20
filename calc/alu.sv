//A <op> B = Y

module alu (
	input [1:0] op,
	input  signed [35:0] A,
	input  signed [35:0] B,
	output reg [35:0] Y,
	output reg error,

	input clk,
	input reset

);

parameter add = 0;
parameter sub = 1;
parameter mult = 2;
parameter div = 3;

// covergroup alu_cv () @ (posedge clk);
// 	A_neg_value: coverpoint op iff (A<0);
// 	B_neg_value: coverpoint op iff (B<0);
// 	A_zero_value: coverpoint op iff (A == 0);
// 	B_zero_value: coverpoint op iff (B == 0);
// 	Div_zero: coverpoint error iff (B == 0 && op == div);
// endgroup
//
// alu_cv alu_cov1 = new();



always@ (posedge(clk)) begin
	if(reset==1'b1) begin
		Y <= 0;
		error <= 0;
	end
	else begin
        case(op)
            add: begin
                Y <= A+B;
				error <= 0;
            end
            sub: begin
                Y <= A-B;
				error <= 0;
            end
            mult: begin
                Y <= A*B;
				error <= 0;
            end
            div: begin
				if(B == 0)begin
					Y <= 0;
					error <= 1;
				end
				else begin
					Y <= A/B;
					error <= 0;
				end
            end
				default: begin
					Y <= 0;
					error <= 1;
				end
        endcase
	end
end



endmodule
