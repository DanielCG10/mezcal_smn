%code requires{
	#include <string>
}
%{
	#include <math.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <iostream>
	#include <memory>
	#include <string>
	using namespace std;
	extern char *yytext;
	extern int  yylineno;
	std::string result;
	int yylex(void);
	void yyerror(char const *);
%}

%define api.value.type {std::string}

%token	ID COLON LEFT_BRACKET RIGHT_BRACKET RIGHT_ARROW LEFT_CURLY_BRACE RIGHT_CURLY_BRACE SINGLECOMMENT MULTILINECOMMENTS QUOTES INT DEC SHOW ANSWER SEMICOLON CHARACTERS LOAD DOLLAR_SIGN GREATHER_THAN LESS_THAN BLN STR INTEGER_VALUE PIPE_MARK QUESTION_MARK IGUAL MAYOR_IGUAL MENOR_IGUAL DIFERENTES PLUS MINUS ARROBA DIAG_INV COMA PSG DIV INCREMENTO

%start input

%%

input:
	function function_list	{
			result = std::string("#include <cstdio>\n #include <iostream> \n using namespace std; \n") + $1 + $2;
				}
	;

function_list:
	function function_list { $$ = $1 + $2; }
	|
	%empty	{ $$ = ""; }
	;

function:
	id COLON COLON LEFT_BRACKET RIGHT_BRACKET RIGHT_ARROW LEFT_BRACKET RIGHT_BRACKET COLON LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE
	{ $$ = std::string("int main(int argc, char *argv[]){ \n") + $11 + "} \n"; }
	;

statements:
	statements statement	{ $$ = $1 + $2; }
	|
	%empty	{ $$ = ""; }
	;

statement:
	loops	{ $$ = $1; }
	|
	bifurcation	{ $$ = $1; }
	|
	SINGLECOMMENT	{ $$ = ""; }
	|
	std_output SEMICOLON	{ $$ = $1; }
	|
	MULTILINECOMMENTS	{ $$ = "";}
	|
	definition SEMICOLON	{ $$ = $1; }
	|
	std_input SEMICOLON	{ $$ = $1; }
	|
	assignment SEMICOLON	{ $$ = $1; }
	|
	operaciones SEMICOLON	{ $$ = $1; }
	|
	operaciones_dos	{ $$ = $1; }
	|
	unitaryOperation SEMICOLON	{ $$ = $1; }
	|
	unitaryOperation_dos	{ $$ = $1; }
	;

unitaryOperation:
	INCREMENTO identifiers	{ $$ = $2 + "++;\n"; }
	;

unitaryOperation_dos:
	INCREMENTO identifiers	{ $$ = $2 + "++\n"; }
	;

operaciones_dos:
	identifiers COLON DOLLAR_SIGN identifiers PLUS integer_value	{ $$ = $1 + "=" + $4 + "+" + $6; }
	|
	identifiers COLON integer_value PLUS integer_value	{ $$ = $1 + "=" + $3 + "+" + $5; }
	|
	identifiers COLON DOLLAR_SIGN identifiers MINUS integer_value	{ $$ = $1 + "=" + $4 + "-" + $6; }
	|
	identifiers COLON integer_value MINUS integer_value	{ $$ = $1 + "=" + $3 + "-" + $5; }
	;

operaciones:
	identifiers COLON integer_value MINUS integer_value { $$ = $1 + "=" + $3 + "-" + $5 + ";\n"; }
	|
	identifiers COLON DOLLAR_SIGN identifiers MINUS integer_value	{ $$ = $1 + "=" + $4 + "+" + $6 + ";\n"; }	
	|
	identifiers COLON integer_value PLUS integer_value { $$ = $1 + "=" + $3 + "+" + $5 + ";\n"; }
	|
	identifiers COLON DOLLAR_SIGN identifiers PLUS integer_value	{ $$ = $1 + "=" + $4 + "+" + $6 + ";\n"; }
	|
	identifiers COLON integer_value DIV integer_value { $$ = $1 + "=" + $3 + "/" + $5 + ";\n"; }
	|
	identifiers COLON DOLLAR_SIGN identifiers DIV integer_value	{ $$ = $1 + "=" + $4 + "/" + $6 + ";\n"; }
	|
	identifiers COLON integer_value PSG integer_value { $$ = $1 + "=" + $3 + "%" + $5 + ";\n"; }
	|
	identifiers COLON DOLLAR_SIGN identifiers PSG integer_value	{ $$ = $1 + "=" + $4 + "%" + $6 + ";\n"; }
	;

