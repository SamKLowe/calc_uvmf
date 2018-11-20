
module bcd (
	input [35:0] binary,
	output reg [3:0] ones,
	output reg [3:0] tens,
	output reg [3:0] hundreds,
	output reg [3:0] thousands,
	output reg [3:0] tenthousands,
	output reg [3:0] hundredthousands,
	output reg [3:0] millions,
	output reg [3:0] tenmillions,
	output reg [3:0] hundredmillions,
	output reg [3:0] billions
);

integer i;
//used BCD proccess found at http://www.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html
always @(binary) begin

	ones = 0;
	tens = 0;
	hundreds = 0;
	thousands = 0;
	tenthousands = 0;
	hundredthousands = 0;
	millions = 0;
	tenmillions = 0;
	hundredmillions = 0;
	billions = 0;

	for(i = 35; i>=0; i = i-1) begin
		//add three to columns with more than 5
		if(billions >= 5)
			billions = billions+3;
		if(hundredmillions >= 5)
			 hundredmillions = hundredmillions+3;
		if(tenmillions >= 5)
			tenmillions = tenmillions+3;
		if(millions >= 5)
			millions = millions+3;
		if(hundredthousands >= 5)
			hundredthousands = hundredthousands+3;
		if(tenthousands >= 5)
			tenthousands = tenthousands+3;
		if(thousands >= 5)
			thousands = thousands+3;
		if(hundreds >= 5)
			hundreds = hundreds+3;
		if(tens >= 5)
			tens = tens+3;
		if(ones >= 5)
			ones = ones+3;

		//shift left
		billions = billions << 1;
		billions[0] = hundredmillions[3];
		hundredmillions = hundredmillions << 1;
		hundredmillions[0] = tenmillions[3];
		tenmillions = tenmillions << 1;
		tenmillions[0] = millions[3];
		millions = millions << 1;
		millions[0] = hundredthousands[3];
		hundredthousands = hundredthousands << 1;
		hundredthousands[0] = tenthousands[3];
		tenthousands = tenthousands << 1;
		tenthousands[0] = thousands[3];
		thousands = thousands << 1;
		thousands[0] = hundreds[3];
		hundreds = hundreds << 1;
		hundreds[0] = tens[3];
		tens = tens << 1;
		tens[0] = ones[3];
		ones = ones << 1;
		ones[0] = binary[i];

	end



end
endmodule
