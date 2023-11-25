module immgen(inst_i, imm_sel_i, imm_o);

input wire [24:0] inst_i;
input wire [2:0] imm_sel_i;
output reg [31:0] imm_o;

parameter [2:0] R_type = 3'b000;
parameter [2:0] I_type = 3'b001;
parameter [2:0] S_type = 3'b010;
parameter [2:0] B_type = 3'b011;
parameter [2:0] U_type = 3'b100;
parameter [2:0] J_type = 3'b101;

always @(*)
begin
	case (imm_sel_i)
		R_type:
			imm_o = 32'd0;
		I_type:
			imm_o = {{20{inst_i[24]}},inst_i[24:13]};
		S_type: 
			imm_o = {{20{inst_i[24]}},inst_i[24:18],inst_i[4:0]};
		B_type:
			imm_o = {{20{inst_i[24]}},inst_i[0],inst_i[23:18],inst_i[4:1],1'b0};
		U_type:
			imm_o = {inst_i[24:5],{12{1'b0}}};
		J_type:
			imm_o = {{11{inst_i[24]}},inst_i[24],inst_i[12:5],inst_i[13],inst_i[23:14],1'b0};
		default:
			imm_o = 32'd0;
	endcase
end

endmodule
