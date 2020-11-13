#ifndef VARIABLE_ENTRY
#define VARIABLE_ENTRY

#include "Type.hpp"
#include <sstream>

class VariableEntry {
public:
	VariableEntry(Type dType, int reg);

	int getAssignedRegister();
	Type::TypeName getDataType();
	string dumpEntry();

private:
	Type dataType;
	int assignedReg;
};

#endif