loops:
	LEFT_BRACKET logicalComparison RIGHT_BRACKET ARROBA LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE { 
	$$ = "while(" + $2 + "){\n" + $6 + "}\n"; }
	|
	LEFT_BRACKET assignment PIPE_MARK logicalComparison PIPE_MARK operaciones_dos RIGHT_BRACKET ARROBA LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE {
	$$ = "for(" + $2  + $4 + ";" + $6 + "){\n" + $10 + "}\n"; }
	;

bifurcation:
	LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE {
	$$ = "if(" + $2 + "){\n" + $6 + "}\n"; }
	|
	PIPE_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE {
	$$ = "else {\n" + $3 + "}\n"; }
	|
	LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE PIPE_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE { 
	$$ = "if(" + $2 + "){\n" + $6 + "\n} else {\n" + $10 + "}\n"; 
	}
	|
	LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE PIPE_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE {
	$$ = "if(" + $2 + "){\n" + $6 + "\n} else if(" +$9 +"){\n" + $13 + "\n} else {\n" +$17 + "}\n";
	}
	|
	LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE PIPE_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE {
	$$ = "if(" + $2 + "){\n" + $6 + "\n} else if(" +$9 +"){\n" + $13 + "\n} else if(" +$16 + "){\n" + $20 + "\n} else {\n" + $24 + "}\n"; }
	|
	LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE PIPE_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE {
	$$ = "if(" + $2 + "){\n" + $6 + "\n} else if(" +$9 +"){\n" + $13 + "\n} else if(" +$16 + "){\n" + $20 + "\n} else if(" + $23 + "){\n" + $27 + "\n} else {\n" +$31 + "}\n"; }
	|
	LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE LEFT_BRACKET logicalComparison RIGHT_BRACKET QUESTION_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE PIPE_MARK LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE {
	$$ = "if(" + $2 + "){\n" + $6 + "\n} else if(" +$9 +"){\n" + $13 + "\n} else if(" +$16 + "){\n" + $20 + "\n} else if(" + $23 + "){\n" + $27 + "\n} else if(" + $30 + "){\n" + $34 + "\n} else {\n" + $38 + "}\n"; }
	;

