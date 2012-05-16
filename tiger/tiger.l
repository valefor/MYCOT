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
 *  LocalModule:lexer
 * }
 * 
 * @CGL:{
 *  Contract: Disobey
 *  Reason  : This file is the input file of LEX program,is not a pure C file.
 *            Naming can't meet the CGL requirement;
 * }
 * 
 * @Doc:{
 *
 *  x. Abbreviations:
 *      tg      <->     tiger
 *      st      <->     symbol table
 *      lxr     <->     lexer
 *      psr     <->     parser
 *      param   <->     parameter
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/

%top{
#define YY_DECL int f_tg_yylex( \
    struct psr_params_s *pPsrParams, \
    yyscan_t yyscanner\
)
}

%{
/* C Declarations: */
#include "tiger.h"
#include "st.h"
#include "node.h"
#include "tiger_parser.h"

void f_lxr_count(yyscan_t,psr_params_t *);
tg_id_t f_lxr_idCheck(psr_params_t *,const char *);

/* The following Macros follow the YACC&LEX Macro Def Stype:yyxxxx */
#define yylloc pPsrParams->psr_yylloc
#define yylval pPsrParams->psr_yylval


#define COUNT  f_lxr_count(yyscanner,pPsrParams)
#define LEX_CURR_LINE_BUFF_SIZE 160

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

[ \t\n]+  { COUNT;putchar(' '); /* eat up whitespaces */ }

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
int     { COUNT; return KW_INT; }
string  { COUNT; return KW_STR; }
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

{IDENTIFIER} { COUNT; return f_lxr_idCheck(pPsrParams,yytext); }
{LETTERS}?\"(\\.|[^\\"])*\" { COUNT; return tSTRING; }

} 

%%

/*********************
 * User code section *
 *********************/

tg_id_t
f_lxr_idCheck(psr_params_t *pPsrParams,const char * pYyText)
{
    tg_id_t tId = tERROR;
    switch( yylexs ) {
        case E_PSR_LS_VARDEC:
        case E_PSR_LS_TYPEDEC:
        case E_PSR_LS_TYPEFEILD:
        case E_PSR_LS_FUNCDEC:
            if( !f_tg_symbolExisted(pYyText,yysymb,&(yylval->id)) ) {
                yylval->id = f_tg_regToSymbolTable(pYyText,yysymb);
                tId = IDENTIFIER;
            }
            else {
                yyerror(pPsrParams,"Duplicated identifier declaration!\n");
                tId = tERROR;
            }
            yylexs = E_PSR_LS_UNDEF;
            break;
        case E_PSR_LS_UNDEF:
            if( !f_tg_symbolExisted(pYyText,yysymb,&(yylval->id)) ) {
                yyerror(pPsrParams,"Undeclared identifier!\n");
                return tERROR;
            }
            else {
                tId = IDENTIFIER;
            }
        default:
            break;
    }
    return tId;
}
 
bool
f_lxr_createClBuffer(char ** pBuffRef,int * sizeRef)
{
    *sizeRef = LEX_CURR_LINE_BUFF_SIZE;

    if( *pBuffRef = MEM_CALLOC(*sizeRef,sizeof(char)) )
        return TRUE;
    else
        return FALSE;
}

bool 
f_lxr_reSizeClBuffer(char ** pBuffRef,int * sizeRef)
{
    char * pNewBuff;
    *sizeRef = *sizeRef * 2;
    if( pNewBuff = MEM_REALLOC(char,pNewBuff,*sizeRef) )
    {
        MEM_COPY(pNewBuff,*pBuffRef,char,(*sizeRef)/2);
        *pBuffRef = pNewBuff;
        return TRUE;
    }
    else {return FALSE;}
}

void
f_lxr_flushClBuffer(char * currBuff)
{
    if(currBuff)
        currBuff[0] = '\0';
}

void 
f_lxr_count(yyscan_t scanner,psr_params_t *pPsrParams)
{
    int i;

    if( !(yylloc->currLineBuff) )
        f_lxr_createClBuffer(
            &(yylloc->currLineBuff),
            &(yylloc->buffSize)
        );
    
    for (i = 0; yyget_text(scanner)[i] != '\0'; i++)
    {
        if (yyget_text(scanner)[i] == '\n')
        {
            ++yylloc->lastLine;
            f_lxr_flushClBuffer(yylloc->currLineBuff);
            yylloc->lastColumn = 0;
        }
        else
        {
            if( (yylloc->lastColumn) >= (yylloc->buffSize - 2) )
                f_lxr_reSizeClBuffer(
                    &(yylloc->currLineBuff),
                    &(yylloc->buffSize)
                );

            yylloc->currLineBuff[yylloc->lastColumn] = yyget_text(scanner)[i];

            if (yyget_text(scanner)[i] == '\t')
                yylloc->lastColumn +=  4 - (yylloc->lastColumn % 4);
            else
                ++yylloc->lastColumn;

        }
    }

    yylloc->currLineBuff[yylloc->lastColumn] = '\0';

    printf("[%d:%d]yytext=%s\n",
        yylloc->lastLine,
        yylloc->lastColumn,
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
int 
main( int argc, char ** argv)
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
