#include "BasicBlock.hpp"
#include <iostream>

BasicBlock::BasicBlock(int id) : blockID(id){}

void BasicBlock::pushBackInstruction(Instruction instruction)
{
	basicBlock.push_back(instruction);
}

string BasicBlock::dumpBasicBlock()
{
	list<Instruction>::iterator iterator;
	string temp = "";
	iterator = basicBlock.begin();

	while (iterator != basicBlock.end()) {
		temp += iterator->dumpInstruction();
		iterator++;
	}
	return temp;
}

int BasicBlock::getInstructionNum()
{	
	return basicBlock.size();
}



