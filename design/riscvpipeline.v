module PIPELINED(
    input clk,
    input start
);
wire branch;
wire memRead;
wire memtoReg;
wire [1:0] ALUOp;
wire memWrite;
wire ALUSrc;
wire regWrite;
wire [4:0] readReg1;
wire [4:0] readReg2;
wire [4:0] writeReg;
wire [31:0] writeData;
wire [31:0] readData1;
wire [31:0] readData2;
wire [31:0] pc_final;
wire [31:0] imm_reg_val;
wire zero;
wire [4:0] ALUCtl;
wire [31:0] imm;
wire [31:0] ALUOut;
wire [31:0] address;
wire [31:0] imm_sum;
wire [31:0] imm_s;
wire [31:0] inst;
wire [31:0] pc_i;
wire [31:0] pc_o;
wire [31:0] pc_new;
//wire funct7;
//wire [2:0] funct3;
wire [31:0] readData;

// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: connect wire to realize SingleCycleCPU
// The following provides simple template,


 //FETCH

    InstructionMemory m_InstMem(
    .readAddr(pc_o),
    .inst(inst)
    );
    //
    Mux2to1 #(.size(32)) m_Mux_PC(
        .sel(branch_regde & zero),
        .s0(pc_new),
        .s1(imm_sum),
        .out(pc_final)
    
    );
    //
    PC m_PC(
        .clk(clk),
        .rst(start),
        .stall(stall),
        .pc_i(pc_final),
        .pc_o(pc_o)
    );

    Adder m_Adder_1(
        .a(pc_o),
        .b(4),
        .sum(pc_new)
    );

wire [31:0] inst_regfd;
wire [31:0] pc_o_regfd;

reg1 m_reg1(
    .clk(clk),
    .rst(start),
    .stall(stall),
    .inst(inst),
    .pc_o(pc_o),
    .branch_regde(branch_regde),
    .zero(zero),
    .inst_regfd(inst_regfd),
    .pc_o_regfd(pc_o_regfd)
);

wire [2:0] funct3_control;
wire funct7_control;


 //DECODE
    Control m_Control(
        .opcode(inst_regfd[6:0]),
        .funt7(inst_regfd[30]),
        .funt3(inst_regfd[14:12]),
        .branch(branch),
        .memRead(memRead),
        .memtoReg(memtoReg),
        .ALUOp(ALUOp),
        .memWrite(memWrite),
        .ALUSrc(ALUSrc),
        .regWrite(regWrite),
        .funct3(funct3_control),
        .funct7(funct7_control)
    );
//
    ImmGen #(.Width(32)) m_ImmGen(
        .inst(inst_regfd),
        .imm(imm)
    );
//
    Register m_Register(
        .clk(clk),
        .rst(start),
        .regWrite(regWrite_regwb),
        .readReg1(inst_regfd[19:15]),
        .readReg2(inst_regfd[24:20]),
        .writeReg(write_to_Reg_regwb),
        .writeData(writeData_regwb),
        .readData1(readData1),
        .readData2(readData2)
    );

    Hazard m_Hazard(
        .readReg1_fd(inst_regfd[19:15]),
        .readReg2_fd(inst_regfd[24:20]),
        .write_to_Reg_regde(write_to_Reg_regde),
        .memRead_regde(memRead_regde),
        .flush(flush),
        .stall(stall)
    );
//
    wire branch_regde;
    wire memRead_regde;
    wire memtoReg_regde;
    wire memWrite_regde;
    wire ALUSrc_regde;
    wire regWrite_regde;
    wire [1:0] ALUOp_regde;
    wire [4:0] writeReg_regde;
    wire [31:0] pc_o_regde;
    wire [31:0] readData1_regde;
    wire [31:0] readData2_regde;
    wire [31:0] imm_regde;
    wire [31:0] inst_regde;
    wire [4:0] readReg1_regde;
    wire [4:0] readReg2_regde;
    wire [1:0] forwardA;
    wire [1:0] forwardB;
    //
reg2 m_reg2(
    .clk(clk),
    .rst(start),
    .branch(branch),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .memWrite(memWrite),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite),
    .writeReg(inst_regfd[11:7]),
    .funct7(funct7_control),
    .funct3(funct3_control),
    .ALUOp(ALUOp),
    .pc_o_regfd(pc_o_regfd),
    .readData1(readData1),
    .readData2(readData2),
    .imm(imm),
    .inst_regfd(inst_regfd),
    .flush(flush),
    .branch_taken(branch_taken),
    .readReg1(inst_regfd[19:15]),
    .readReg2(inst_regfd[24:20]),
    
    .branch_regde(branch_regde),
    .memRead_regde(memRead_regde),
    .memtoReg_regde(memtoReg_regde),
    .memWrite_regde(memWrite_regde),
    .ALUSrc_regde(ALUSrc_regde),
    .regWrite_regde(regWrite_regde),
    .ALUOp_regde(ALUOp_regde),
    .write_to_Reg_regde(write_to_Reg_regde),
    .pc_o_regde(pc_o_regde),
    .readData1_regde(readData1_regde),
    .readData2_regde(readData2_regde),
    .imm_regde(imm_regde),
    .inst_regde(inst_regde),
    .funct7_regde(funct7_regde),
    .funct3_regde(funct3_regde),
    .readReg1_regde(readReg1_regde),
    .readReg2_regde(readReg2_regde)
);

