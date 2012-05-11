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
 *  3. No gc
 * 
 * }
 * 
 * @Module:{
 *  ``ParenModule:( tiger )
 *  &&LocalModule:( parser )
 *  --AssocModule:( lexer )
 *  ''ChildModule:( N/A )
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
 *
 *  x. Abbreviations:
 *      tg      <->     tiger
 *      st      <->     symbol table
 *      lxr     <->     lexer
 *      psr     <->     parser
 *      param   <->     parameter
 *
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/

/* Declarations */
%{

#include <math.h>
#include <string.h>
#include "tiger.h"
#include "st.h"
#include "node.h"

%}

/* Definitions that'll be used by other modules */
%code provides
{
typedef struct psr_iTable_s psr_iTable_t;

struct psr_iTable_s
{
    tg_id_t * table;
    int pos; // the last id's position
    int cap; // the capacity of table
    psr_iTable_t * prevTbl; // the previous id table
};

typedef struct psr_localScope_s psr_localScope_t;

struct psr_localScope_s
{
    psr_iTable_t * typeDefs;
    psr_iTable_t * args;
    psr_iTable_t * vars;
    psr_localScope_t * prevScope; // the previous scope
};

typedef struct tg_symbols_s {
    tg_id_t lastId;
    st_table_t * str2idTbl;
    st_table_t * id2strTbl;
} tg_symbols_t;

typedef struct YYLTYPE
{
    int firstLine;
    int firstColumn;
    int lastLine;
    int lastColumn;
    char *currLineBuff;
    int buffSize;
} YYLTYPE;

struct psr_params_s
{
    /* File related parameters,etc. line,column number,file name... */
    char *psr_srcFileName;
    YYLTYPE *psr_yylloc;

    /* Parser&Lexer dedicated parameters */
    void * psr_scanner;
    psr_localScope_t * psr_locScp;
    YYSTYPE *psr_yylval;
    tg_symbols_t *psr_tgSymbols;
};

typedef struct psr_params_s psr_params_t;

}



/* Bison Options */
%debug
%pure_parser
%parse-param    { psr_params_t *pPsrParams }
%lex-param      { psr_params_t *pPsrParams }

/* YYSTYPE */
%union{
    tg_id_t id;
    tg_node_t * node;
    tg_value_t value;
    int num;
}

%{
#include "tiger_lexer.h"
static int yylex(YYSTYPE *,psr_params_t *);
void yyerror (psr_params_t * ,char const *s);
static void f_psr_initLexer(psr_params_t *);
%}

/* External function declaration */
%code provides
{
    int yyparse(psr_params_t * pPsrParams);
    psr_params_t * f_psr_new(void);
}

%initial-action
{
    // Initiate scanner params
    f_psr_initLexer(pPsrParams);

    // Enable yydebug
#if TG_YACC_DEBUG > 0
    yydebug = 1;
#endif

}

/* Local Definitions */
%code {
tg_node_t * f_psr_getNodeById(psr_params_t *,tg_id_t);
#define PSR_LOC_SCP pPsrParams->psr_locScp
#define F_PSR_GET_NODE(id) f_psr_getNodeById(pPsrParams,id)

/******************************************************************************
 *
 *  Parser Utils:the definitions and operations of local scope for Identifiers
 *
 *****************************************************************************/

static psr_iTable_t *
f_psr_iTable_new(psr_iTable_t * pPrevTbl)
{
    psr_iTable_t * pNewTbl = MEM_ALLOC(psr_iTable_t);
    pNewTbl->pos = 0;
    pNewTbl->cap = 10;
    pNewTbl->table = MEM_ALLOCN(tg_id_t,pNewTbl->cap);
    pNewTbl->prevTbl = pPrevTbl;
    
    return pNewTbl;
} 

static bool
f_psr_iTable_include(const psr_iTable_t * pTbl,tg_id_t tId)
{
    int i;
    for(i = 0; i < pTbl->pos ; i++ )
    {
        if( pTbl->table[i] == tId ) return TRUE;
    }

    return FALSE;
}

static void
f_psr_iTable_add(psr_iTable_t * pTbl,tg_id_t tId)
{
    if( pTbl->pos == pTbl->cap )
    {
        pTbl->cap = pTbl->cap *2;
        pTbl->table = MEM_REALLOC(tg_id_t,pTbl->table,pTbl->cap);
    }

    pTbl->table[pTbl->pos++] = tId;
}

static void 
f_psr_locScp_push(struct psr_params_s * pPsrParams)
{
    psr_localScope_t * pNewLocScp = MEM_ALLOC(psr_localScope_t);

    pNewLocScp->prevScope = PSR_LOC_SCP;
    pNewLocScp->typeDefs = f_psr_iTable_new(NULL);
    pNewLocScp->args = f_psr_iTable_new(NULL);
    pNewLocScp->vars = f_psr_iTable_new(NULL);

    PSR_LOC_SCP = pNewLocScp;
}

static void 
f_psr_locScp_pop(psr_params_t * pPsrParams)
{
    psr_localScope_t * pLocScp = PSR_LOC_SCP->prevScope; 
    MEM_FREE(PSR_LOC_SCP->typeDefs);
    MEM_FREE(PSR_LOC_SCP->args);
    MEM_FREE(PSR_LOC_SCP->vars);
    MEM_FREE(PSR_LOC_SCP);

    PSR_LOC_SCP = pLocScp;
}

}// End of %code

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
%token <id>     IDENTIFIER tSTRING
%token <num>    tNUMBER
%type  <node>   exp primaryExp postfixExp unaryExp arithExp argExpList
%type  <node>   relationExp equalExp andExp orExp conditionalExp assignExp
%type  <node>   none

// Last ID,Don't use it in this file
%token <id>     tLAST_ID
/*
 * Precedence Table
 *
 * <<Operator precedence>>:
 * The relative precedence of different operators is controlled by the order
 * in which they are declared.The earliest declaration,the lowest precedence
 *
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

/******************************************************************************
 *
 *  Action Section:
 *    1. If you don't specify an action for a rule,Bison supplies a default:
 *       $$ = $1.
 *
 *****************************************************************************/

/* Expressions */
primaryExp: IDENTIFIER { $$ = F_PSR_GET_NODE($1); }
        | tNUMBER   { $$ = F_ND_NEW_NUM($1); }
        | tSTRING   { $$ = F_ND_NEW_STR($1); }
        | '(' exp ')' { $$ = $2; }
;

postfixExp: primaryExp
        | postfixExp '[' exp ']' 
        | postfixExp '[' exp ']' KW_OF exp
        | postfixExp '(' ')' 
        | postfixExp '(' argExpList ')'
;

argExpList: assignExp
        | argExpList ',' assignExp
;

unaryExp: postfixExp
;

arithExp: unaryExp
        | arithExp '+' unaryExp
        | arithExp '-' unaryExp
        | arithExp '*' unaryExp
        | arithExp '/' unaryExp
        | '-' unaryExp %prec tUMINUS { $$ = $2; }
;

relationExp: arithExp
        | relationExp tLEQ arithExp
        | relationExp tGEQ arithExp
        | relationExp '<' arithExp
        | relationExp '>' arithExp
;

equalExp: relationExp
        | equalExp tEQ relationExp
        | equalExp tNEQ relationExp
;

andExp  : equalExp
        | andExp '&' equalExp
;

orExp   : andExp
        | orExp '|' andExp
;

conditionalExp: orExp
        | orExp '?' exp ':' conditionalExp
;

assignExp: conditionalExp
        | unaryExp assignOp unaryExp
;

exp     : assignExp
        | exp ',' assignExp 
;

assignOp: tASSIGN
;


/* Delarations */
decs    : dec
        | decs dec
;

dec     : typeDec terms
        | varDec terms
        | funcDef terms
;

typeDec : KW_TYPE IDENTIFIER '=' typeDef { /* if typeDef is not defined yet,through out an parse error*/ }
;

typeDef : type 
        | KW_TYPE_INT
        | KW_TYPE_STR
;

type    : IDENTIFIER
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
compoundStmt: '(' ')'
        | '(' decs ')' 
        | '(' stmts ')' 
        | '(' decs stmts ')' 
;

stmts   : stmt
        | stmts term stmt
;

stmt    : expStmts
        | compoundStmt
        | selectionStmt
        | iterationStmt
        | jumpStmt
        | letStmt
;

expStmts: exp
        | expStmts term exp
;



selectionStmt: KW_IF exp KW_THEN stmt
        | KW_IF exp KW_THEN stmt KW_ELSE stmt
;

iterationStmt: KW_WHILE exp KW_DO stmt
        | KW_FOR IDENTIFIER tASSIGN exp KW_TO exp KW_DO stmt
;

jumpStmt: KW_BREAK
;

letStmt: KW_LET decs KW_IN stmt KW_END
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
extDec  : dec
        | stmt
;

prog    : extDec 
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

/******************************************************************************
 *
 *  Tiger Level Related Funtions
 *
 *****************************************************************************/
#define f_tg_strCmp strcmp
static const st_hashType_t cl_tg_strHashType = { 
    f_tg_strCmp,
    f_tg_strHash
};

static const st_hashType_t cl_tg_numHashType = { 
    f_st_numCmp,
    f_st_numHash
};

void
f_tg_initSymbolTables()
{
    //gl_tigerSymbols.idTbl = f_st_initTable(&cl_tg_hashType,1000);
}

/******************************************************************************
 *
 *  Parser Level Related Funtions
 *
 *****************************************************************************/
extern int f_tg_yylex(void *pPsrParams,yyscan_t);

// Redefine yylex
#if YYPURE
static int 
yylex(YYSTYPE *pl_lval,psr_params_t *pPsrParams)
#else
static int 
yylex(void *p)
#endif
{
    psr_params_t *vl_psrParams = (psr_params_t*)pPsrParams;
    int t;
#if YYPURE
    vl_psrParams->psr_yylval = pl_lval;
#endif
    t = f_tg_yylex(vl_psrParams,vl_psrParams->psr_scanner);

    return t;
}

tg_node_t *
f_psr_getNodeById(psr_params_t *pPsrParams,tg_id_t id)
{
    return NULL;
}

static void 
f_psr_initLexer(psr_params_t *pPsrParams)
{
    FILE * pSrcFile = fopen( pPsrParams->psr_srcFileName,"r" );

    yylex_init(&(pPsrParams->psr_scanner));

    yyset_in(pSrcFile,pPsrParams->psr_scanner);

    //yylex_destroy(pPsrParams->psr_scanner);
}

static void 
f_psr_initPsrParams(psr_params_t *pPsrParams)
{
    YYSTYPE * pYyVal = MEM_ALLOC(YYSTYPE);
    YYLTYPE * pYyLoc = MEM_ALLOC(YYLTYPE);
    tg_symbols_t * pTgSymbols = MEM_ALLOC(tg_symbols_t);

    pYyVal->id = 0;
    pYyVal->value = 0;
    pYyVal->node = MEM_ALLOC(tg_node_t);
    pYyVal->num = 0;

    pYyLoc->firstLine = 1;
    pYyLoc->firstColumn = 0;
    pYyLoc->lastLine = 1;
    pYyLoc->lastColumn = 0;
    pYyLoc->currLineBuff = NULL;
    pYyLoc->buffSize = 0;

    pTgSymbols->lastId = tLAST_ID;
    pTgSymbols->str2idTbl = f_st_initTable(&cl_tg_strHashType,1000);
    pTgSymbols->id2strTbl = f_st_initTable(&cl_tg_numHashType,1000);

    pPsrParams->psr_srcFileName = 0;
    pPsrParams->psr_yylval = pYyVal;
    pPsrParams->psr_yylloc = pYyLoc;
    pPsrParams->psr_tgSymbols = pTgSymbols;
}

psr_params_t *
f_psr_new(void)
{
    psr_params_t *pPsrParams = MEM_ALLOC(psr_params_t);

    f_psr_initPsrParams(pPsrParams);
    return pPsrParams;
}

void 
yyerror(psr_params_t * pPsrParams,char const * errorMsg)
{
    fprintf(stderr, "%s:%d\t%s\n",
        pPsrParams->psr_srcFileName,
        pPsrParams->psr_yylloc->lastLine,
        pPsrParams->psr_yylloc->currLineBuff
    );
    fprintf(stderr, "%s:%d\t%s\n",
        pPsrParams->psr_srcFileName,
        pPsrParams->psr_yylloc->lastLine,
        errorMsg
    );
}