logicalComparison:
	DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET GREATHER_THAN DOLLAR_SIGN identifiers { $$ = $2 + "[" + $5 + "]" + ">" + $9; } 
	|
	DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET GREATHER_THAN DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers PLUS integer_value RIGHT_BRACKET { $$ = $2 + "[" + $5 + "]" + ">" + $9 + "[" + $12 + "+" + $14 + "] "; } 
	|
	integer_value GREATHER_THAN integer_value	{ $$ = $1 + ">" + $3; }
	|
	DOLLAR_SIGN identifiers GREATHER_THAN DOLLAR_SIGN identifiers	{ $$ = $2 + ">" + $5; }
	|
	DOLLAR_SIGN identifiers GREATHER_THAN integer_value	{ $$ = $2 + ">" + $4; }
	|
	DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET LESS_THAN DOLLAR_SIGN identifiers { $$ = $2 + "[" +$5 + "]" + "<" + $9; } 
	|
	DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET LESS_THAN DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers PLUS integer_value RIGHT_BRACKET { $$ = $2 + "[" + $5 + "]" + "<" + $9 + "[" + $12 + "+" + $14 + "] "; } 
	|
	integer_value LESS_THAN integer_value	{$$ = $1 + "<" + $3; }
	|
	DOLLAR_SIGN identifiers LESS_THAN DOLLAR_SIGN identifiers	{ $$ = $2 + "<" + $5; }
	|
	DOLLAR_SIGN identifiers LESS_THAN integer_value	{ $$ = $2 + "<" + $4; }
	|
	DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET IGUAL DOLLAR_SIGN identifiers { $$ = $2 + "[" +$5 + "]" + "==" + $9; } 
	|	
	integer_value IGUAL integer_value	{ $$ = $1 + "==" + $3; }
	|
	DOLLAR_SIGN identifiers IGUAL DOLLAR_SIGN identifiers	{ $$ = $2 + "==" + $5; }
	|
	DOLLAR_SIGN identifiers IGUAL integer_value	{ $$ = $2 + "==" + $4; }
	|
	DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET MAYOR_IGUAL DOLLAR_SIGN identifiers { $$ = $2 + "[" +$5 + "]" + ">=" + $9; } 
	|	
	integer_value MAYOR_IGUAL integer_value	{ $$ = $1 + ">=" + $3; }
	|
	DOLLAR_SIGN identifiers MAYOR_IGUAL  DOLLAR_SIGN identifiers	{ $$ = $2 + ">=" + $5; }
	|
	DOLLAR_SIGN identifiers MAYOR_IGUAL integer_value	{ $$ = $2 + ">=" + $4; }
	|
	DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET MENOR_IGUAL DOLLAR_SIGN identifiers { $$ = $2 + "[" +$5 + "]" + "<=" + $9; } 
	|	
	integer_value MENOR_IGUAL integer_value	{ $$ = $1 + "<=" + $3; }
	|
	DOLLAR_SIGN identifiers MENOR_IGUAL  DOLLAR_SIGN identifiers	{ $$ = $2 + "<=" + $5; }
	|
	DOLLAR_SIGN identifiers MENOR_IGUAL  integer_value	{ $$ = $2 + "<=" + $4; }
	|
	DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET DIFERENTES DOLLAR_SIGN identifiers { $$ = $2 + "[" +$5 + "]" + "!=" + $9; } 
	|
	DOLLAR_SIGN identifiers PSG integer_value DIFERENTES integer_value { $$ = $2 + "%" + $4 + "!=" + $6; } 
	|	
	integer_value DIFERENTES integer_value	{ $$ = $1 + "!=" + $3; }
	|
	DOLLAR_SIGN identifiers DIFERENTES DOLLAR_SIGN identifiers	{ $$ = $2 + "!=" + $5; }
	|
	DOLLAR_SIGN identifiers DIFERENTES integer_value	{ $$ = $2 + "!=" + $4; }
	; 

assignment:
	identifiers COLON integer_value	{ $$ = $1 + "=" + $3 + "; \n"; }
	|
	identifiers COLON DOLLAR_SIGN identifiers	{ $$ = $1 + "=" + $4 + "; \n"; }
	|
	identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET COLON DOLLAR_SIGN identifiers {$$ = $1 + "[" + $4 + "] = " + $8 + ";\n"; }
	|
	identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET COLON DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET {$$ = $1 + "[" + $4 + "] = " + $8 + "[" + $11 + "];\n"; }
	|
	identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET COLON DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers PLUS integer_value RIGHT_BRACKET {$$ = $1 + "[" + $4 + "] = " + $8 + "[" + $11 + "+" + $13 +"];\n"; }
	|
	identifiers LEFT_BRACKET DOLLAR_SIGN identifiers PLUS integer_value RIGHT_BRACKET COLON DOLLAR_SIGN identifiers	{ $$ = $1 + "[" +$4 + "+" + $6 + "] = " + $10 + ";\n"; }
	|	
	identifiers COLON DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET { $$ = $1 + "=" + $4 + "[" + $7 + "]\n;"; }
	|
	identifiers COLON DOLLAR_SIGN identifiers LEFT_BRACKET integer_value RIGHT_BRACKET { $$ = $1 + "=" + $4 + "[" + $6 + "]\n;"; }
	|
	identifiers COLON LEFT_BRACKET integer_value COMA integer_value RIGHT_BRACKET { $$ = $1 + "[" + $4 + "] = " + $6 + ";\n"; }
	|
	identifiers COLON LEFT_BRACKET DOLLAR_SIGN identifiers COMA DOLLAR_SIGN identifiers RIGHT_BRACKET { $$ = $1 + "[" + $5 + "] = " + $8 + ";\n"; }	
	|
	identifiers COLON characters	{ $$ = $1 + " = " + $3 + ";\n"; }
	|
	identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET INCREMENTO integer_value { $$ = $1 + "[" + $4 + "]" + "+=" + $7 + ";\n"; }
	|
	identifiers INCREMENTO DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET { $$ = $1 + "+=" + $4 + "[" + $7 + "]" + ";\n"; }
	|
	identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET COLON integer_value {$$ = $1 + "[" + $4 + "] = " + $7 + ";\n"; }
	|
	identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET unitaryOperation_dos { $$ = $1 + "[" + $4 + "]" + $6 + ";\n"; } 
	|
	identifiers COLON DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers PLUS integer_value RIGHT_BRACKET { $$ = $1 + "=" + $4 + "[" + $7 + "+" + $9 + "]" + ";\n"; }
	|
	identifiers COLON DOLLAR_SIGN identifiers PLUS DOLLAR_SIGN identifiers { $$ = $1 + "=" + $4 + "+" + $7 + ";\n"; }
	|
	identifiers COLON DOLLAR_SIGN identifiers PLUS DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET { $$ = $1 + "=" + $4 + "+" + $7 + "[" + $10 + "]" + ";\n"; }
	;

