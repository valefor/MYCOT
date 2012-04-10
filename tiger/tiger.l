%top{
/* C Declarations: */
#include "tiger_types.h"
#include "tiger.tab.h"

%}

/* Lex Definitions: */

/* Regular Expressions and Actions: */

/*
 * Float unsupported
 */

DIGITS      [0-9]+
ID          [_a-zA-Z][a-zA-Z0-9]*
PUNTUATOR   [{}(),=:;\[\]]
ARITH_OP    [\+\-\*\/\%]
ARRAY_OF    "array of"
ASSIGN      ":="

%x comment_block 
%x comment_line
%x literal

%%

"/*"    BEGIN(comment_block);
"//"    BEGIN(comment_line);
"\""    BEGIN(literal);

<comment_block>[^*\n]* 
<comment_block>"*"+[^*/\n]* 
<comment_block>\n ++line_num;
<comment_block>"*"+"/" BEGIN(INITIAL);

<comment_line>[^\n]* 
<comment_line>\n    { ++line_num; BEGIN(INITIAL); }

<literal>"\\"+"\"" 
<literal>"\"" { BEGIN(INITIAL);} 

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
<INITIAL>int    { return KW_TYPE_INT; }
<INITIAL>string { return KW_TYPE_STR; }
<INITIAL>function   { return KW_FUNC; }

<INITIAL>{ASSIGN}   { return KW_ASSIGN; }
<INITIAL>{ARRAY_OF} { return KW_ARRAY_OF; }

<INITIAL>{PUNTUATOR} { return *yytext; }


<INITIAL>{ID}       { yylval->id = yytext;return KW_ID; }

%%