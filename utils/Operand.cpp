#include "Operand.hpp"
#include <iostream>

Operand::Operand(){}

Operand::Operand(OperandType opType, int val) : operandType(opType), value(val){}

int Operand::getOperandValue()
{
	return value;
}

Operand::OperandType Operand::getOperandType()
{
	return operandType;
}


string Operand::dumpOperand()
{
	string op;
	auto opType = getOperandType();
	auto opValue = to_string(getOperandValue());

	switch (opType) {
		case 0:
			op = 'R' + opValue;
			break;
		case 1:
			op = '&' + opValue;
			break;
		case 2:
			op = '$' + opValue;
			break;
		case 3:
			op = 'L' + opValue;
			break;
		case 4:
			op = "none";
	}
	return op;
}



