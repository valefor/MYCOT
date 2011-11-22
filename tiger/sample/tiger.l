%top{
/* C Declarations: */
#include "tiny_types.h"
#include "tokens.h"
#include "errormsg.h"

union {int ival; string sval; double fval;} yylval;
int charPos = 1;
#define ADJ (EM_tokPos=charPos, charPos += yyleng)
%}

/* Lex Definitions: */
digits  [0-9]+
%%
/* Regular Expressions and Actions: */
if  { ADJ;return IF; }
[a-z][a-z0-9]*
    {
        ADJ;
        yylval.sval=String(yytext);
        return ID;
    }
{digits}
    {
        ADJ;
        yylval.ival=atoi(yytext);
        return NUM;
    }
({digits}"."[0-9]*)|([0-9]*"."{digits})
    {
        ADJ;
        yylval.fval=atof(yytext);
        return FLOAT;
    }
("--"[a-z]*"\n")|(" "|"\n"|"\t") {ADJ;}
