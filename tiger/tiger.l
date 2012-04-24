/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Tiger's Lexer $\ }
 * 
 * @Author:{
 *  Name  : Adrian Hu
 *  Email : adrain.f.tepes@gmail.com
 * }
 * 
 *
 * @Progress:{
 * Phase 1 ->
 *  1. Float unsupported
 * 
 * }
 * 
 * }
 * @Module:{
 *  LocalMoudle:lexer
 * }
 * 
 * @CGL:{
 *  Contract: Disobey
 *  Reason  : This file is the input file of YACC program,is not a pure C file.
 *            Naming can't meet the CGL requirement;
 * }
 * 
 * @Doc:{
 *
 *  x. Abbreviations:
 *      lexer       <->     lxr
 *      parser      <->     psr
 *      parameter   <->     param
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/

%top{
#define YY_DECL int tiger_yylex( \
    struct s_psr_params *pPsrParams, \
    yyscan_t yyscanner\
)
}

%{
/* C Declarations: */
#include "tiger.h"
#include "tiger_types.h"
#include "tiger_parser.h"

void f_lxr_count(yyscan_t,psr_params_t *);

#define yylloc pPsrParams->psr_yylloc
#define yylval pPsrParams->psr_yylval
#define COUNT  f_lxr_count(yyscanner,pPsrParams)

%}
%option noyywrap stack reentrant

%x COMMENT_BLOCK 
%x COMMENT_LINE

DIGITS      [0-9]+
LETTERS     [a-zA-Z_]
HEX         [a-fA-F0-9]
IDENTIFIER  [_a-zA-Z][a-zA-Z0-9]*
PUNTUATOR   [{}(),=:;\[\]]
LOGIC_OP    [<>\|&\?]
ARITH_OP    [\+\-\*\/\%]
ARRAY_OF    "array of"
ASSIGN      ":="

%%
<COMMENT_BLOCK>{
[^*\n]* 
"*"+[^*/\n]* 
\n      { COUNT; }
"*"+"/" { yy_pop_state(yyscanner); }
} 

<COMMENT_LINE>[^\n]* 
<COMMENT_LINE>\n { COUNT;yy_pop_state(yyscanner); }


<INITIAL>{
"/*"    { yy_push_state(COMMENT_BLOCK,yyscanner); }
"//"    { yy_push_state(COMMENT_LINE,yyscanner); }

[ \t]+  { COUNT;putchar(' '); /* eat up whitespaces */ }
\n      { COUNT; }      

if      { COUNT; return KW_IF; }
then    { COUNT; return KW_THEN; }
else    { COUNT; return KW_ELSE; }
end     { COUNT; return KW_END; }
while   { COUNT; return KW_WHILE; }
do      { COUNT; return KW_DO; }
for     { COUNT; return KW_FOR; }
in      { COUNT; return KW_IN; }
to      { COUNT; return KW_TO; }
break   { COUNT; return KW_BREAK; }
let     { COUNT; return KW_LET; }
of      { COUNT; return KW_OF; }

type    { COUNT; return KW_TYPE; }
nil     { COUNT; return KW_NIL; }
var     { COUNT; return KW_VAR; }
int     { COUNT; return KW_TYPE_INT; }
string  { COUNT; return KW_TYPE_STR; }
function { COUNT; return KW_FUNC; }

"=="    { COUNT; return tEQ; }
"!="    { COUNT; return tNEQ; }
"<="    { COUNT; return tGEQ; }
">="    { COUNT; return tLEQ; }
{ASSIGN}    { COUNT; return tASSIGN; }
{ARRAY_OF}  { COUNT; return KW_ARRAY_OF; }

{ARITH_OP}  { COUNT; return *yytext; }
{LOGIC_OP}|{PUNTUATOR} { COUNT; return *yytext; }

{DIGITS}    { COUNT; return tNUMBER; }
{IDENTIFIER}    {  yylval->id = yytext ;COUNT; return IDENTIFIER; }
{LETTERS}?\"(\\.|[^\\"])*\" { COUNT; return tSTRING; }

} 

%%

/*********************
 * User code section *
 *********************/

void f_lxr_count(yyscan_t scanner,psr_params_t *pPsrParams)
{
        int i;

        for (i = 0; yyget_text(scanner)[i] != '\0'; i++)
        if (yyget_text(scanner)[i] == '\n')
        {
            ++yylloc->last_line;
            yylloc->last_column = 0;
        }
        else if (yyget_text(scanner)[i] == '\t')
            yylloc->last_column +=  8 - (yylloc->last_column % 8);
        else
            ++yylloc->last_column;


        printf("[%d:%d]yytext=%s\n",
            yylloc->last_line,
            yylloc->last_column,
            yyget_text(scanner)
        );
        /*
        // Must redefine yyg
        struct yyguts_t * yyg = (struct yyguts_t*)scanner;
        ECHO;

        printf("yytext=%s\n",yyget_text(scanner));
        */
}

#if TG_LEX_DEBUG > 0
int main( int argc, char ** argv)
{
    printf("Enter Main\n");
    ++argv,--argc; // skip over program name

    yyscan_t scanner;
    int tok;
    yylex_init(&scanner);

    struct yyguts_t * yyg = (struct yyguts_t*)scanner;

    if( argc > 0 )
        yyin = fopen(argv[0],"r");
    else
        yyin = stdin;

    while((tok=yylex(scanner))>0) ;
        //printf("token=%d yytext=%s\n",tok,yyget_text(scanner));
    yylex_destroy(scanner);




    return 0;
}
#endif

/*


<LITERAL>"\\"+"\"" 
<LITERAL>\n     ++line_num;
<LITERAL>\n     ++line_num;
<LITERAL>"\""   { BEGIN(INITIAL);yylval->id = yytext;return tSTR;} 

*/