wire funct7_regde;
wire [14:12] funct3_regde;
wire [31:0] readData1_final;
wire [31:0] readData2_final;
wire branch_taken;
assign branch_taken = branch_regde & zero;

// forwarding unit
Forward m_Forward(
    .readReg1_regde(readReg1_regde),
    .readReg2_regde(readReg2_regde),
    .write_to_Reg_regem(write_to_Reg_regem),
    .write_to_Reg_regwb(write_to_Reg_regwb),
    .regWrite_regwb(regWrite_regwb),
    .regWrite_regem(regWrite_regem),
    .forwardA(forwardA),
    .forwardB(forwardB)
);

//EXCECUTE
    ShiftLeftOne m_ShiftLeftOne(
    .i(imm_regde),
    .o(imm_s)
    );
//
    Adder m_Adder_2(
    .a(pc_o_regde),
    .b(imm_s),
    .sum(imm_sum)
    );

    Mux4to1 #(.size(32)) m_Mux_ALU_A(
    .sel(forwardA),
    .s0(readData1_regde),
    .s1(writeData_regwb),
    .s2(ALUOut_regem),
    .out(readData1_final)
    );

    Mux4to1 #(.size(32)) m_Mux_ALU_B(
    .sel(forwardB),
    .s0(readData2_regde),
    .s1(writeData_regwb),
    .s2(ALUOut_regem),
    .out(readData2_final)
    );




//
    Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUSrc_regde),
    .s0(readData2_final),
    .s1(imm_regde),
    .out(imm_reg_val)
    );
//



    ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp_regde),
    //.functi(inst_regde)
    .funct7_c(funct7_regde),
    .funct3_c(funct3_regde),
    .ALUCtl(ALUCtl)
    );
//
    ALU m_ALU(
    .ALUCtl(ALUCtl),
    .A(readData1_final),
    .B(imm_reg_val),
    .ALUOut(ALUOut),
    .zero(zero),
    .branch_zero(branch_zero)
    );

//
wire [4:0] write_to_Reg_regde;
wire memtoReg_regem;
wire regWrite_regem;
wire branch_regem;
wire memRead_regem;
wire memWrite_regem;
wire [31:0] imm_sum_regem;
wire zero_regem;
wire [31:0] ALUOut_regem;
wire [31:0] readData1_regem;
wire [31:0] readData2_regem;
wire [4:0] write_to_Reg_regem;
//
reg3 m_reg3(
    .clk(clk),
    .rst(start),
    .memtoReg_regde(memtoReg_regde),
    .regWrite_regde(regWrite_regde),
    .branch_regde(branch_regde),
    .memRead_regde(memRead_regde),
    .memWrite_regde(memWrite_regde),
    .imm_sum(imm_sum),
    .zero(zero),
    .ALUOut(ALUOut),
    .readData2_regde(readData2_regde),
    .write_to_Reg_regde(write_to_Reg_regde),

    .memtoReg_regem(memtoReg_regem),
    .regWrite_regem(regWrite_regem),
    .branch_regem(branch_regem),
    .memRead_regem(memRead_regem),
    .memWrite_regem(memWrite_regem),
    .imm_sum_regem(imm_sum_regem),
    .zero_regem(zero_regem),
    .ALUOut_regem(ALUOut_regem),
    .readData2_regem(readData2_regem),
    .write_to_Reg_regem(write_to_Reg_regem)
);

//MEMORY
    DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite_regem),
    .memRead(memRead_regem),
    .address(ALUOut_regem),
    .writeData(readData2_regem),
    .readData(readData)
    );
//
wire memtoReg_regwb;
wire regWrite_regwb;
wire [31:0] readData_regwb;
wire [31:0] ALUOut_regwb;
wire [31:0] readData_regem;
wire [4:0] write_to_Reg_regwb;
wire [31:0] writeData_regwb;

//
reg4 m_reg4(
    .clk(clk),
    .rst(start),
    .memtoReg_regem(memtoReg_regem),
    .regWrite_regem(regWrite_regem),
    .readData(readData),
    .ALUOut_regem(ALUOut_regem),
    .write_to_Reg_regem(write_to_Reg_regem),
    .memtoReg_regwb(memtoReg_regwb),
    .regWrite_regwb(regWrite_regwb),
    .readData_regwb(readData_regwb),
    .ALUOut_regwb(ALUOut_regwb),
    .write_to_Reg_regwb(write_to_Reg_regwb)
);

//WRITEBACK
    Mux2to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg_regwb),
    .s0(ALUOut_regwb),
    .s1(readData_regwb),
    .out(writeData_regwb)
    );

endmodule