integer_value:
	INTEGER_VALUE { $$ = std::string(yytext); }
	;

definition:
	identifiers COLON INT LEFT_BRACKET integer_value RIGHT_BRACKET	{ $$ ="int " + $1 + "[" + $5 + "]" + ";\n"; }
	|
	identifiers COLON DEC LEFT_BRACKET integer_value RIGHT_BRACKET	{ $$ ="float " + $1 + "[" + $5 + "]" + ";\n"; }
	|	
	identifiers COLON INT	{ $$ ="int " + $1 + "; \n"; }
	|
	identifiers COLON DEC	{ $$ ="float " + $1 + "; \n"; }
	|
	identifiers COLON BLN	{ $$ ="bool " + $1 + "; \n"; }
	|
	identifiers COLON STR	{ $$ ="string " + $1 + "; \n"; }
	;

identifiers:
	identifiers ids	{ $$ = $1 + $2; }
	|
	%empty	{ $$ = ""; }
	;

ids:
	id	{ $$ = $1; }
	;

std_output:
	SHOW COLON DOLLAR_SIGN identifiers	{ $$ = "cout << " + $3 + $4 + " << endl; \n"; }
	|
	SHOW COLON characters	{ $$ = "\t cout << " + $3 + " << endl; \n"; }
	|
	SHOW COLON DOLLAR_SIGN assignment COMA integer_value	{ $$ = "\t cout << " + $4 + "[" + $6 + "] << endl;\n"; }
	|
	SHOW COLON characters COMA DOLLAR_SIGN identifiers COMA characters	{ $$ = "\t cout << " + $3 + "<< " + $6 + " << endl;\n"; }
	|
	SHOW COLON DOLLAR_SIGN identifiers LEFT_BRACKET DOLLAR_SIGN identifiers RIGHT_BRACKET { $$ = "\t cout << " + $4 + "[" + $7 + "] << endl;\n"; }
	|
	SHOW COLON DOLLAR_SIGN identifiers COMA DOLLAR_SIGN identifiers { $$ = "\t cout << " + $4 + " << " + $7 + " << endl;\n"; }
	;

std_input:
	LOAD COLON identifiers	{ $$= "cin >> " + $3 + "; \n"; } 
	//LOAD COLON identifiers	{ $$ = "printf(\"entro\");"; }
	;
	
characters:
	CHARACTERS	{ $$ = std::string(yytext); }
	;
	
id:
	ID	{ $$ = std::string(yytext); }
	;

%%
void yyerror(char const *x){
	printf("Error %s, en la linea: %d\n", x, yylineno);
	exit(1);
}
