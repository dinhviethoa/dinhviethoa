module ctrl_unit(
inst_i,
bl_less_i,
bl_equal_i,
imm_sel_o,
func3_o, 
bl_sel_o, 
bl_unsigned_o, 
rd_wren_o, 
op_a_sel_o,
op_b_sel_o, 
alu_op_o, 
mem_wren_o, 
wb_sel_o);

input wire [10:0] inst_i;
input wire bl_less_i;
input wire bl_equal_i;
output reg [2:0] func3_o;
output reg [2:0] imm_sel_o;
output reg bl_sel_o;
output reg bl_unsigned_o;
output reg rd_wren_o;
output reg op_a_sel_o;
output reg op_b_sel_o;
output reg [3:0] alu_op_o;
output reg mem_wren_o;
output reg [1:0] wb_sel_o;

always @(*)
begin
	case (inst_i[6:0])
		7'b0110011: 
			begin
				imm_sel_o = 3'd0;
				bl_sel_o = 1'b0;
				bl_unsigned_o = 1'b0;
				rd_wren_o = 1'b1;
				op_a_sel_o = 1'b0;
				op_b_sel_o = 1'b0;
				func3_o = 3'b010;
				mem_wren_o = 1'b0;
				wb_sel_o = 2'b01;
				case(inst_i[9:7])
					3'b000:
						if (!inst_i[10])
							alu_op_o = 4'd0;
						else
							alu_op_o = 4'd1;
					3'b001:
						alu_op_o = 4'd7;
					3'b010:
						alu_op_o = 4'd2;
					3'b011:
						alu_op_o = 4'd3;
					3'b100:
						alu_op_o = 4'd4;
					3'b101:
						if (!inst_i[10])
							alu_op_o = 4'd8;
						else
							alu_op_o = 4'd9;
					3'b110:
						alu_op_o = 4'd5;
					3'b111:
						alu_op_o = 4'd6;
				endcase						 
			end
		7'b0010011:
			begin
				imm_sel_o = 3'b001;
				bl_sel_o = 1'b0;
				bl_unsigned_o = 1'b0;
				rd_wren_o = 1'b1;
				op_a_sel_o = 1'b0;
				op_b_sel_o = 1'b1;
				func3_o = 3'b010;
				mem_wren_o = 1'b0;
				wb_sel_o = 2'b01;
				case(inst_i[9:7])
					3'b000:
						alu_op_o = 4'd0;
					3'b001:
						alu_op_o = 4'd7;
					3'b010:
						alu_op_o = 4'd2;
					3'b011:
						alu_op_o = 4'd3;
					3'b100:
						alu_op_o = 4'd4;
					3'b101:
						if (!inst_i[10])
							alu_op_o = 4'd8;
						else
							alu_op_o = 4'd9;
					3'b110:
						alu_op_o = 4'd5;
					3'b111:
						alu_op_o = 4'd6;
				endcase						
			end
		7'b0000011:
			begin
				imm_sel_o = 3'b001;
				bl_sel_o = 1'b0;
				bl_unsigned_o = 1'b0;
				rd_wren_o = 1'b1;
				op_a_sel_o = 1'b0;
				op_b_sel_o = 1'b1;
				mem_wren_o = 1'b0;
				wb_sel_o = 2'b10;
				func3_o = inst_i[9:7];
				/*case(inst_i[7:5])
					3'b000:
						
					3'b001:
					
					3'b010:
					
					3'b011:
						
					3'b100:
						
					3'b101:
	
					3'b110:
						
					3'b111:
						
					default: ;
				endcase*/
				alu_op_o = 4'd0;					
			end
		7'b0100011:
			begin
				imm_sel_o = 3'b010;
				bl_sel_o = 1'b0;
				bl_unsigned_o = 1'b0;
				rd_wren_o = 1'b0;
				op_a_sel_o = 1'b0;
				op_b_sel_o = 1'b1;
				mem_wren_o = 1'b1;
				wb_sel_o = 2'b00;
				func3_o = inst_i[9:7];
				/*case(inst_i[7:5])
					3'b000:
					
					3'b001:
					
					3'b010:
					
					3'b011:
					
					3'b100:
					
					3'b101:
					
					3'b110:
					
					3'b111:
					
					default: ;
				endcase*/
				alu_op_o =4'd0;					
			end	
		7'b1100011:
			begin
				imm_sel_o = 3'b011;
					case(inst_i[9:7])
					3'b000:
						begin
						bl_unsigned_o = 1'b0;
						if (bl_equal_i) 
							bl_sel_o = 1'b1;
						else
							bl_sel_o = 1'b0;
						end
					3'b001:
						begin
						bl_unsigned_o = 1'b0;
						if (bl_equal_i)
							bl_sel_o = 1'b0;
						else
							bl_sel_o = 1'b1;
						end	
					3'b100:
						begin
						bl_unsigned_o = 1'b0;
						if (bl_less_i)
							bl_sel_o = 1'b1;
						else
							bl_sel_o = 1'b0;
						end
					3'b101:
						begin
						bl_unsigned_o = 1'b0;
						if (!bl_less_i)
							bl_sel_o = 1'b1;
						else
 							bl_sel_o = 1'b0;
 						end	
					3'b110:
						begin
						bl_unsigned_o = 1'b1;
						if (bl_less_i)
							bl_sel_o = 1'b1;
						else
							bl_sel_o = 1'b0;
						end
					3'b111:
						begin
						bl_unsigned_o = 1'b1;
						if (!bl_less_i)
						bl_sel_o = 1'b1;
						else
						bl_sel_o = 1'b0;
						end
					default:
						begin
							bl_sel_o = 1'b0;
							bl_unsigned_o = 1'b0;
						end	
				endcase					
				rd_wren_o = 1'b0;
				op_a_sel_o = 1'b1;
				op_b_sel_o = 1'b1;
				func3_o = 3'b010;
				mem_wren_o = 1'b0;
				wb_sel_o = 2'b00;
				alu_op_o = 4'd0;	
			end
		7'b0110111:
			begin
				imm_sel_o = 3'b100;
				bl_unsigned_o = 1'b0;
				bl_sel_o = 1'b0;
				rd_wren_o = 1'b1;
				op_a_sel_o = 1'b1;
				op_b_sel_o = 1'b1;
				func3_o = 3'b010;
				mem_wren_o = 1'b0;
				wb_sel_o = 2'b01;
				alu_op_o = 4'd0;	
			end
		7'b1101111:
			begin
				imm_sel_o = 3'b101;
				bl_unsigned_o = 1'b0;
				bl_sel_o = 1'b1;
				rd_wren_o = 1'b1;
				func3_o = 3'b010;
				op_a_sel_o = 1'b1;
				op_b_sel_o = 1'b1;
				mem_wren_o = 1'b0;
				wb_sel_o = 2'b00;
				alu_op_o = 4'd0;	
			end
		7'b1100111:
			begin
				imm_sel_o = 3'b001;
				bl_unsigned_o = 1'b0;
				bl_sel_o = 1'b1;
				rd_wren_o = 1'b1;
				op_a_sel_o = 1'b0;
				func3_o = 3'b010;
				op_b_sel_o = 1'b1;
				mem_wren_o = 1'b0;
				wb_sel_o = 2'b00;
				alu_op_o = 4'd0;
			end
		default:
			begin
				imm_sel_o = 3'b000;
				bl_unsigned_o = 1'b0;
				bl_sel_o = 1'b0;
				rd_wren_o = 1'b0;
				op_a_sel_o = 1'b0;
				op_b_sel_o = 1'b0;
				func3_o = 3'b010;
				mem_wren_o = 1'b0;
				wb_sel_o = 2'b00;
				alu_op_o = 4'd0;
			end
	endcase
end
endmodule
