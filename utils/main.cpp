#include "Operand.hpp"
#include "Instruction.hpp"
#include "BasicBlock.hpp"
#include "ControlFlowGraph.hpp"
#include "SymbolTable.hpp"

#include <iostream>
using std::cout; using std::endl;

void testBasicBlock() {

}

int main() {
    //Create basic blocks
    BasicBlock* beginBlock = new BasicBlock(0);
    BasicBlock* currentBlock = new BasicBlock(1);
    BasicBlock* currentBlock2 = new BasicBlock(2);
    BasicBlock* currentBlock3 = new BasicBlock(3);

    //Create necessary operands (dest, src1, src2)
    Operand* src1 = new Operand(Operand::REGISTER, 0);
    Operand* src2 = new Operand(Operand::REGISTER, 1);
    Operand *dest = new Operand(Operand::REGISTER, 2);

    //Generate instructions using operands and push into basic block
    Instruction inst(Instruction::ADD, *dest, *src1, *src2);
    currentBlock->pushBackInstruction(inst);

    Instruction inst1(Instruction::SUB, *dest, *src1, *src2);
    currentBlock->pushBackInstruction(inst1);

    Instruction inst2(Instruction::MUL, *dest, *src1, *src2);
    currentBlock->pushBackInstruction(inst2);


    //Create a graph using the main basic block
    Graph* CFG = new Graph(*beginBlock);

    //flag = 1 indicates that we need to create a node for the currentBlock
    CFG->addEdge(CFG->lastAddedBlockID, *currentBlock);

    CFG->dumpGraph();
    


    //-------------------Test symbol Table-------------
    SymbolTable symbolTable;

    string var_name("a");
    int assignedReg = 0;

    //check operand type
    if (dest->getOperandType() == Operand::CONST || dest->getOperandType() == Operand::MEM_ADDRESS) {
        assignedReg++;

        //emit a LD instruction
        Instruction inst(Instruction::LOAD, Operand(Operand::REGISTER, assignedReg), *dest);
    
        //push back to current block
        currentBlock->pushBackInstruction(inst);
    }
    else {
        assignedReg = dest->getOperandValue();
    }

    //create an entry in symbol table
    if (!symbolTable.insertNewVariable(var_name, (Type::INT), assignedReg)) {
        cout << "Lado Vayo nita!!";
    }



    cout << "\n \n ... Symbol Table ... \n \n" << symbolTable.dumpSymbolTable() << endl;

}

