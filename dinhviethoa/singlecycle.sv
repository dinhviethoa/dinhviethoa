module singlecycle(
clk_i,
rst_ni,
io_sw_i,
io_lcd_o, 
io_ledg_o, 
io_ledr_o, 
io_hex0_o,
io_hex1_o,
io_hex2_o,
io_hex3_o,
io_hex4_o,
io_hex5_o,
io_hex6_o,
io_hex7_o
);
input wire clk_i;
input wire rst_ni;
input wire [31:0] io_sw_i;

output wire [31:0] io_lcd_o;
output wire [31:0] io_ledg_o;
output wire [31:0] io_ledr_o;
output wire [31:0] io_hex0_o;
output wire [31:0] io_hex1_o;
output wire [31:0] io_hex2_o;
output wire [31:0] io_hex3_o;
output wire [31:0] io_hex4_o;
output wire [31:0] io_hex5_o;
output wire [31:0] io_hex6_o;
output wire [31:0] io_hex7_o;

reg [31:0] operand_a;
reg [31:0] operand_b;
wire [31:0] pc2;
reg [31:0] rd_data;
wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire rd_wren;
wire [11:0] pc;
wire [31:0] inst;
wire br_sel;
wire [31:0] alu_data;
wire [31:0] imm;
wire [2:0] imm_sel;
wire bl_unsigned;
wire bl_equal;
wire bl_less;
wire op_a_sel;
wire op_b_sel;
wire [3:0] alu_op;
wire [31:0] ld_data; 
wire [1:0] wb_sel;
wire mem_wren;
wire [2:0] func3;

inst_memory a1(
.addr_i(pc),
.inst_o(inst)
);

regfile a2(
.clk_i(clk_i),
.rst_ni(rst_ni), 
.rs1_addr_i(inst[19:15]),
.rs2_addr_i(inst[24:20]),
.rd_addr_i(inst[11:7]),
.rd_data_i(rd_data),
.rd_wren_i(rd_wren),
.rs1_data_o(rs1_data),
.rs2_data_o(rs2_data)
);

reg_PC a3(
.clk_i(clk_i),
.rst_ni(rst_ni),
.alu_data_i(alu_data[11:0]),
.pc_o(pc),
.br_sel_i(br_sel)
);

immgen a4(
.inst_i(inst[31:7]),
.imm_sel_i(imm_sel),
.imm_o(imm)
);

brcomp a5(
.rs1_data_i(rs1_data),
.rs2_data_i(rs2_data),
.br_unsign_i(bl_unsigned),
.br_equal_o(bl_equal),
.br_less_o(bl_less)
);

assign pc2 = {{20{1'b0}},pc};
always @(*)
begin
	if(op_a_sel)
		operand_a = pc2;
	else
		operand_a = rs1_data;
end

always @(*)
begin
	if(op_b_sel)
		operand_b = imm;
	else
		operand_b = rs2_data;
end

alu a6(
.alu_op_i(alu_op),
.opa_i(operand_a),
.opb_i(operand_b),
.alu_data_o(alu_data)
);

ctrl_unit a7(
.inst_i({inst[30],inst[14:12],inst[6:0]}),
.bl_less_i(bl_less),
.bl_equal_i(bl_equal),
.imm_sel_o(imm_sel),
.func3_o(func3),
.bl_sel_o(br_sel),
.bl_unsigned_o(bl_unsigned),
.rd_wren_o(rd_wren),
.op_a_sel_o(op_a_sel),
.op_b_sel_o(op_b_sel),
.alu_op_o(alu_op),
.mem_wren_o(mem_wren),
.wb_sel_o(wb_sel)
);

slu a8(
.clk_i(clk_i),
.addr_i(alu_data[11:0]),
.func3_i(func3),
.st_data_i(rs2_data),
.st_en_i(mem_wren),
.io_sw_i(io_sw_i),
.ld_data_o(ld_data),
.io_lcd_o(io_lcd_o),
.io_ledg_o(io_ledg_o),
.io_ledr_o(io_ledr_o),
.io_hex0_o(io_hex0_o),
.io_hex1_o(io_hex1_o),
.io_hex2_o(io_hex2_o),
.io_hex3_o(io_hex3_o),
.io_hex4_o(io_hex4_o),
.io_hex5_o(io_hex5_o),
.io_hex6_o(io_hex6_o),
.io_hex7_o(io_hex7_o)
);

always @(*)
begin
	case(wb_sel)
		2'b00:
			rd_data = pc2 + 32'd4;
		2'b01:
			rd_data = alu_data;
		2'b10:
			rd_data = ld_data;
		default: ;
	endcase
end
endmodule
