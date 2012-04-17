/*
 * /$ Tiger's Grammar $\
 * 
 * Phase 1 ->
 *  1. No constant
 *  2. No global var
 * 
 */

/* Declarations */
%{

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>


%}

%code provides
{
    struct parser_params
    {
        char *parser_tiger_sourcefile;
    };
}

%locations
%pure_parser
%parse-param    { struct parser_params *parserParams }
%parse-param    { void * scanner }
%lex-param      { void * scanner }

%union{
    char * id;
    int val;
}

%{
#include "tiger_lexer.h"

int yylex(YYSTYPE *lvalp, YYLTYPE * llocap, yyscan_t scanner);
void yyerror (YYLTYPE * llocap, struct parser_params * ,yyscan_t scanner, char const *s);
static void tiger_initLexer(struct parser_params *parserParams,void ** scanner);
%}

%code provides
{
    struct parser_params * parser_new(void);
}

%initial-action
{
    // Initiate scanner params
    tiger_initLexer(parserParams,&scanner);
}

/* Keyword(Reserved Word) */
%token
    KW_IF
    KW_THEN
    KW_ELSE
    KW_END
    KW_WHILE
    KW_DO
    KW_FOR
    KW_BREAK
    KW_TO
    KW_IN
    KW_LET
    KW_VAR
    KW_NIL
    KW_TYPE
    KW_TYPE_INT
    KW_TYPE_STR
    KW_FUNC
    KW_ARRAY_OF
    KW_OF

/* Token */
%token
    tLOWEST

/* Token-Operater */
%token
    tEQ
    tLEQ
    tNEQ
    tGEQ
    tUMINUS
    tASSIGN

// Const & Variable
%token <val>    tNUMBER
%token <id>     tSTRING
%token <id>     IDENTIFIER
%type  <val>    exp none

/*
<<Operator precedence>>:
The relative precedence of different operators is controlled by the order in which they are declared.
The earliest declaration,the lowest precedence
*/

%nonassoc tLOWEST

%nonassoc tEQ tNEQ '>' tGEQ '<' tLEQ
%right  tASSIGN
%left   '|' '&'
/* %left   '>' tGEQ '<' tLEQ */
%left   '-' '+'
%left   '*' '/'
%right  '!' tUMINUS

/* start parse */
%start prog
%% /* Grammar rules and actions follow */

/* Expressions */
primaryExp
        : IDENTIFIER
        | tNUMBER
        | tSTRING
        | '(' exp ')'
;

postfixExp
        : primaryExp
        | postfixExp '[' exp ']' 
        | postfixExp '[' exp ']' KW_OF exp
        | postfixExp '(' ')' 
        | postfixExp '(' argExpList ')'
;

argExpList
        : assignExp
        | argExpList ',' assignExp
;

unaryExp
        : postfixExp
;

arithExp
        : unaryExp
        | arithExp '+' unaryExp
        | arithExp '-' unaryExp
        | arithExp '*' unaryExp
        | arithExp '/' unaryExp
        | '-' unaryExp %prec tUMINUS
;

relationExp
        : arithExp
        | relationExp tLEQ arithExp
        | relationExp tGEQ arithExp
        | relationExp '<' arithExp
        | relationExp '>' arithExp
;

equalExp
        : relationExp
        | equalExp tEQ relationExp
        | equalExp tNEQ relationExp
;

andExp
        : equalExp
        | andExp '&' equalExp
;

orExp
        : andExp
        | orExp '|' andExp
;

conditionalExp
        : orExp
        | KW_IF orExp KW_THEN exp KW_ELSE exp
;

assignExp
        : conditionalExp
        | unaryExp assignOp unaryExp
;

exp     : assignExp
        | exp ',' assignExp 
;

assignOp
        : tASSIGN
;


/* Delarations */
decs
        : dec
        | decs terms dec
;

dec
        : typeDec
        | varDec
        | funcDef
;

typeDec : KW_TYPE IDENTIFIER '=' typeDef { /* if typeDef is not defined yet,through out an parse error*/ }
;

typeDef : type 
        | KW_TYPE_INT
        | KW_TYPE_STR
;

