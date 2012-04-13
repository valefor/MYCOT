%{
/* C Declarations: */
#include "tiger_types.h"
#include "tiger.tab.h"

%}

%option noyywrap stack reentrant

%x COMMENT_BLOCK 
%x COMMENT_LINE
%x LITERAL

DIGITS      [0-9]+
ID          [_a-zA-Z][a-zA-Z0-9]*
PUNTUATOR   [{}(),=:;\[\]]
ARITH_OP    [\+\-\*\/\%]
ARRAY_OF    "array of"
ASSIGN      ":="

%%

/* Lex Definitions: */

/* Regular Expressions and Actions: */

/*
 * Float unsupported
 */

<COMMENT_BLOCK>[^*\n]* 
<COMMENT_BLOCK>"*"+[^*/\n]* 
<COMMENT_BLOCK>\n ++line_num;
<COMMENT_BLOCK>"*"+"/" BEGIN(INITIAL);

<COMMENT_LINE>[^\n]* 
<COMMENT_LINE>\n    { ++line_num; BEGIN(INITIAL); }

<LITERAL>"\\"+"\"" 
<LITERAL>\n     ++line_num;
<LITERAL>\n     ++line_num;
<LITERAL>"\""   { BEGIN(INITIAL);yylval->id = yytext;return tSTR;} 

<INITIAL>"/*"   BEGIN(comment_block);
<INITIAL>"//"   BEGIN(comment_line);
<INITIAL>"\""   BEGIN(literal);

<INITIAL>if     { return KW_IF; }
<INITIAL>then   { return KW_THEN; }
<INITIAL>else   { return KW_ELSE; }
<INITIAL>end    { return KW_END; }
<INITIAL>while  { return KW_WHILE; }
<INITIAL>do     { return KW_DO; }
<INITIAL>for    { return KW_FOR; }
<INITIAL>let    { return KW_LET; }
<INITIAL>var    { return KW_VAR; }
<INITIAL>nil    { return KW_NIL; }
<INITIAL>type   { return KW_TYPE; }
<INITIAL>int    { return KW_TYPE_INT; }
<INITIAL>string { return KW_TYPE_STR; }
<INITIAL>function   { return KW_FUNC; }

<INITIAL>{ASSIGN}   { return KW_ASSIGN; }
<INITIAL>{ARRAY_OF} { return KW_ARRAY_OF; }

<INITIAL>{PUNTUATOR} { return *yytext; }


<INITIAL>{ID}       { yylval->id = yytext;return KW_ID; }

%%
