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
 * @Module:{
 *  LocalMoudle:lexer
 * }
 * 
 * @Doc:{
 *
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/

%top{
#define YY_DECL int tiger_yylex( \
    struct s_psr_params *pl_psrParams, \
    yyscan_t yyscanner\
)
}

%{
/* C Declarations: */
#include "tiger_types.h"
#include "tiger_parser.h"
#include "config.h"


int line_num = 0;

void f_lxr_count(yyscan_t);

#define COUNT  f_lxr_count(yyscanner);

%}
%option noyywrap stack reentrant

%x COMMENT_BLOCK 
%x COMMENT_LINE

DIGITS      [0-9]+
LETTERS     [a-zA-Z_]
HEX         [a-fA-F0-9]
ID          [_a-zA-Z][a-zA-Z0-9]*
PUNTUATOR   [{}(),=:;\[\]]
LOGIC_OP    [<>\|&\?]
ARITH_OP    [\+\-\*\/\%]
ARRAY_OF    "array of"
ASSIGN      ":="

%%
<COMMENT_BLOCK>[^*\n]* 
<COMMENT_BLOCK>"*"+[^*/\n]* 
<COMMENT_BLOCK>\n ++line_num;
<COMMENT_BLOCK>"*"+"/" { yy_pop_state(yyscanner); }

<COMMENT_LINE>[^\n]* 
<COMMENT_LINE>\n    { ++line_num; yy_pop_state(yyscanner); }

<INITIAL>"/*"   { yy_push_state(COMMENT_BLOCK,yyscanner); }
<INITIAL>"//"   { yy_push_state(COMMENT_LINE,yyscanner); }

<INITIAL>[ \t]+ { putchar(' '); /* eat up whitespaces */ }

<INITIAL>if     { COUNT; return KW_IF; }
<INITIAL>then   { COUNT; return KW_THEN; }
<INITIAL>else   { COUNT; return KW_ELSE; }
<INITIAL>end    { COUNT; return KW_END; }
<INITIAL>while  { COUNT; return KW_WHILE; }
<INITIAL>do     { COUNT; return KW_DO; }
<INITIAL>for    { COUNT; return KW_FOR; }
<INITIAL>in     { COUNT; return KW_IN; }
<INITIAL>to     { COUNT; return KW_TO; }
<INITIAL>break  { COUNT; return KW_BREAK; }
<INITIAL>let    { COUNT; return KW_LET; }
<INITIAL>of     { COUNT; return KW_OF; }

<INITIAL>type   { COUNT; return KW_TYPE; }
<INITIAL>nil    { COUNT; return KW_NIL; }
<INITIAL>var    { COUNT; return KW_VAR; }
<INITIAL>int    { COUNT; return KW_TYPE_INT; }
<INITIAL>string { COUNT; return KW_TYPE_STR; }
<INITIAL>function   { COUNT; return KW_FUNC; }

<INITIAL>"=="   { COUNT; return tEQ; }
<INITIAL>"!="   { COUNT; return tNEQ; }
<INITIAL>"<="   { COUNT; return tGEQ; }
<INITIAL>">="   { COUNT; return tLEQ; }
<INITIAL>{ASSIGN}   { COUNT; return tASSIGN; }
<INITIAL>{ARRAY_OF} { COUNT; return KW_ARRAY_OF; }

<INITIAL>{ARITH_OP} { COUNT; return *yytext; }
<INITIAL>{LOGIC_OP}|{PUNTUATOR} { COUNT; return *yytext; }

<INITIAL>{ID}       {  /*yylval->id = yytext */;COUNT; return IDENTIFIER; }
<INITIAL>{DIGITS}   { COUNT; return tNUMBER; }
<INITIAL>{LETTERS}?\"(\\.|[^\\"])*\"     { COUNT; return tSTRING; }

%%

/*********************
 * User code section *
 *********************/

int column = 0;

void f_lxr_count(yyscan_t scanner)
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
        /*
        printf("yytext=%s\n",yyget_text(scanner));
        */
}

#if LEX_DEBUG > 0
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
