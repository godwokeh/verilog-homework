`include "util.v"

module mips_cpu(clk, pc, pc_new, instruction_memory_a, instruction_memory_rd, data_memory_a, data_memory_rd, data_memory_we, data_memory_wd,
                register_a1, register_a2, register_a3, register_we3, register_wd3, register_rd1, register_rd2);
  // сигнал синхронизации
  input clk;
  // текущее значение регистра PC
  inout [31:0] pc;
  // новое значение регистра PC (адрес следующей команды)
  output [31:0] pc_new;
  // we для памяти данных
  output data_memory_we;
  // адреса памяти и данные для записи памяти данных
  output [31:0] instruction_memory_a, data_memory_a, data_memory_wd;
  // данные, полученные в результате чтения из памяти
  inout [31:0] instruction_memory_rd, data_memory_rd;
  // we3 для регистрового файла
  output register_we3;
  // номера регистров
  output [4:0] register_a1, register_a2, register_a3;
  // данные для записи в регистровый файл
  output [31:0] register_wd3;
  // данные, полученные в результате чтения из регистрового файла
  inout [31:0] register_rd1, register_rd2;

  // TODO: implementation

  initial begin
    reset = 1;
    repeat (2)
      @ (negedge clk); 
    reset = 0;
  end

  reg reset;
  wire MemToReg, MemWrite, Branch, ALUSrc, RegDst, RegWrite;
  wire [2:0] ALUControl;
  wire [31:0] PC, PC_new;
  assign instruction_memory_a = PC;
  assign pc = PC;
  // next instruction address
  nextInstructionAddress nextInstructionAdress1(pc, PC_new);
  // next instruction in PC
  nextInstruction nextInstruction1(clk, reset, PC_new, PC);
  // control unit
  control_unit cu(instruction_memory_rd, MemToReg, MemWrite, Branch, ALUControl, ALUSrc, RegDst, RegWrite);
  // адрес следующей инструкции
  assign instruction_memory_a = PC; 
  // второй операнд АЛУ
  wire [31:0] SrcB;
  chooseSrcB choose1(register_rd2, instruction_memory_rd, ALUSrc, SrcB);
  // номера регистров
  chooseA3 choose2(instruction_memory_rd, RegDst, register_a3);
  assign register_a1 = instruction_memory_rd[25:21];
  assign register_a2 = instruction_memory_rd[20:16];
  // флаг записи для регистрового и обычного файла
  assign register_we3 = RegWrite;
  assign data_memory_we = MemWrite;
  // ALU calculate
  wire [31:0] alu_result;
  alu alu(register_rd1, SrcB, ALUControl, alu_result);
  assign data_memory_a = alu_result;
  // данные для записи в регистровый файл
  chooseResult choose3(data_memory_rd, alu_result, MemToReg, register_wd3);
  // данные для записи в память
  assign data_memory_wd = register_rd2;
endmodule


module nextInstruction(
          input clk, 
          input reset,	
				  input [31:0] pc_next,
					output reg [31:0] pc
          );
always @(posedge clk)
	pc = reset ? 0 : pc_next;
       
endmodule

module nextInstructionAddress(
    input [31:0] pc,
    output reg [31:0] pc_new
);

    always @* begin
        pc_new = pc + 4;
    end

endmodule

module control_unit(input [31:0] instruction, 
                    output reg MemToReg, 
                    output reg MemWrite,
                    output reg Branch,
                    output [2:0] ALUControl, 
                    output reg AluSRC, 
                    output reg RegDst, 
                    output reg RegWrite);
wire [5:0] opcode;
assign opcode = instruction[31:26];
reg [5:0] funct;
reg [1:0] aluOP;
always @(*) begin
    case (opcode)
        6'b000000: // r-type
            funct = instruction[5:0];
        6'b100011, // lw
        6'b101011, // sw
        6'b000100: // beq
            funct = 6'bxxxxxx;
    endcase
end

always @(*) begin
    case (opcode)
        6'b000000: // r-type
            begin
                aluOP = 2'b10;
                RegWrite = 1;
                RegDst = 1;
                AluSRC = 0;
                Branch = 0;
                MemWrite = 0;
                MemToReg = 0;
            end
        6'b100011: // lw
            begin
                aluOP = 2'b00; 
                RegWrite = 1;
                RegDst = 0;
                AluSRC = 1;
                Branch = 0;
                MemWrite = 0;
                MemToReg = 1;
            end
        6'b101011: // sw
            begin
                aluOP = 2'b00; 
                RegWrite = 0;
                RegDst = 1'bx;
                AluSRC = 1;
                Branch = 0;
                MemWrite = 1;
                MemToReg = 1'bx;

            end
        6'b000100: // beq
            begin 
                aluOP = 2'b01;
                RegWrite = 0;
                RegDst = 1'bx;
                AluSRC = 0;
                Branch = 1;
                MemWrite = 0;
                MemToReg = 1'bx;
            end
        6'b001000: // addi
            begin
                aluOP = 2'b00;
                RegWrite = 1;
                RegDst = 0;
                AluSRC = 1;
                Branch = 0;
                MemWrite = 0;
                MemToReg = 0;
            end
    endcase
end
  ALUdecoder aludecoder1(funct, aluOP, ALUControl);
endmodule

module ALUdecoder(input [5:0] funct, input [1:0] ALUop, output reg [2:0] ALUControl);
always @(*)
begin
  case (ALUop)
    2'b10:
      begin
        case (funct)
          6'b100000:
            ALUControl = 3'b010; // add
          6'b100010:
            ALUControl = 3'b110; // sub
          6'b100100:
            ALUControl = 3'b000; // and
          6'b100101:
            ALUControl = 3'b001; // or
          6'b101010:
            ALUControl = 3'b111; // slt
        endcase
      end 
    2'b00:
      begin
        ALUControl = 3'b010; // add
      end
    2'b01:
      begin
        ALUControl = 3'b110; // sub
      end
  endcase
end
endmodule

module alu(input [31:0] SrcA, input [31:0] SrcB, input [2:0] ALUControl, output reg [31:0] result);
always @(*)
begin
	case (ALUControl)
		3'b010: result = SrcA + SrcB;
    3'b110: result = SrcA - SrcB;
    3'b000: result = SrcA & SrcB;
    3'b001: result = SrcA | SrcB;
    3'b111: result = ($signed(SrcA) < $signed(SrcB)) ? 32'b1 : 32'b0;
	endcase
end
endmodule

module chooseSrcB(
    input [31:0] rd2,
    input [31:0] instruction,
    input ALUSrc,
    output reg [31:0] srcB
);
    wire [31:0] srcBwr;
    sign_extend se(instruction[15:0], srcBwr);
    always @(*) begin
        if (ALUSrc == 1) begin
            srcB = srcBwr;
        end else begin
            srcB = rd2;
        end
    end
endmodule

module chooseA3(
    input [31:0] instruction,
    input RegDst,
    output reg [4:0] WriteReg
);
    always @(*) begin
        if (RegDst == 1) begin
            WriteReg = instruction[15:11];
        end else begin
            WriteReg = instruction[20:16];
        end
    end
endmodule

module chooseResult(
    input [31:0] rd_data, 
    input [31:0] alu_result,
    input MemToReg,
    output reg [31:0] result
);
    always @(*) begin
        if (MemToReg == 1) begin
            result = rd_data;
        end else begin
            result = alu_result;
        end
    end
endmodule
