module inst_memory(addr_i, inst_o);

input [11:0] addr_i;
output [31:0] inst_o;

wire [11:0] addr_i;
wire [31:0] inst_o;

reg [31:0] arr_inst [4095:0];

initial 
begin
	$readmemh("./memory/instmem.data", arr_inst);
end

assign inst_o = arr_inst[addr_i];

endmodule
