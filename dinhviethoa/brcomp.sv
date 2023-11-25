module brcomp(rs1_data_i, rs2_data_i, br_unsign_i, br_less_o, br_equal_o);

input [31:0] rs1_data_i;
input [31:0] rs2_data_i;
input br_unsign_i;
output br_less_o;
output br_equal_o;

wire [31:0] rs1_data_i;
wire [31:0] rs2_data_i;
wire br_unsign_i;
reg br_less_o;
reg br_equal_o;

reg [31:0] temp;
reg [31:0] temp_1;

assign temp = rs1_data_i + ~(rs2_data_i) + 1;
assign temp_1 = temp ^ 32'hffffffff;
 
always @(*)
begin
	if (temp_1 == 32'hffffffff)
	begin
		br_equal_o = 1;
		br_less_o = 0;
	end
	else 
	begin
		br_equal_o = 0;
		if (br_unsign_i == 0)
		begin
			if (rs1_data_i[31] == rs2_data_i[31])
				br_less_o = !(temp[31] ^ 1);
			else
			    br_less_o = rs1_data_i[31];
		end
		else
			br_less_o = !(temp[31] ^ 1);
	end	
end
endmodule
