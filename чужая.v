module not_one ( in, out);
input wire in;
output wire out;

supply1 pwr;
supply0 gnd;

pmos p(out, pwr, in); 
nmos n(out, gnd, in);  
endmodule

module or_one( in1, in2, out);
input wire in1, in2;
output wire out;

wire w1;
supply1 pwr;
supply0 gnd;

pmos p1(w1, gnd, in1);  
pmos p2(out, w1, in2);  
nmos n1(out, pwr, in1);
nmos n2(out, pwr, in2);
endmodule 

module nor_one( in1, in2, out);
input wire in1, in2;
output wire out;

wire w1;

or_one o1 (in1, in2, w1);
not_one no1 (w1, out);
endmodule

module and_one( in1, in2, out);
input wire in1, in2;
output wire out;

supply1 pwr;
supply0 gnd;
wire pwr_wire;

pmos p1(out, gnd, in1);
pmos p2(out, gnd, in2);
nmos n1(pwr_wire, pwr, in1); 
nmos n2(out, pwr_wire, in2); 
endmodule 

module nand_one( in1, in2, out);
input wire in1, in2; 
output wire out;

wire and_result;

and_one a1 (in1, in2, and_result);
not_one n1 (and_result, out);
endmodule

module xor_one( in1, in2, out);
input wire in1, in2; 
output wire out;

wire w1;
wire w2;

or_one o1(in1, in2, w2);
nand_one n1(in1, in2, w1);
and_one a1(w2, w1, out);
endmodule

module half_adder( a, b, sum, cout);
input wire a, b; 
output wire sum, cout;

xor_one x1(a, b, sum);
and_one a1(a, b, cout);
endmodule

module full_adder( a, b, cin, sum, cout);
input wire a, b, cin;
output wire sum, cout;

wire w1;
wire w2;
wire w3;

half_adder h1(a, b, w1, w2);
half_adder h2(w1, cin, sum, w3);
or_one o1(w2, w3, cout);
endmodule

module and4( in1, in2, out );
input wire [3:0] in1, in2;
output wire [3:0] out;

and_one a0(in1[0], in2[0], out[0]);
and_one a1(in1[1], in2[1], out[1]);
and_one a2(in1[2], in2[2], out[2]);
and_one a3(in1[3], in2[3], out[3]);
endmodule

module nand4( in1, in2, out );
input wire [3:0] in1, in2;
output wire [3:0] out;

nand_one n0(in1[0], in2[0], out[0]);
nand_one n1(in1[1], in2[1], out[1]);
nand_one n2(in1[2], in2[2], out[2]);
nand_one n3(in1[3], in2[3], out[3]);
endmodule

module or4( in1, in2, out );
input wire [3:0] in1, in2;
output wire [3:0] out; 

or_one o0(in1[0], in2[0], out[0]);
or_one o1(in1[1], in2[1], out[1]);
or_one o2(in1[2], in2[2], out[2]);
or_one o3(in1[3], in2[3], out[3]);
endmodule

module nor4( in1, in2, out );
input wire [3:0] in1, in2;
output wire [3:0] out; 

nor_one n0(in1[0], in2[0], out[0]);
nor_one n1(in1[1], in2[1], out[1]);
nor_one n2(in1[2], in2[2], out[2]);
nor_one n3(in1[3], in2[3], out[3]);
endmodule

module not4( in, out );
input wire [3:0] in;
output wire [3:0] out;

not_one n0(in[0], out[0]);
not_one n1(in[1], out[1]);
not_one n2(in[2], out[2]);
not_one n3(in[3], out[3]);
endmodule

module addition ( in1, in2, out );
input wire [3:0] in1, in2; 
output wire [3:0] out; 

wire w1;
wire w2;
wire w3;
wire w4;

