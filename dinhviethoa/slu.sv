module slu( clk_i, 
			addr_i, 
			func3_i,
			st_data_i, 
			st_en_i, 
			io_sw_i, 
			ld_data_o, 
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
input wire [11:0] addr_i;
input wire [2:0] func3_i;
input wire [31:0] st_data_i;
input wire st_en_i;
input wire [31:0] io_sw_i;
output reg [31:0] ld_data_o;
output reg [31:0] io_lcd_o;
output reg [31:0] io_ledg_o;
output reg [31:0] io_ledr_o;
output reg [31:0] io_hex0_o;
output reg [31:0] io_hex1_o;
output reg [31:0] io_hex2_o;
output reg [31:0] io_hex3_o;
output reg [31:0] io_hex4_o;
output reg [31:0] io_hex5_o;
output reg [31:0] io_hex6_o;
output reg [31:0] io_hex7_o;
              
reg [31:0] arr_in_per; // in peripheral register				  
reg [31:0] arr_out_per [0:255]; // out peripheral array					
reg [31:0] arr_d [0:1023]; // data memory

reg [1:0] addr_sel;
wire [3:0] temp;
wire st_en_d;
reg [31:0] temp_2;
wire st_en_out_per;
reg [9:0] addr_d;
reg [7:0] addr_out;

wire [31:0] rdata_sw;
wire [31:0] rdata_per;
reg [31:0] rdata_d;

always @(*)
$writememh("./memory/datamem.data",arr_d);

/* ---------    comment here            ---*/
assign temp = addr_i[11:8];
always_latch
begin
	case(temp)
		4'h0,4'h1,4'h2,4'h3:
		begin
			addr_d = addr_i[9:0];
			addr_sel = 2'b01;
		end
		4'h4:
		begin
			addr_out = addr_i[7:0];
			addr_sel = 2'b10;
		end
		4'h5:
			addr_sel = 2'b11;
		default: 
			addr_sel = 2'b00;
	endcase
end

/* ---------    comment here            ---*/

assign st_en_d 			= (addr_sel == 2'b01) & st_en_i? 1 : 0;
assign st_en_out_per 	= (addr_sel == 2'b10) & st_en_i? 1 : 0;

/* ---------    comment here            ---*/
always @(posedge clk_i) 
begin
	arr_in_per[31:0] <= io_sw_i[31:0];
end

assign rdata_sw = arr_in_per;

/* ---------    comment here            ---*/
assign io_hex0_o = arr_out_per[8'h00];
assign io_hex1_o = arr_out_per[8'h10];
assign io_hex2_o = arr_out_per[8'h20];
assign io_hex3_o = arr_out_per[8'h30];
assign io_hex4_o = arr_out_per[8'h40];
assign io_hex5_o = arr_out_per[8'h50];
assign io_hex6_o = arr_out_per[8'h60];
assign io_hex7_o = arr_out_per[8'h70];

assign io_ledr_o = arr_out_per[8'h80];
assign io_ledg_o = arr_out_per[8'h90];
assign io_lcd_o  = arr_out_per[8'hA0]; 

/* ---------    comment here            ---*/
always @(posedge clk_i) 
begin
	if (st_en_out_per)
	begin
		arr_out_per[addr_out] <= st_data_i;
	end	
end

assign rdata_per = (st_en_out_per == 0)? arr_out_per[addr_out] : 32'd0;

/* ---------    comment here            ---*/
always @(*)
begin
	case(func3_i)
		3'b000:
			temp_2 = arr_d[addr_d] & 32'hfffffffc;
		3'b001:
			temp_2 = arr_d[addr_d] & 32'hffff0000;
		default:
			temp_2 = 32'd0;
	endcase
end

always @(posedge clk_i) 
begin
	if (st_en_d)
		arr_d[addr_d] <= temp_2 + st_data_i;
end

reg [31:0] temp_1;
assign temp_1 = arr_d[addr_d];
always_latch
begin
	if (!st_en_d)
		case(func3_i)
		3'b000:
				rdata_d = {{24{temp_1[7]}},temp_1[7:0]};
		3'b001:
				rdata_d = {{16{temp_1[15]}},temp_1[15:0]};
		3'b010:
				rdata_d = temp_1;
		3'b100:
				rdata_d = temp_1 & 32'd3;
		3'b101:
				rdata_d = temp_1 & 32'h0000ffff;
		default: ;
		endcase
	else
		rdata_d = 32'd0;
end
//assign rdata_d = (st_en_d == 0)? arr_d[addr_d] : 32'd0;

/* ---------    comment here            ---*/
always @(*)
begin
	if (~st_en_i)
	case (addr_sel)
		2'b01:
			ld_data_o = rdata_d;
		2'b10:
			ld_data_o = rdata_per;
		2'b11:
			ld_data_o = rdata_sw;
		default: 
			ld_data_o = 32'd0;
	endcase
	else
		ld_data_o = 32'd0;
end

endmodule  
