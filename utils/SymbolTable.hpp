#ifndef SYMBOL_TABLE_HPP
#define SYMBOL_TABLE_HPP

#include <string>
#include <unordered_map>
#include <sstream>

#include "Type.hpp"
#include "VariableEntry.hpp"

using namespace std;

/*
 * Each entry in the table can be either a variable name or a function name
 * SymbolTableEntry is the super class of both VariableEntry and FunctionEntry
 */

class SymbolTable {
public:
	SymbolTable();

	bool isSymbolInTable(string symbolName);

	// functions used for variable entry
	bool insertNewVariable(string symbolName, Type dataType, int assignedReg);
	int getAssignedRegister(string symbolName);
	Type::TypeName getDataType(string symbolName);

	//		TODO functions used for function entry
	//		bool insertNewFunction();

	const string dumpSymbolTable();

private:
	unordered_map<string, VariableEntry> symbolTable;
};

#endif
