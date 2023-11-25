module alu(alu_op_i, opa_i, opb_i, alu_data_o);

input [3:0] alu_op_i;
input [31:0] opa_i;
input [31:0] opb_i;
output [31:0] alu_data_o;

wire [31:0] opa_i;
wire [31:0] opb_i;
wire [3:0] alu_op_i;

reg [31:0] alu_data_o;

parameter [3:0] A_ADD = 4'h0;
parameter [3:0] A_SUB = 4'h1;
parameter [3:0] A_SLT = 4'h2;
parameter [3:0] A_SLTU = 4'h3;
parameter [3:0] A_XOR = 4'h4;
parameter [3:0] A_OR = 4'h5;
parameter [3:0] A_AND = 4'h6;
parameter [3:0] A_SLL = 4'h7;
parameter [3:0] A_SRL = 4'h8;
parameter [3:0] A_SRA = 4'h9;

reg [31:0] temp_1;

always @(*)
begin
	case (alu_op_i)
		A_ADD: 
			begin
				alu_data_o = opa_i + opb_i;
				temp_1 = 0;
			end
		A_SUB:
			begin 
				temp_1 = 0;
				alu_data_o = opa_i + temp_1;
			end
		A_SLT:
			begin
				temp_1 = ~(opb_i) + 32'd1;
				if (opa_i[31] == opb_i[31])
				begin
					alu_data_o[31:1] = 31'd0;
					alu_data_o[0] = ~(temp_1[31] ^ 1); 
				end  
				else
				begin
					alu_data_o[31:1] = 31'd0;
			    	alu_data_o[0] = opa_i[31];	
			    end
			end
		A_SLTU: 
			begin
				temp_1 = ~(opb_i) + 32'h00000001;
				alu_data_o[31:1] = 31'd0;
				alu_data_o[0] = ~(temp_1[31] ^ 1);
			end				
		A_XOR: 
			begin
				temp_1 = 0;
				alu_data_o = opa_i ^ opb_i;
			end
		A_OR:
			begin
				temp_1 = 0;
				alu_data_o = opa_i | opb_i;
			end
		A_AND:
			begin
				temp_1 = 0;
				alu_data_o = opa_i & opb_i;
			end
		A_SLL:
			begin
				temp_1 = 0;
				alu_data_o = opa_i << opb_i;
			end
		A_SRL:
			begin
				temp_1 = 0;
				alu_data_o = opa_i >> opb_i;
			end
		A_SRA: 
			begin
			temp_1 = 0;
	        alu_data_o = opa_i >>> opb_i;
	        end
	    default:
	    begin
        	temp_1 = 0;  
	    	alu_data_o = 32'h00000000;
	    end
	endcase
end
endmodule 
