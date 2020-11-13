#include "VariableEntry.hpp"
#include <string>

//VariableEntry :: VariableEntry(){}
VariableEntry::VariableEntry(Type dType, int reg) : dataType(dType), assignedReg(reg) {}

int VariableEntry::getAssignedRegister() {
	return assignedReg;
}

Type::TypeName VariableEntry::getDataType() {
	return dataType.getTypeName();
}

string VariableEntry::dumpEntry() {
	string data = "Data Type is: " + dataType.dumpTypeName();
	string reg = ", Assigned Register is: " + to_string(getAssignedRegister());
	return data + reg;
}



