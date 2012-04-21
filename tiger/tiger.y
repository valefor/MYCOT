/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Tiger's Grammar $\ }
 * 
 * @Author:{
 *  Name  : Adrian Hu
 *  Email : adrain.f.tepes@gmail.com
 * }
 * 
 *
 * @Progress:{
 * Phase 1 ->
 *  1. No constant
 *  2. No global var
 * 
 * }
 * 
 * @Module:{
 *  LocalMoudle:parser
 *  AssocMoudle:lexer
 * }
 * 
 * @CGL:{
 *  Obey
 * }
 * 
 * @Doc:{
 * 
 * <<The CGL(Coding Guide Line)>>
 * All the naming should be as symbolic as possible,then as laconic as possible
 * 
 * The naming out of this program's scope will not be constrained,e.g the yacc
 * or lex built-in declaration & macro.
 * 
 * Use all uppercase letters words carefully.Don't mix them up with MARCO 
 *
 *  1. Nameing:
 *    #1 Declaration:
 *      $1. <scopeSpec><[Module_]><Name> : 
 *        %1. <scopeSpec> ~~~ scope specifers:
 *          &1. g_  : global variable
 *          &2. v_  : local variable
 *          &3. pm  : parameter.
 *          &4. cl_ : local const,e.g static const or static
 *          &5. cg_ : global const
 *
 *        %2. [<Module_>] ~~~ module name is optional
 *
 *        %3. xxx_<Name>:the <Name> is recommended to be written in camelStyle,
 *              underscode_style is not recommended
 *
 *      $2. <typeSpec><Name>:Sometimes a local variable "v_murMurMur" isn't fit
 *            your style,there are so may local variables,this rule use type
 *            specifer to make variables more accurate.
 *        %1. <typeSpec>:
 *          &1. i : integer
 *          &2. b : boolean
 *          &3. s : string
 *          &4. c : char
 *          &5. p : pointer
 *          &6. t : user defined type
 *
 *        %2. <Name> : follow rule:[$1%3],then what ever...
 *
 *      $3. xxx_<Name>_<Typedef_tag> :the tailed <TypeDef_tag>('_t') is allowed 
 *
 *      $4. temporary variables ain't force to follow above rules,e.g i,j, .etc
 *
 *    #2 Definition:
 *      $1. MARCO : macro definitions with uppercase letters
 *      $2. f_<Module>_<funcName> : local variables 
 *      $3. s_<structName> : struct
 *
 *  2. Consistency:
 *
 *  3. Comments:
 *    #1. "//" Only use this for single line comment.
 *    #2. the function header comments are not mandatory,but if it'll be greate
 *      if it has,it will help others understand the function more quickly.
 *
 *  x. Abbreviations:
 *      lexer       <->     lxr
 *      parser      <->     psr
 *      parameter   <->     param
 *
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/

/* Declarations */
%{

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>


%}

%code provides
{
    typedef struct YYLTYPE
    {
      int first_line;
      int first_column;
      int last_line;
      int last_column;
    } YYLTYPE;

    struct s_psr_params
    {
        char *psr_tigerSrcFile;

        YYSTYPE *psr_yylval;

        void * psr_scanner;
    };

}

%debug
%pure_parser
%parse-param    { struct s_psr_params *pl_psrParams }
%parse-param    { void * scanner }
%lex-param      { struct s_psr_params *pl_psrParams }
%lex-param      { void * scanner }

%union{
    char * id;
    int val;
}

%{
#include "tiger_lexer.h"
#include "config.h"
#include "utils.h"

static int yylex(YYSTYPE *,struct s_psr_params *, yyscan_t );
void yyerror (struct s_psr_params * ,yyscan_t , char const *s);
static void f_psr_initLexer(struct s_psr_params *,void **);
%}

%code provides
{
    struct s_psr_params * f_psr_new(void);
}

%initial-action
{
    // Initiate scanner params
    f_psr_initLexer(pl_psrParams,&scanner);

    // Enable yydebug
#if YACC_DEBUG > 0
    yydebug = 1;
#endif

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

%left   '|' '&'
%nonassoc tEQ tNEQ '>' tGEQ '<' tLEQ
%right  tASSIGN
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
        | orExp '?' exp ':' conditionalExp
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
        | decs dec
;

dec
        : typeDec terms
        | varDec terms
        | funcDef terms
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
        | stmts term stmt
;

stmt
        : expStmts
        | compoundStmt
        | selectionStmt
        | iterationStmt
        | jumpStmt
        | letStmt
;

expStmts
        : exp
        | expStmts term exp
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

/*********************
 * User code section *
 *********************/
extern int tiger_yylex(void *pl_psrParams, void * scanner);

// Redefine yylex
#if YYPURE
static int 
yylex(YYSTYPE *pl_lval,struct s_psr_params *pl_psrParams,yyscan_t scanner)
#else
static int 
yylex(void *p)
#endif
{
    struct s_psr_params *vl_psrParams = (struct s_psr_params*)pl_psrParams;
    int t;
#if YYPURE
    vl_psrParams->psr_yylval = pl_lval;
#endif
    t = tiger_yylex(vl_psrParams,scanner);

    return t;
}

static void 
f_psr_initLexer(struct s_psr_params *pl_psrParams,yyscan_t * scanner)
{
    FILE * ptr_srcFile = fopen( pl_psrParams->psr_tigerSrcFile,"r" );
    YYSTYPE * ptr_yyVal = MEM_ALLOC(YYSTYPE);
    YYLTYPE * ptr_yyLoc = MEM_ALLOC(YYLTYPE);

    ptr_yyVal->val = 0;
    ptr_yyLoc->first_line = 0;
    ptr_yyLoc->first_column = 0;
    ptr_yyLoc->last_line = 0;
    ptr_yyLoc->last_column = 0;

    yylex_init(scanner);

    yyset_in(ptr_srcFile,*scanner);

    //yylex_destroy(scanner);
}

static void 
f_psr_initPsrParams(struct s_psr_params *pl_psrParams)
{
    pl_psrParams->psr_tigerSrcFile = 0;
}

struct s_psr_params *
f_psr_new(void)
{
    struct s_psr_params *ptr_psrParams;

    ptr_psrParams = malloc(sizeof(struct s_psr_params));
    f_psr_initPsrParams(ptr_psrParams);
    return ptr_psrParams;
}

void 
yyerror(struct s_psr_params * pl_psrParams,yyscan_t scanner,char const *s)
{
    fprintf(stderr, "%s\n",s);
}
