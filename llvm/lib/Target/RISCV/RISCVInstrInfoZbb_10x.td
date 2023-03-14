let Predicates = [HasZbb_10x] in {
def ANDN_10x : Instruction {
bits<32> Inst;
bits<32> SoftFail = 0;
bits<5> rs2;
bits<5> rs1;
bits<5> rd;
let Namespace = "RISCV";
let Size = 4;
let hasSideEffects = 0;
let mayLoad = 0;
let mayStore = 0;
let Inst{31-25} = 0b0100000; /*funct7*/  // Avoiding Encoding Conflict 
let Inst{24-20} = rs2;
let Inst{19-15} = rs1;
let Inst{14-12} = 0b111; /*funct3*/
let Inst{11-7} = rd;
let Inst{6-0} = 0b0110011; /*opcode*/
dag OutOperandList = (outs GPR:$rd);
dag InOperandList = (ins GPR:$rs1, GPR:$rs2);
let AsmString = "andn_10x\t$rd, $rs1, $rs2";
}

def : Pat<(and GPR:$rs1, (not GPR:$rs2)), (ANDN_10x GPR:$rs1, GPR:$rs2)>;

}