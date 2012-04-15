/*
 * /$ Tiger's Lexer $\
 * 
 * Phase 1 ->
 *  Float unsupported
 * 
 */

%{
/* C Declarations: */
#include "tiger_types.h"
#include "tiger_parser.h"


int line_num = 0;

void count_t(yyscan_t);
#define count()     count_t(yyscanner)

%}

%option noyywrap stack reentrant
%option bison-bridge bison-locations

%x COMMENT_BLOCK 
%x COMMENT_LINE

DIGITS      [0-9]+
LETTERS     [a-zA-Z_]
HEX         [a-fA-F0-9]
ID          [_a-zA-Z][a-zA-Z0-9]*
PUNTUATOR   [{}(),=:;\[\]]
ARITH_OP    [\+\-\*\/\%]
ARRAY_OF    "array of"
ASSIGN      ":="

%%

<COMMENT_BLOCK>[^*\n]* 
<COMMENT_BLOCK>"*"+[^*/\n]* 
<COMMENT_BLOCK>\n ++line_num;
<COMMENT_BLOCK>"*"+"/" BEGIN(INITIAL);

<COMMENT_LINE>[^\n]* 
<COMMENT_LINE>\n    { ++line_num; BEGIN(INITIAL); }

<INITIAL>"/*"   BEGIN(COMMENT_BLOCK);
<INITIAL>"//"   BEGIN(COMMENT_LINE);

<INITIAL>if     { count(); return KW_IF; }
<INITIAL>then   { count(); return KW_THEN; }
<INITIAL>else   { count(); return KW_ELSE; }
<INITIAL>end    { count(); return KW_END; }
<INITIAL>while  { count(); return KW_WHILE; }
<INITIAL>do     { count(); return KW_DO; }
<INITIAL>for    { count(); return KW_FOR; }
<INITIAL>in     { count(); return KW_IN; }
<INITIAL>to     { count(); return KW_TO; }
<INITIAL>break  { count(); return KW_BREAK; }
<INITIAL>let    { count(); return KW_LET; }

<INITIAL>type   { count(); return KW_TYPE; }
<INITIAL>nil    { count(); return KW_NIL; }
<INITIAL>var    { count(); return KW_VAR; }
<INITIAL>int    { count(); return KW_TYPE_INT; }
<INITIAL>string { count(); return KW_TYPE_STR; }
<INITIAL>function   { count(); return KW_FUNC; }

<INITIAL>{ASSIGN}   { count(); return tASSIGN; }
<INITIAL>{ARRAY_OF} { count(); return KW_ARRAY_OF; }

<INITIAL>{PUNTUATOR} { count(); return *yytext; }

<INITIAL>{ID}       {  yylval->id = yytext ;count(); return IDENTIFIER; }
<INITIAL>{DIGITS}   { count(); return tNUMBER; }
<INITIAL>{LETTERS}?\"(\\.|[^\\"])*\"     { count(); return tSTRING; }

%%

int column = 0;

void count_t(yyscan_t scanner)
{
        int i;

        for (i = 0; yyget_text(scanner)[i] != '\0'; i++)
        if (yyget_text(scanner)[i] == '\n')
                column = 0;
        else if (yyget_text(scanner)[i] == '\t')
                column += 8 - (column % 8);
        else
                column++;

        // Must redefine yyg
        struct yyguts_t * yyg = (struct yyguts_t*)scanner;

        ECHO;
}

/*


<LITERAL>"\\"+"\"" 
<LITERAL>\n     ++line_num;
<LITERAL>\n     ++line_num;
<LITERAL>"\""   { BEGIN(INITIAL);yylval->id = yytext;return tSTR;} 

*/
