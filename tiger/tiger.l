%top{
/* C Declarations: */
#include "tiger_types.h"
#include "tiger.tab.h"

%}

/* Lex Definitions: */

DIGITS  [0-9]+
ARRAYOF array of
ID      [_a-zA-Z][a-zA-Z0-9]*

%x comment

%%
/* Regular Expressions and Actions: */

"/*"    BEGIN(comment);

<comment>[^*\n]* 
<comment>"*"+[^*/\n]* 
<comment>\n ++line_num;
<comment>"*"+"/" BEGIN(INITIAL);

<INITIAL>if     { return KW_IF; }
<INITIAL>then   { return KW_THEN; }
<INITIAL>else   { return KW_ELSE; }
<INITIAL>while  { return KW_WHILE; }
<INITIAL>do     { return KW_DO; }
<INITIAL>for    { return KW_FOR; }
<INITIAL>let    { return KW_LET; }
<INITIAL>var    { return KW_VAR; }
<INITIAL>nil    { return KW_NIL; }


<INITIAL>{ARRAYOF} { return KW_ARRAY_OF; }
<INITIAL>{ID}    { yylval->id = yytext;return KW_ID; }

%%
