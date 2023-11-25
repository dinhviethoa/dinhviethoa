module reg_PC(
clk_i, 
rst_ni, 
alu_data_i, 
pc_o, 
br_sel_i);

input wire clk_i;
input wire rst_ni;
input wire br_sel_i;
input wire [11:0] alu_data_i;
output reg [11:0] pc_o;

always @(posedge clk_i)
begin
	if (!rst_ni)
		pc_o <= 12'd0;
	else
		begin
			if (br_sel_i)
			begin
				pc_o <= pc_o +alu_data_i;
			end
			else
				pc_o <= pc_o + 12'd4;
		end
end
endmodule
