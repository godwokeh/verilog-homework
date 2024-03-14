module not_gate(a, out);

input a;
output out;

supply1 pwr;
supply0 gnd;

pmos pmos1(out, pwr, a);
nmos nmos1(out, gnd, a);
endmodule

module nand_gate(a, b, out);
  input a, b;
  output out;

  pmos pmos1(out, pwr, a);
  pmos pmos2(out, pwr, b);

  wire nmos1_out;

  nmos nmos1(nmos1_out, gnd, b);
  nmos nmos2(out, nmos1_out, a);
  
  supply1 pwr;
  supply0 gnd;
endmodule

module and_gate(a, b, out);
  input wire a, b;
  output wire out;
  
  wire nand_out;

  nand_gate nand_gate1(a, b, nand_out);
  not_gate not_gate1(nand_out, out);
endmodule

module nor_gate(a, b, out);
  input a, b;
  output out;

  supply0 gnd;
  supply1 pwr;

  wire pmos1_out;

  pmos pmos1(pmos1_out, pwr, a);
  pmos pmos2(out, pmos1_out, b);
  nmos nmos1(out, gnd, a);
  nmos nmos2(out, gnd, b);
endmodule

module or_gate(a, b, out);
  input a, b;
  output out;

  wire nor_out;

  nor_gate nor_gate1(a, b, nor_out);
  not_gate not_gate1(nor_out, out);
endmodule

module xor_gate(a, b, out);
    input a, b;
    output out;
    wire w1, w2, w3, w4;
    not_gate n1(a, w1);
    not_gate n2(b, w2);
    and_gate a1(a, w2, w3);
    and_gate a2(w1, b, w4);
    or_gate o1(w3, w4, out);
endmodule

module full_adder(a, b, cin, sum, cout);
  input a, b, cin;
  output sum, cout;
  wire w1, w2, w3;
  xor_gate xor_ab(a, b, w1);
  xor_gate xor_abcin(w1, cin, sum);
  and_gate and_ab(a, b, w2);
  and_gate and_xorabcin(cin, w1, w3);
  or_gate or_final(w2, w3, cout);
endmodule

module full_adder_4bit(input [3:0] a, b, input cin, output [3:0] sum, output cout);
  wire c1, c2, c3;
  full_adder fa0(a[0], b[0], cin, sum[0], c1);
  full_adder fa1(a[1], b[1], c1, sum[1], c2);
  full_adder fa2(a[2], b[2], c2, sum[2], c3);
  full_adder fa3(a[3], b[3], c3, sum[3], cout);
endmodule

