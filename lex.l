%option noyywrap
%{
	#include "grammar.tab.h"
%}
digit	[0-9]
alpha	[a-zA-Z]
id	{alpha}({alpha}*{digit}*)+
whitespace	[ \r\t\v\f]
linefeed	\n
slash	[/]
singlecomment	{slash}{slash}({dot}*{whitespace}*)+{linefeed}
multilinecomments {LESS_THAN}{PLUS}({dot}*{whitespace}*{linefeed}*)+{PLUS}{GREATHER_THAN}
quotes	[\"]
PLUS [+]
GREATHER_THAN [>]
LESS_THAN [<]
DIAG_INV [\\]
characters	{quotes}({alpha}*{digit}*{whitespace}*:*)+{quotes}
dot .

%%

{digit}+	{ return INTEGER_VALUE; }
{singlecomment}		{ return SINGLECOMMENT; }
{multilinecomments}	{ return MULTILINECOMMENTS; }
","			{ return COMA; }
"Int"			{ return INT; }
"Dec"			{ return DEC; }
"Bln"			{ return BLN; }
"Str"			{ return STR; }
"show"			{ return SHOW; }
"answer"		{ return ANSWER; }
"load"			{ return LOAD; }
{id}			{ return ID; }
{quotes}		{ return QUOTES; }
{characters}		{ return CHARACTERS; }
{PLUS}			{ return PLUS; }
{GREATHER_THAN}		{ return GREATHER_THAN; }
{LESS_THAN}		{ return LESS_THAN; }
{DIAG_INV}		{ return DIAG_INV; }
"$"	{ return DOLLAR_SIGN; }
":"	{ return COLON; }
";"	{ return SEMICOLON; }
"["	{ return LEFT_BRACKET; }
"]"	{ return RIGHT_BRACKET; }
"->"	{ return RIGHT_ARROW; }
"{"	{ return LEFT_CURLY_BRACE; }
"}"	{ return RIGHT_CURLY_BRACE; }
"|"	{ return PIPE_MARK; }
"=="	{ return IGUAL; }
">="	{ return MAYOR_IGUAL; }
"<="	{ return MENOR_IGUAL; }
"!="	{ return DIFERENTES; }
"?"	{ return QUESTION_MARK; }
"@"	{ return ARROBA; }
"-"	{ return MINUS; }
"%"	{ return PSG; }
"/"	{ return DIV; }
"+:"	{ return INCREMENTO; }
{whitespace}
{linefeed}	++yylineno;

%%
#include <stdio.h>
