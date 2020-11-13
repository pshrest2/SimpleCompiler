#include "Type.hpp"

Type::Type(TypeName tp) : type(tp){}

void Type::convertToPointerType()
{
	if (type == Type::INT)
		type = Type::INT_PTR;
	if (type == Type::FLOAT)
		type = Type::FLOAT_PTR;
}

const Type::TypeName Type::getTypeName()
{
	return type;
}

const string Type::dumpTypeName()
{
	return typeNameString[getTypeName()];
}

