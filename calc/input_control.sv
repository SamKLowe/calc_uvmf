//input controller must walk a zero accross cols then check rows

module input_control(
	output logic [3:0] key_col,
	input logic [3:0] key_row,
	output logic ev,
	output logic [3:0] row_o,
	output logic [3:0] col_o,
	input clk,
	input reset
);

logic count_en;
reg [3:0] count;
logic [2:0] state, next;
parameter SCAN = 0, EVENT = 1, WAIT_FOR_RELEASE = 2;


// //coverage
// covergroup input_cv () @ (posedge clk);
// 	all_rows: coverpoint key_row iff (!(&key_row)){
// 		bins row1 = {4'b0111};
// 		bins row2 = {4'b1011};
// 		bins row3 = {4'b1101};
// 		bins row4 = {4'b1110};
// 	}
// endgroup
//
// input_cv input_cov1 = new();

//build 4 bit shift reg with a walking 0
always @ (posedge(clk)) begin//needs a slower clk
	if(reset == 1'b1)begin //reset
		count <= 4'b0111;
		row_o <= 4'b1111;
		ev <= 0;
	end
	else if(count_en == 1'b0) begin
		count <= count;
		row_o <= key_row;
	end
	else begin //clock high and count_en = 1
		count <= {count[2:0], count[3]}; //rotate values
	end
end
//have confirmed this works but commenting out for easier simulation
assign key_col = count;

//state conversion
always @(posedge clk or posedge reset) begin
	if(reset) begin
		state <= SCAN;
	end
	else
		state <= next;
end

assign count_en = (&key_row);

//output logic
always @ (posedge clk or posedge reset) begin
	if(reset == 1'b1)begin
		//count_en <= 1;
		ev <= 0;
		col_o <= 4'b1111;
	end
	else begin
		case (state)
			SCAN: begin
				//count_en <= 1'b1;
				ev <= 1'b0;
			end
			EVENT: begin
				//count_en <= 1'b0;
				ev <= 1'b1;
				col_o <= key_col;//{key_col[0], key_col[3:1]};
			end
			WAIT_FOR_RELEASE: begin
				//count_en <= 0;
				ev <= 1'b0;
			end
		endcase
	end
end

//next state logic
always_comb begin
	case(state)
		SCAN: begin
			if(!(&key_row))
				next = EVENT;
			else
				next = SCAN;
		end
		EVENT: begin
			if(reset)
				next = SCAN;
			else
				next = WAIT_FOR_RELEASE;
		end
		WAIT_FOR_RELEASE: begin
			if(&key_row)
				next = SCAN;
			else
				next = WAIT_FOR_RELEASE;
		end
		default:
			next = SCAN;
	endcase
end

endmodule
