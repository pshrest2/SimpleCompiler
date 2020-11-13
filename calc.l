%{
#include "calc.tab.h"

%}

%option noyywrap

TOK_INT			(int)
TOK_IF			(if)
TOK_ELSE		(else)
TOK_FOR			(for)

TOK_ID				[a-zA-Z_][a-zA-Z0-9_]*

TOK_PLUS			\+
TOK_MINUS			\-
TOK_MULT			\*
TOK_DIV				\/
TOK_MOD				\%
TOK_EQUAL			\=
TOK_EQUALITY		(\=\=)
TOK_INEQUALITY		(\!\=)
TOK_GREATER			\>
TOK_LESS			\<
TOK_GREATER_EQUAL	(\>\=)
TOK_LESS_EQUAL		(\<\=)
TOK_ADD_EQUAL		(\+\=)
TOK_MINUS_EQUAL		(\-\=)
TOK_MULT_EQUAL		(\*\=)
TOK_DIV_EQUAL		(\/\=)
TOK_MOD_EQUAL		(\%\=)
TOK_INCREMENT		(\+\+)
TOK_DECREMENT		(\-\-)

TOK_PAR_OPEN		\(
TOK_PAR_CLOSE		\)
TOK_CURLY_BRACE_OPEN	\{
TOK_CURLY_BRACE_CLOSE	\}
TOK_SEMICOLON		\;
TOK_RETURN		(return)





%%

[0-9]+   					{ yylval.val = atoi(yytext); return NUM; }
[ \t\n]						;
"exit" 						exit(1);
"print"						yyterminate();

{TOK_PLUS} {

	return TOK_PLUS;
}

{TOK_MINUS} {

	return TOK_MINUS;
}
{TOK_MULT} {

	return TOK_MULT;
}
{TOK_DIV} {

	return TOK_DIV;
}
{TOK_MOD} {

	return TOK_MOD;
}
{TOK_EQUAL} {

	return TOK_EQUAL;
}

{TOK_EQUALITY} {

	return TOK_EQUALITY;
}
{TOK_INEQUALITY} {

	return TOK_INEQUALITY;
}
{TOK_GREATER} {

	return TOK_GREATER;
}
{TOK_LESS} {
	
	return TOK_LESS;
}
{TOK_GREATER_EQUAL} {

	return TOK_GREATER_EQUAL;
}
{TOK_LESS_EQUAL} {

	return TOK_LESS_EQUAL;
}
{TOK_ADD_EQUAL} {

	return TOK_ADD_EQUAL;
}
{TOK_MINUS_EQUAL} {

	return TOK_MINUS_EQUAL;
}
{TOK_MULT_EQUAL} {

	return TOK_MULT_EQUAL;
}
{TOK_DIV_EQUAL} {
	
	return TOK_DIV_EQUAL;
}
{TOK_MOD_EQUAL} {
	
	return TOK_MOD_EQUAL;
}
{TOK_INCREMENT} {
	
	return TOK_INCREMENT;
}
{TOK_DECREMENT} {
	
	return TOK_DECREMENT;
}

{TOK_PAR_OPEN} {

	return TOK_PAR_OPEN;
}
{TOK_PAR_CLOSE} {

	return TOK_PAR_CLOSE;
}
{TOK_CURLY_BRACE_OPEN} {

	return TOK_CURLY_BRACE_OPEN;
}
{TOK_CURLY_BRACE_CLOSE} {

	return TOK_CURLY_BRACE_CLOSE;
}
{TOK_SEMICOLON} {
	return TOK_SEMICOLON;
}
{TOK_RETURN} {
	return TOK_RETURN;
}

{TOK_INT} {
	return TOK_INT;
}
{TOK_IF} {
	return TOK_IF;
}
{TOK_ELSE} {
	return TOK_ELSE;
}
{TOK_FOR} {
	return TOK_FOR;
}







{TOK_ID} {
	yylval.identifier = yytext;
	return TOK_ID;
}
.							{ return yytext[0]; }

%%




