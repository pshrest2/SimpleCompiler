#include "Instruction.hpp"

Instruction::Instruction(){}

Instruction::Instruction(Opcode op) : opcode(op) {}

Instruction::Instruction(Opcode op, Operand destOp) : opcode(op) , destOperand(destOp){}

Instruction::Instruction(Opcode op, Operand destOp, Operand srcOp) : opcode(op), destOperand(destOp), srcOperand1(srcOp) {}

Instruction::Instruction(Opcode op, Operand destOp, Operand srcOp1, Operand srcOp2) : opcode(op), destOperand(destOp), srcOperand1(srcOp1), srcOperand2(srcOp2) {}

const string Instruction::dumpInstruction()
{
	// string opName = opcodeNameList[opcode];
	std::ostringstream out;
	switch (opcode) {
	case 0:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " + " << srcOperand2.dumpOperand() << '\n';
		break;
	case 1:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " - " << srcOperand2.dumpOperand() << '\n';
		break;
	case 2:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " * " << srcOperand2.dumpOperand() << '\n';
		break;
	case 3:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " / " << srcOperand2.dumpOperand() << '\n';
		break;
	case 4:
		out << destOperand.dumpOperand() << " <- " << srcOperand1.dumpOperand() << "\n";
		break;
	case 5:
		out << destOperand.dumpOperand() << " <- " << srcOperand1.dumpOperand() << "\n";
		break;
	case 6:
		out << destOperand.dumpOperand() << " <- " << srcOperand1.dumpOperand() << "\n";
		break;
	case 7:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " == " << srcOperand2.dumpOperand() << '\n';
		break;
	case 8:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " != " << srcOperand2.dumpOperand() << '\n';
		break;
	case 9:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " >= " << srcOperand2.dumpOperand() << '\n';
		break;
	case 10:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " < " << srcOperand2.dumpOperand() << '\n';
		break;
	case 11:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " > " << srcOperand2.dumpOperand() << '\n';
		break;
	case 12:
		out << destOperand.dumpOperand() << " = " << srcOperand1.dumpOperand() << " <= " << srcOperand2.dumpOperand() << '\n';
		break;
	case 13:
		out << destOperand.dumpOperand() << '\n';
		break;
	case 14:
		out << destOperand.dumpOperand() << " if " << srcOperand1.dumpOperand() << " is TRUE \nELSE\n";
		break;
	case 15:
		out << destOperand.dumpOperand() << " if " << srcOperand1.dumpOperand() << " is FALSE \nELSE\n";
		break;
	default:
		out << "NO-OP\n";
	}
	return out.str();

}