type: IDENTIFIER
    | '{' typeFields '}'
    | KW_ARRAY_OF typeDef
;

typeFields  : typeField
            | typeFields ',' typeField
;

typeField   : none
            | IDENTIFIER ':' typeDef
;

varDec  : KW_VAR IDENTIFIER assignOp unaryExp
        | KW_VAR IDENTIFIER ':' typeDef assignOp unaryExp
;

/* Function Delaration & Definition */

funcDef : KW_FUNC IDENTIFIER '(' typeFields ')' '=' compoundStmt
        | KW_FUNC IDENTIFIER '(' typeFields ')' ':' typeDef '=' compoundStmt
;

/* Statements */
compoundStmt
        : '(' ')'
        | '(' decs ')' 
        | '(' stmts ')' 
        | '(' decs stmts ')' 
;

stmts   
        : stmt
        | stmts stmt
;

stmt
        : expStmt
        | compoundStmt
        | selectionStmt
        | iterationStmt
        | jumpStmt
        | letStmt
;

expStmt
        : exp ';'
;

selectionStmt
        : KW_IF exp KW_THEN stmt
        | KW_IF exp KW_THEN stmt KW_ELSE stmt
;

iterationStmt
        : KW_WHILE exp KW_DO stmt
        | KW_FOR IDENTIFIER tASSIGN exp KW_TO exp KW_DO stmt
;

jumpStmt
        : KW_BREAK
;

letStmt
        : KW_LET decs KW_IN stmt KW_END
;

terms : term
    | terms ';' { yyerrok; }
;

term : ';'
;

none    :
        {
        $$ = 0;
        }
;

/* start parse */
extDec
    : dec
    | stmt
;

prog: extDec 
    | prog extDec
;

/* End of grammar. */
/*
assignExp: IDENTIFIER tASSIGN exp
;

compExp : exp compOp exp
;

compOp  : '>'
        : '<'
        | tEQ
        | tLEQ
        | tNEQ
        | tGEQ
;

call: IDENTIFIER "(" argsX ')'
;

declaration
        : decSpcfiers initDecList ';'
;

decSpcfiers
        : typeSpcfier
;

typeSpcfier
        : KW_TYPE
;

initDecList
        : initDec
        | initDecList ';' initDec
;

initDec
        : declarator
        | declarator assignOp initializer
;

initializer
        : assignExp
        | '{' initializerList '}'
;

initializerList
        : initializer
        | initializerList ',' initializer
;

declarator
        : IDENTIFIER
        | '(' declarator ')'
;

stmt: KW_IF compExp KW_THEN stmts optElse
    | KW_WHILE compExp KW_DO stmts
    | KW_FOR IDENTIFIER tASSIGN value KW_TO value KW_DO stmts
    | KW_BREAK
    | 
    | dec
    | exp
    | '(' stmt ')'
;

optElse: none
    |  nonNilStmts
;

nonNilStmts : stmt
            | nonNilStmts term stmt
;

*/

%%

/*
void tiger_parse(char const * filename)
{
    
}
*/

static void tiger_initLexer(struct parser_params *parserParams,yyscan_t * scanner)
{
    FILE * srcFile = fopen( parserParams->parser_tiger_sourcefile,"r" );
    YYSTYPE * v_yyVal = malloc(sizeof(YYSTYPE));
    YYLTYPE * v_yyLoc = malloc(sizeof(YYLTYPE));

    v_yyVal->val = 0;
    v_yyLoc->first_line = 0;
    v_yyLoc->first_column = 0;
    v_yyLoc->last_line = 0;
    v_yyLoc->last_column = 0;

    yylex_init(scanner);

    yyset_in(srcFile,*scanner);

    //yylex_destroy(scanner);
}

static void 
parser_initialize(struct parser_params *parser)
{
    parser->parser_tiger_sourcefile = 0;
}

struct parser_params *
parser_new(void)
{
    struct parser_params *p;

    p = malloc(sizeof(struct parser_params));
    parser_initialize(p);
    return p;
}

void yyerror(YYLTYPE *locp,struct parser_params * parserParams,yyscan_t scanner,char const *s)
{
    fprintf(stderr, "%s\n",s);
}