full_adder f0(in1[0], in2[0], 1'b0, out[0], w1);
full_adder f1(in1[1], in2[1], w1, out[1], w2);
full_adder f2(in1[2], in2[2], w2, out[2], w3);
full_adder f3(in1[3], in2[3], w3, out[3], w4);
endmodule

module subtraction ( in1, in2, out );
input wire [3:0] in1, in2; 
output wire [3:0] out;

wire w1;
wire w2;
wire w3;
wire w4;
wire [3:0] in2_inv;
wire [3:0] w10;

not4 n1(in2, in2_inv);
full_adder f0(in1[0], in2_inv[0], 1'b0, w10[0], w1);
full_adder f1(in1[1], in2_inv[1], w1, w10[1], w2);
full_adder f2(in1[2], in2_inv[2], w2, w10[2], w3);
full_adder f3(in1[3], in2_inv[3], w3, w10[3], w4);
addition a1(w10, 4'b1, out);
endmodule

module slt ( in1, in2, out );
input wire [3:0] in1, in2; 
output wire [3:0] out;

wire [3:0] sub_res;
wire w1;
wire w2;
wire w2_inv;
wire w3;
wire w3_inv;
wire w4;
wire w4_inv;
wire w5;
wire w6;  

subtraction s1(in1, in2, sub_res);
and_one a1(1'b0, 1'b0, out[1]);
and_one a2(1'b0, 1'b0, out[2]);
and_one a3(1'b0, 1'b0, out[3]);
//
xor_one x1(1'b0, sub_res[3], w1);
xor_one x2(1'b1, in1[3], w2);
xor_one x3(1'b0, in2[3], w3);
and_one a4(w2, w3, w4); 
not_one n1(w4, w4_inv);
and_one a5(w1, w4_inv, w5);
not_one n2(w2, w2_inv); 
not_one n3(w3, w3_inv);
and_one a6(w2_inv, w3_inv, w6);
or_one o1(w5, w6, out[0]);
endmodule

module control_to_select ( control, out );
input wire [2:0] control;
output wire [3:0] out; 

wire w1;
wire w2;

and_one a1(control[0], control[1], w1);
and_one a2(w1, control[2], w2);
and_one a3 (1'b1, w2, out[0]);
and_one a4 (1'b1, w2, out[1]);
and_one a5 (1'b1, w2, out[2]);
and_one a6 (1'b1, w2, out[3]);
endmodule

module multiplex_8_1 (in1, in2, in3, in4, in5, in6, in7, in8, select, out);
input wire [3:0] in1, in2, in3, in4, in5, in6, in7, in8; 
input wire [2:0] select;
output wire [3:0] out;

wire [2:0] s0;
wire [2:0] s1;
wire [2:0] select_inv;
wire dummy1;
wire dummy2;
wire dummy3;
wire [3:0] select1;
wire [3:0] select2;
wire [3:0] select3;
wire [3:0] select4;
wire [3:0] select5;
wire [3:0] select6;
wire [3:0] select7;
wire [3:0] select8;
wire [3:0] out1;
wire [3:0] out2;
wire [3:0] out3;
wire [3:0] out4;
wire [3:0] out5;
wire [3:0] out6;
wire [3:0] out7;
wire [3:0] out8;
wire [3:0] w1;
wire [3:0] w2;
wire [3:0] w3;
wire [3:0] w4;
wire [3:0] w5;
wire [3:0] w6;

not4 n1({1'b1, select}, {dummy1, select_inv});
and4 a1({4'b1111}, {1'b1, select}, {dummy2, s1});
and4 a2({4'b1111}, {1'b1, select_inv}, {dummy3, s0});
control_to_select c1(s0, select1);
control_to_select c2({s0[2], s0[1], s1[0]}, select2);
control_to_select c3({s0[2], s1[1], s0[0]}, select3);
control_to_select c4({s0[2], s1[1], s1[0]}, select4);
control_to_select c5({s1[2], s0[1], s0[0]}, select5);
control_to_select c6({s1[2], s0[1], s1[0]}, select6);
control_to_select c7({s1[2], s1[1], s0[0]}, select7);
control_to_select c8(s1, select8);
and4 a10(select1, in1, out1);
and4 a11(select2, in2, out2);
and4 a12(select3, in3, out3);
and4 a13(select4, in4, out4);
and4 a14(select5, in5, out5);
and4 a15(select6, in6, out6);
and4 a16(select7, in7, out7);
and4 a17(select8, in8, out8);
or4 o1(out1, out2, w1);
or4 o2(w1, out3, w2);
or4 o3(w2, out4, w3);
or4 o4(w3, out5, w4);
or4 o5(w4, out6, w5);
or4 o6(w5, out7, w6);
or4 o7(w6, out8, out);
endmodule

module alu(a, b, control, res);
  input wire signed[3:0] a, b; // Операнды
  input wire [2:0] control; // Управляющие сигналы для выбора операции

  output [3:0] res; // Результат
  // TODO: implementation

  wire [3:0] and_result;
  wire [3:0] nand_result;
  wire [3:0] or_result;
  wire [3:0] nor_result;
  wire [3:0] add_result;
  wire [3:0] sub_result;
  wire [3:0] slt_result;

  and4 a1(a, b, and_result);
  nand4 n(a, b, nand_result);
  or4 o1(a, b, or_result);
  nor4 n2(a, b, nor_result);
  addition a2(a, b, add_result);
  subtraction s1(a, b, sub_result);
  slt s2(a, b, slt_result);

  multiplex_8_1 m1(and_result, nand_result, or_result, nor_result, add_result, sub_result, slt_result, 4'b0000, control, res);
endmodule

module d_latch(clk, d, we, q);
  input clk; // Сигнал синхронизации
  input d; // Бит для записи в ячейку
  input we; // Необходимо ли перезаписать содержимое ячейки

  output reg q; // Сама ячейка
  // Изначально в ячейке хранится 0
  initial begin
    q <= 0;
  end
  // Значение изменяется на переданное на спаде сигнала синхронизации
  always @ (negedge clk) begin
    // Запись происходит при we = 1
    if (we) begin
      q <= d;
    end
  end
endmodule

module register_file(clk, rd_addr, we_addr, we_data, rd_data, we);
  input clk; // Сигнал синхронизации
  input [1:0] rd_addr, we_addr; // Номера регистров для чтения и записи
  input [3:0] we_data; // Данные для записи в регистровый файл
  input we; // Необходимо ли перезаписать содержимое регистра

  output [3:0] rd_data; // Данные, полученные в результате чтения из регистрового файла
  // TODO: implementation

  wire  [3:0] registers [0:3];

  d_latch d1(clk, we_data[0], we && !we_addr[0] && !we_addr[1], registers[0][0]);
  d_latch d2(clk, we_data[1], we && !we_addr[0] && !we_addr[1], registers[0][1]);
  d_latch d3(clk, we_data[2], we && !we_addr[0] && !we_addr[1], registers[0][2]);
  d_latch d4(clk, we_data[3], we && !we_addr[0] && !we_addr[1], registers[0][3]);
  d_latch d5(clk, we_data[0], we && we_addr[0] && !we_addr[1], registers[1][0]);
  d_latch d6(clk, we_data[1], we && we_addr[0] && !we_addr[1], registers[1][1]);
  d_latch d7(clk, we_data[2], we && we_addr[0] && !we_addr[1], registers[1][2]);
  d_latch d8(clk, we_data[3], we && we_addr[0] && !we_addr[1], registers[1][3]);
  d_latch d9(clk, we_data[0], we && !we_addr[0] && we_addr[1], registers[2][0]);
  d_latch d10(clk, we_data[1], we && !we_addr[0] && we_addr[1], registers[2][1]);
  d_latch d11(clk, we_data[2], we && !we_addr[0] && we_addr[1], registers[2][2]);
  d_latch d12(clk, we_data[3], we && !we_addr[0] && we_addr[1], registers[2][3]);
  d_latch d13(clk, we_data[0], we && we_addr[0] && we_addr[1], registers[3][0]);
  d_latch d14(clk, we_data[1], we && we_addr[0] && we_addr[1], registers[3][1]);
  d_latch d15(clk, we_data[2], we && we_addr[0] && we_addr[1], registers[3][2]);
  d_latch d16(clk, we_data[3], we && we_addr[0] && we_addr[1], registers[3][3]);
  multiplex_8_1 m1(registers[0], registers[1], registers[2], registers[3], registers[0], registers[1], registers[2], registers[3], {1'b0, rd_addr}, rd_data);
endmodule

module counter(clk, addr, control, immediate, data);
  input clk; // Сигнал синхронизации
  input [1:0] addr; // Номер значения счетчика которое читается или изменяется
  input [3:0] immediate; // Целочисленная константа, на которую увеличивается/уменьшается значение счетчика
  input control; // 0 - операция инкремента, 1 - операция декремента

  output [3:0] data; // Данные из значения под номером addr, подающиеся на выход
  // TODO: implementation

  wire [3:0] w1;
  wire w2;

  and_one a3(1'b1, control, w2);
  alu a(data, immediate, {2'b10, w2}, w1);
  register_file rf(clk, addr, addr, w1, data, 1'b1);
endmodule

