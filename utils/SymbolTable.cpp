#include "SymbolTable.hpp"

SymbolTable::SymbolTable(){}

bool SymbolTable::isSymbolInTable(string symbolName)
{
	if (symbolTable.find(symbolName) == symbolTable.end()) {
		return false;
	}
	else
		return true;
}

bool SymbolTable::insertNewVariable(string symbolName, Type dataType, int assignedReg)
{
	if (isSymbolInTable(symbolName) == false) {
		symbolTable.insert({ symbolName, VariableEntry(dataType, assignedReg) });
		return true;
	}
	else {
		printf("Symbol exists already\n");
		return false;
	}
}

int SymbolTable::getAssignedRegister(string symbolName)
{
	if (isSymbolInTable(symbolName) == true) {
		auto var = symbolTable.find(symbolName);
		return var->second.getAssignedRegister();
	}
	else {
		printf("Symbol doesn't exist\n");
		return 0;
	}
}

Type::TypeName SymbolTable::getDataType(string symbolName)
{
	if (isSymbolInTable(symbolName) == true) {
		auto var = symbolTable.find(symbolName);
		return var->second.getDataType();
	}
	else {
		printf("Symbol doesn't exist\n");
		return Type::INVALID_TYPE;
	}
}

const string SymbolTable::dumpSymbolTable()
{
	printf("Symbol Name, Variable Entry\n");
	string temp = "";
	for (auto var : symbolTable) {
		temp += var.first + " " + var.second.dumpEntry() + "\n";
	}
	return temp;
}



















