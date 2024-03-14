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

module ternary_min(a, b, out);
  input [1:0] a;
  input [1:0] b;
  output [1:0] out;

  and_gate and_gate1(a[1], b[1], out[1]);

  wire c, d, e;

  or_gate or_gate1(b[1], b[0], c);
  and_gate and_gate2(c, a[0], d);
  and_gate and_gate3(a[1], b[0], e);
  or_gate or_gate2( d, e, out[0]);
endmodule

module ternary_max(a, b, out);
  input [1:0] a;
  input [1:0] b;
  output [1:0] out;

  wire wire1, wire2;

  or_gate or_gate2(a[0], b[0], wire1);
  not_gate not_gate1(out[1], wire2);
  and_gate and_gate2(wire1, wire2, out[0]);

  or_gate or_gate1(a[1], b[1], out[1]);
endmodule

module ternary_consensus(a, b, out);
  input [1:0] a;
  input [1:0] b;
  output [1:0] out;

  wire wire1, wire2, wire3, wire4;

  and_gate and_gate1(a[1], b[1], out[1]);
  not_gate not_gate1(out[1], wire1 );

  or_gate or_gate1(a[1], a[0],  wire2);
  or_gate or_gate2(b[1], b[0], wire3);
  or_gate or_gate3(wire2, wire3, wire4);
  and_gate and_gate2(wire1, wire4, out[0]);
endmodule

module ternary_any(a, b, out);
  input [1:0] a;
  input [1:0] b;
  output [1:0] out;

  // for first bit

  wire sdnf1, sdnf2, sdnf3, sdnf4;
  not_gate not_gate1(a[1], sdnf1);
  not_gate not_gate2(a[0], sdnf2);
  not_gate not_gate3(b[1], sdnf3);
  not_gate not_gate4(b[0], sdnf4);

  wire sdnfres1, sdnfres2, SDNFpart1;

  and_gate and_gateSDNF10(sdnf1, a[0], sdnfres1);
  and_gate and_gateSDNF11(sdnfres1, b[1], sdnfres2);
  and_gate and_gateSDNF12(sdnfres2, sdnf4, SDNFpart1);

  wire sdnfress1, sdnfress2, SDNFpart2;

  and_gate and_gateSDNF13(a[1], sdnf2, sdnfress1);
  and_gate and_gateSDNF14(sdnfress1, sdnf3, sdnfress2);
  and_gate and_gateSDNF15(sdnfress2, b[0], SDNFpart2);

  wire sdnfresss1, sdnfresss2, SDNFpart3;

  and_gate and_gateSDNF16(a[1], sdnf2, sdnfresss1);
  and_gate and_gateSDNF17(sdnfresss1, b[1], sdnfresss2);
  and_gate and_gateSDNF18(sdnfresss2, sdnf4, SDNFpart3);

  wire sdnfresss3;

  or_gate or_gateSDNF10(SDNFpart1, SDNFpart2, sdnfresss3);
  or_gate or_gateSDNF11(sdnfresss3, SDNFpart3, out[1]);

  // for 2nd bit

  wire sdnfotv1, sdnfotv2, SDNFpart4;

  and_gate and_gateSDNF20(sdnf1, sdnf2, sdnfotv1);
  and_gate and_gateSDNF21(sdnfotv1, b[1], sdnfotv2);
  and_gate and_gateSDNF22(sdnfotv2, sdnf4, SDNFpart4);

  wire sdnfotv3, sdnfotv4, SDNFpart5;

  and_gate and_gateSDNF23(a[1], sdnf2, sdnfotv3);
  and_gate and_gateSDNF24(sdnfotv3, sdnf3, sdnfotv4);
  and_gate and_gateSDNF25(sdnfotv4, sdnf4, SDNFpart5);

  wire sdnfotv5, sdnfotv6, SDNFpart6;

  and_gate and_gateSDNF26(sdnf1, a[0], sdnfotv5);
  and_gate and_gateSDNF27(sdnfotv5, sdnf3, sdnfotv6);
  and_gate and_gateSDNF28(sdnfotv6, b[0], SDNFpart6);

  wire sdnf222; 

  or_gate or_gateSDNF13(SDNFpart4, SDNFpart5, sdnf222);
  or_gate or_gateSDNF14(sdnf222, SDNFpart6, out[0]);
  
endmodule