module full_subtractor_4bit(input [3:0] a, b, output [3:0] sum, output cout);
  wire c1, c2, c3;
  wire [3:0] not_b;
  not_gate notb1(b[0], not_b[0]);
  not_gate notb2(b[1], not_b[1]);
  not_gate notb3(b[2], not_b[2]);
  not_gate notb4(b[3], not_b[3]);
  full_adder fa4(a[0], not_b[0], 1'b1, sum[0], c1);
  full_adder fa5(a[1], not_b[1], c1, sum[1], c2);
  full_adder fa6(a[2], not_b[2], c2, sum[2], c3);
  full_adder fa7(a[3], not_b[3], c3, sum[3], cout);
endmodule

module and_4bit(input [3:0] a, b, output [3:0] res);
  and_gate and1(a[0], b[0], res[0]);
  and_gate and2(a[1], b[1], res[1]);
  and_gate and3(a[2], b[2], res[2]);
  and_gate and4(a[3], b[3], res[3]);
endmodule

module nand_4bit(input [3:0] a, b, output [3:0] res);
  wire [3:0] r1;
  and_4bit and4bit(a, b, r1);
  not_gate not22(r1[0], res[0]);
  not_gate not33(r1[1], res[1]);
  not_gate not44(r1[2], res[2]);
  not_gate not55(r1[3], res[3]);
endmodule

module and_3bit(input a, b, c, output res);
  wire connect;
  and_gate and3bit(a, b, connect);
  and_gate and3bit2(connect, c, res);
endmodule

module or_4bit(input [3:0] a, b, output [3:0] res);
  or_gate or_gate1(a[0], b[0], res[0]);
  or_gate or_gate2(a[1], b[1], res[1]);
  or_gate or_gate3(a[2], b[2], res[2]);
  or_gate or_gate4(a[3], b[3], res[3]);
endmodule

module nor_4bit(input [3:0] a, b, output [3:0] res);
  wire [3:0] r2;
  or_4bit or4bit(a, b, r2);
  not_gate not23(r2[0], res[0]);
  not_gate not34(r2[1], res[1]);
  not_gate not45(r2[2], res[2]);
  not_gate not46(r2[3], res[3]);
endmodule

module slt_4bit(input [3:0] a, b, output [3:0] res);
  and_gate zerogen(1'b0, 1'b0, res[3]);
  and_gate zerogen1(1'b0, 1'b0, res[2]);
  and_gate zerogen2(1'b0, 1'b0, res[1]);
  wire [3:0] subtract;
  wire cout1;
  full_subtractor_4bit fs1(a, b, subtract, cout);
  wire wr1, wr2, wr3, wr4, wr5, wr6, not_wr2, not_wr3, not_wr4;
  xor_gate xor1(1'b0, subtract[3], wr1);
  xor_gate xor2(1'b1, a[3], wr2);
  xor_gate xor3(1'b0, b[3], wr3);
  and_gate and1(wr2, wr3, wr4);
  not_gate not1(wr4, not_wr4);
  and_gate and2(not_wr4, wr1, wr5);
  not_gate not2(wr2, not_wr2);
  not_gate not3(wr3, not_wr3);
  and_gate and3(not_wr2, not_wr3, wr6);
  or_gate or1(wr6, wr5, res[0]);
endmodule


module multiplexor(input d0, d1, d2, d3, d4, d5, d6, d7, input [2:0] control, output result);
  wire notA, notB, notC;
  not_gate not_gate1(control[2], notA);
  not_gate not_gate2(control[1], notB);
  not_gate not_gate3(control[0], notC);
  // 000 a & b
  // ~A ~B ~C
  wire nAnBnC;
  and_3bit and3bit1(notA, notB, notC, nAnBnC);
  wire r0;
  and_gate and_gate1(nAnBnC, d0, r0);
  // 001 !(a & b)	
  // ~A ~B C
  wire nAnBC;
  and_3bit and3bit2(notA, notB, control[0], nAnBC);
  wire r1;
  and_gate and_gate2(nAnBC, d1, r1);
  // 010 a | b
  // ~A B ~C
  wire nABnC;
  and_3bit and3bit3(notA, control[1], notC, nABnC);
  wire r2;
  and_gate and_gate3(nABnC, d2, r2); 
  // 011 !(a | b)	
  // ~A B C
 wire nABC;
  and_3bit and3bit4(notA, control[1], control[0], nABC);
  wire r3;
  and_gate and_gate4(nABC, d3, r3); 
  // 100 a + b
  // A ~B ~C
 wire AnBnC;
  and_3bit and3bit5(control[2], notB, notC, AnBnC);
  wire r4;
  and_gate and_gate5(AnBnC, d4, r4); 
  // 101 a - b	
  // A ~B C
 wire AnBC;
  and_3bit and3bit6(control[2], notB, control[0], AnBC);
  wire r5;
  and_gate and_gate6(AnBC, d5, r5); 
  // 110 slt
  // A B ~C
 wire ABnC;
  and_3bit and3bit7(control[2], control[1], notC, ABnC);
  wire r6;
  and_gate and_gate7(ABnC, d6, r6); 
  // 111 unused 
  // A B C

  // di to result
  wire a1, a2, a3, a4, a5;
  or_gate or_gate1(r0, r1, a1);
  or_gate or_gate2(a1, r2, a2);
  or_gate or_gate3(a2, r3, a3);
  or_gate or_gate4(a3, r4, a4);
  or_gate or_gate5(a4, r5, a5);
  or_gate or_gate6(a5, r6, result);
endmodule

module multiplexor_4bit(data1, data2, data3, data4, data5, data6, data7, data8, control, res);
  input [3:0] data1, data2, data3, data4, data5, data6, data7, data8;
  input [2:0] control;
  output [3:0] res;
  wire r1, r2, r3, r4;
  multiplexor multiplexor1(data1[0], data2[0], data3[0], data4[0], data5[0], data6[0], data7[0], data8[0], control, res[0]);
  multiplexor multiplexor2(data1[1], data2[1], data3[1], data4[1], data5[1], data6[1], data7[1], data8[1], control, res[1]);
  multiplexor multiplexor3(data1[2], data2[2], data3[2], data4[2], data5[2], data6[2], data7[2], data8[2], control, res[2]);
  multiplexor multiplexor4(data1[3], data2[3], data3[3], data4[3], data5[3], data6[3], data7[3], data8[3], control, res[3]);
endmodule;


module alu(a, b, control, res);
  input [3:0] a, b; // Операнды
  input [2:0] control; // Управляющие сигналы для выбора операции
  wire [3:0] r0, r1, r2, r3, r4, r5, r6, r7;
  output [3:0] res; // Результат
  // 000 a & b
  and_4bit and1(a, b, r0);
  // 001 !(a & b)	
  nand_4bit nand2(a, b, r1);
  // 010 a | b
  or_4bit or1(a, b, r2);
  // 011 !(a | b)	
  nor_4bit nor2(a, b, r3);
  // 100 a + b	
  wire cout4;
  full_adder_4bit fa10(a, b, 1'b0, r4, cout4);
  // 101 a - b
  wire cout5;
  full_subtractor_4bit fs10(a, b, r5, cout5);	
  // 110 slt
  slt_4bit slt1(a, b, r6);
  // 111 unused 
  not_gate nt1(pwr, r7[0]);
  not_gate nt2(pwr, r7[1]);
  not_gate nt3(pwr, r7[2]);
  not_gate nt4(pwr, r7[3]);
  multiplexor_4bit multiplexor2(r0, r1, r2, r3, r4, r5, r6, r7, control, res);
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
endmodule

module counter(clk, addr, control, immediate, data);
  input clk; // Сигнал синхронизации
  input [1:0] addr; // Номер значения счетчика которое читается или изменяется
  input [3:0] immediate; // Целочисленная константа, на которую увеличивается/уменьшается значение счетчика
  input control; // 0 - операция инкремента, 1 - операция декремента

  output [3:0] data; // Данные из значения под номером addr, подающиеся на выход
  // TODO: implementation
endmodule
