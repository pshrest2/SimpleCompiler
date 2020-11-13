#ifndef TYPE_HPP
#define TYPE_HPP

#include <string>

#define TYPE_NUM 5

using namespace std;

class Type {
public:
	// TODO more types to be added
	enum TypeName {
		INT,
		FLOAT,
		INT_PTR,
		FLOAT_PTR,
		INVALID_TYPE
	};

	Type(TypeName);

	void convertToPointerType();

	const Type::TypeName getTypeName();

	const string dumpTypeName();
private:
	TypeName type;

	const string typeNameString[TYPE_NUM] = { "int",
												"float",
												"int *",
												"float *",
												"invalid type" };
};

#endif