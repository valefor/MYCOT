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
 * @Version:{
 *  tiger 3.0   :   ( 2012-03-01 )
 *  tiger 3.1.0 :   ( 2012-05-23 )
 * }
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
 *  Language Specification:
 *    Type definitions have different name space with variable/function,which
 *    means the following declaration is valid:
 *    <var name> <type name>
 *          |       |
 *          v       v
 *    var murmur:murmur;
 *
 *  Hence,variables and functions name share the same name space
 *
 * }
 *
 * @Abbreviations:{
 *      tg      <->     tiger
 *      st      <->     symbol table
 *      lxr     <->     lexer
 *      psr     <->     parser
 *      param   <->     parameter
 *
 * ------------------------------------
 * Keyword ID Name Pair --- KINP
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
#include "id.h"

%}

/* Definitions that'll be used by other modules */
%code provides
{
typedef enum psr_lexState_e psr_lexState_t;

enum psr_lexState_e
{
    E_PSR_LS_VARDEC,
    E_PSR_LS_TYPEDEC,
    E_PSR_LS_TYPEFEILD,
    E_PSR_LS_ARGS,
    E_PSR_LS_FUNCDEC,
    E_PSR_LS_TYPEREF,
    E_PSR_LS_UNDEF
};



typedef struct tg_bindId_s tg_bindId_t;

struct tg_bindId_s{
    tg_id_t id;
    tg_id_t type;
};

typedef struct psr_iTable_s psr_iTable_t;

struct psr_iTable_s
{
    tg_bindId_t **table;
    int pos; // the last id's position
    int cap; // the capacity of table
    psr_iTable_t * prevTbl; // the previous id table
};

typedef struct psr_localScope_s psr_localScope_t;

struct psr_localScope_s
{
    psr_iTable_t * types;
    psr_iTable_t * args;
    psr_iTable_t * vars;
    psr_iTable_t * funcs;
    psr_iTable_t * temp;
    psr_localScope_t * prevScope; // the previous scope
};

typedef struct tg_symbols_s {
    tg_id_t lastId;
    // consts,variables,functions namespace
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
    YYSTYPE *psr_yylval;
    void    *psr_scanner;
    psr_localScope_t * psr_locScp;
    psr_lexState_t  psr_lexState;
    //psr_lexState_t  *psr_lexStateStack;
    tg_symbols_t    *psr_tgVarSymbols;
    tg_symbols_t    *psr_tgArgSymbols;
    tg_symbols_t    *psr_tgTypeSymbols;
    tg_symbols_t    *psr_tgFuncSymbols;
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
    #define yyvsymb pPsrParams->psr_tgVarSymbols
    #define yytsymb pPsrParams->psr_tgTypeSymbols
    #define yylexs pPsrParams->psr_lexState
    #define yylscp pPsrParams->psr_locScp
    int yyparse(psr_params_t * pPsrParams);
    psr_params_t * f_psr_new(void);

    // provides to LEX program
    bool f_tg_symbolExisted(const char * ,tg_symbols_t *,tg_id_t *);
    tg_id_t f_tg_regToSymbolTable(const char *,int,tg_symbols_t *);
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

typedef enum psr_dbgLevel_e psr_dbgLevel_t;
enum psr_dbgLevel_e
{
    E_PSR_DBG_FATAL,    // Top level,unrecoverable fault
    E_PSR_DBG_ERROR,    // Parse error
    E_PSR_DBG_WARN,     // Kindly warning
    E_PSR_DBG_INFO,     // Useful debug information
    E_PSR_DBG_MURMUR    // Some murmurs,ignore it as you like
};

tg_node_t * f_psr_getNodeById(psr_params_t *,tg_id_t);
tg_id_t f_psr_str2Id(psr_params_t *,const char *,int);
char * f_psr_id2str(psr_params_t *,tg_id_t,int);

#define PSR_ROOT_SCP ffffffff0x
#define PSR_LOC_SCP pPsrParams->psr_locScp
#define PSR_LOG_ERROR(errorMsg) f_psr_log(E_PSR_DBG_ERROR,pPsrParams,errorMsg)
#define PSR_LOG_WARNING(errorMsg) f_psr_log(E_PSR_DBG_WARN,pPsrParams,errorMsg)
#define PSR_GET_NODE(id) f_psr_getNodeById(pPsrParams,id)
#define PSR_VAR2ID(str) f_psr_str2Id(pPsrParams,str,ID_VAR)
#define PSR_TYPE2ID(str) f_psr_str2Id(pPsrParams,str,ID_TYPE)
//#define PSR_LSS_PUSH() f_psr_lss_push(pPsrParams)
//#define PSR_LSS_POP() f_psr_lss_pop(pPsrParams)

/* internal macro for temporarily use */
static tg_id_t _f_psr_intern(psr_params_t *,const tg_id_t,int);
static tg_id_t _f_psr_addID2CurrScp(psr_params_t *,const tg_id_t,int);
static bool _f_psr_isIDinCurrScp(psr_localScope_t *,const tg_id_t,int);
static bool _f_psr_idDefined(psr_params_t *,const tg_id_t,int);
static void _f_psr_tmpScp_new(psr_params_t *);
static void _f_psr_tmpScp_rmv(psr_params_t *);
static void _f_psr_locScp_push(psr_params_t *);
static void _f_psr_locScp_pop(psr_params_t *);
static tg_node_t * _f_psr_binCall(psr_params_t*,tg_node_t*,tg_id_t,tg_node_t*);
static tg_node_t * _f_psr_unaCall(psr_params_t*,tg_id_t,tg_node_t*);
static tg_node_t * _f_psr_condExpCheck(psr_params_t *,tg_node_t *);
static void _f_psr_typeConCheck(psr_params_t *,tg_node_t *,
    tg_node_t *,tg_node_t *);
static tg_node_t * _f_psr_genAppend(psr_params_t *,tg_node_t *,tg_node_t *);
static tg_id_t * _f_psr_locScp_whole(psr_params_t *);
static tg_id_t * _f_psr_funcArgsRet(psr_params_t *,tg_node_t *,tg_node_t *);
static tg_node_t * _f_psr_assignCheck(psr_params_t *,tg_id_t,
    tg_node_t *,tg_node_t *);



#define f_psr_intern(e,i) _f_psr_intern(pPsrParams,e,i)
#define f_psr_addID2CurrScp(i,t) _f_psr_addID2CurrScp(pPsrParams,i,t)
#define f_psr_isIDinCurrScp(i,t) _f_psr_isIDinCurrScp(PSR_LOC_SCP,i,t)
#define f_psr_idDefined(i,t) _f_psr_idDefined(pPsrParams,i,t)
#define f_psr_binCall(l,o,r) _f_psr_binCall(pPsrParams,l,o,r)
#define f_psr_unaCall(o,e) _f_psr_unaCall(pPsrParams,o,e)
#define f_psr_extDecAppend(h,t) _f_psr_extDecAppend(pPsrParams,h,t)
#define f_psr_genAppend(h,t) _f_psr_genAppend(pPsrParams,h,t)
#define f_psr_tmpScp_new() _f_psr_tmpScp_new(pPsrParams)
#define f_psr_tmpScp_rmv() _f_psr_tmpScp_rmv(pPsrParams)
#define f_psr_locScp_push() _f_psr_locScp_push(pPsrParams)
#define f_psr_locScp_pop() _f_psr_locScp_pop(pPsrParams)
#define f_psr_condExpCheck(node) _f_psr_condExpCheck(pPsrParams,node)
#define f_psr_typeConCheck(t,n1,n2) _f_psr_typeConCheck(pPsrParams,t,n1,n2)
#define f_psr_locScp_whole() _f_psr_locScp_whole(pPsrParams)
#define f_psr_funcArgsRet(args,ret) _f_psr_funcArgsRet(pPsrParams,args,ret)
#define f_psr_assignCheck(id,type,node) \
        _f_psr_assignCheck(pPsrParams,id,type,node)

/******************************************************************************
 *
 *  Parser Utils:the definitions and operations of local scope for Identifiers
 *
 *****************************************************************************/

static tg_bindId_t *
f_tg_bindId_new(tg_id_t id,tg_id_t type)
{
    tg_bindId_t * pBindId = MEM_ALLOC(tg_bindId_t);
    pBindId->id = id;

    return pBindId;
}

#define PSR_ITBL_SIZE(table) table->pos
static psr_iTable_t *
f_psr_iTable_new(psr_iTable_t * pPrevTbl)
{
    psr_iTable_t * pNewTbl = MEM_ALLOC(psr_iTable_t);
    pNewTbl->pos = 0;
    pNewTbl->cap = 10;
    pNewTbl->table = MEM_ALLOCN(tg_bindId_t*,pNewTbl->cap);
    pNewTbl->prevTbl = pPrevTbl;

    return pNewTbl;
}

static bool
f_psr_iTable_include(const psr_iTable_t * pTbl,tg_id_t tId)
{
    int i;
    for(i = 0; i < pTbl->pos ; i++ )
    {
        if( pTbl->table[i]->id == tId ) return TRUE;
    }

    return FALSE;
}

static tg_bindId_t *
f_psr_iTable_getBindId(const psr_iTable_t * pTbl,tg_id_t tId)
{
    int i;
    for(i = 0; i < pTbl->pos ; i++ )
    {
        if( pTbl->table[i]->id == tId ) return pTbl->table[i];
    }

    return NULL;
}

static void
f_psr_iTable_add(psr_iTable_t * pTbl,tg_bindId_t * tBindId)
{
    if( pTbl->pos == pTbl->cap )
    {
        pTbl->cap = pTbl->cap *2;
        pTbl->table = MEM_REALLOC(tg_bindId_t*,pTbl->table,pTbl->cap);
    }

    pTbl->table[pTbl->pos++] = tBindId;
}

static tg_bindId_t **
f_psr_iTable_idCopy(tg_bindId_t ** pDst,const psr_iTable_t * pSrcTbl)
{
    int i,iCount = PSR_ITBL_SIZE(pSrcTbl);

    if(iCount > 0) {
        for(i = 0; i < iCount ; i++) pDst[i] = pSrcTbl->table[i];
        return pDst;
    }

    return NULL;
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
    KW_INT
    KW_STR
    KW_FUNC
    KW_ARRAY_OF
    KW_OF

/* built-in const */
%token
    KW_LINE
    KW_FILE

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
%token <id>     tIDENTIFIER tSTRING
%token <num>    tNUMBER
%type  <id>     ID
%type  <node>   exp primaryExp postfixExp iterativeExp callativeExp optInitTail
%type  <node>   unaryExp arithExp argExpList
%type  <node>   relationExp equalExp andExp orExp conditionalExp assignExp
%type  <node>   stmts stmt decs dec
%type  <node>   expStmts compoundStmt selectionStmt iterationStmt jumpStmt
%type  <node>   letStmt
%type  <node>   typeDef varDec funcDef typeRef
%type  <node>   varDecInits varDecInit varId varType
%type  <node>   type typeFields typeField funcArgsRet funcRet
%type  <node>   none

%token <id>     tERROR
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
%% /* Grammar rules and actions */

/******************************************************************************
 *
 *  Action Section:
 *    1. If you don't specify an action for a rule,Bison supplies a default:
 *       $$ = $1.
 *
 *****************************************************************************/

/* transform tIDENTIFIER to internal ID */
ID:     tIDENTIFIER 

/* Expressions */
primaryExp: ID
            {
            $$ = ND_NEW_ID($1);
            }
        | tNUMBER
            {
            $$ = ND_NEW_NUM($1);
            }
        | tSTRING
            {
            $$ = ND_NEW_STR($1);
            }
        | '(' exp ')'
            {
            $$ = $2;
            }
;

postfixExp: primaryExp
            {
            if( ND_GET_TYPE($1) == E_NODE_TYPE_ID )
            {
                $<node>1->u1.id = f_psr_intern($<node>1->u1.id,ID_VAR);
                if( !f_psr_idDefined( $<node>1->u1.id,ID_VAR) )
                    $$ = NULL;
            } 
            }
        | iterativeExp
        | callativeExp
;

iterativeExp: ID '[' exp ']' optInitTail
            {
            $$ = ND_NEW_ITER($1,$3,$5);
            //    $1 = f_psr_intern($1,ID_TYPE);
            //    if( !f_psr_idDefined( $1,ID_TYPE) )
            //        $$ = NULL;
            }
;

optInitTail : none
        | KW_OF exp
            {
            $$ = $2;
            }
;

callativeExp: ID '(' argExpList ')'
            {
            $$ = ND_NEW_CALL($1,$3);
            //    $1 = f_psr_intern($1,ID_FUNC);
            //    if( !f_psr_idDefined( $1,ID_FUNC) )
            //        $$ = NULL;
            }
;


argExpList:none 
        | assignExp
        | argExpList ',' assignExp
            {
            $$ = f_psr_genAppend($1,$3);
            }
;

unaryExp: postfixExp
;

arithExp: unaryExp
        | arithExp '+' unaryExp
            {
            $$ = ND_NEW_ARITH($1,'+',$3);
            }
        | arithExp '-' unaryExp
            {
            $$ = ND_NEW_ARITH($1,'-',$3);
            }
        | arithExp '*' unaryExp
            {
            $$ = ND_NEW_ARITH($1,'*',$3);
            }
        | arithExp '/' unaryExp
            {
            $$ = ND_NEW_ARITH($1,'/',$3);
            }
        | '-' unaryExp %prec tUMINUS
            {
            $$ = ND_NEW_ARITH(NULL,'-',$2);
            }
;

relationExp: arithExp
        | relationExp tLEQ arithExp
            {
            $$ = ND_NEW_RELAT($1,tLEQ,$3);
            }
        | relationExp tGEQ arithExp
            {
            $$ = ND_NEW_RELAT($1,tLEQ,$3);
            }
        | relationExp '<' arithExp
            {
            $$ = ND_NEW_RELAT($1,'<',$3);
            }
        | relationExp '>' arithExp
            {
            $$ = ND_NEW_RELAT($1,'>',$3);
            }
;

equalExp: relationExp
        | equalExp tEQ relationExp
            {
            $$ = ND_NEW_RELAT($1,tEQ,$3);
            }
        | equalExp tNEQ relationExp
            {
            $$ = ND_NEW_RELAT($1,tNEQ,$3);
            }
;

andExp  : equalExp
        | andExp '&' equalExp
            {
            $$ = ND_NEW_LOGIC( $1,'&',$3 );
            }
;

orExp   : andExp
        | orExp '|' andExp
            {
            $$ = ND_NEW_LOGIC( $1,'|',$3 );
            }
;

conditionalExp: orExp
        | orExp '?' exp ':' conditionalExp
            {
            $$ = ND_NEW_CONDEXP( $1,$3,$5 );
            }
;

assignExp: conditionalExp
        | unaryExp assignOp unaryExp
            {
            $$ = ND_NEW_ASSIGN( $1,$3 );
            }
;

exp     : assignExp
        | exp ',' assignExp
            {
            $$ = f_psr_genAppend($1,$3);
            }
;

assignOp: tASSIGN
;


/* Delarations */
decs    : dec
        | decs dec
            {
            $$ = f_psr_genAppend($1,$2);
            }
;

dec     : typeDef terms
        | varDec  terms
        | funcDef terms
;

typeDef : KW_TYPE
        ID '=' typeRef
            {
            $<id>2 = f_psr_addID2CurrScp($2,ID_TYPE);
            $$ = ND_NEW_TYPEDEC( $2,$4 );
            }
;

typeRef : type
        | KW_INT
            {
            $$ = ND_NEW_TYPEDEC(PSR_TYPE2ID("int"),NULL);
            }
        | KW_STR
            {
            $$ = ND_NEW_TYPEDEC(PSR_TYPE2ID("string"),NULL);
            }
;

type    : ID
            {
            $<id>1 = f_psr_intern($1,ID_TYPE);
            if( f_psr_idDefined($1,ID_TYPE) ){
            $$ = PSR_GET_NODE($1);
            }
            else $$ = NULL;
            }
        | '{'
            {
            yylexs = E_PSR_LS_TYPEFEILD;
            f_psr_tmpScp_new();
            }
        typeFields '}'
            {
            $$ = $3;
            yylexs = E_PSR_LS_UNDEF;
            f_psr_tmpScp_rmv();
            }
        | KW_ARRAY_OF typeRef
            {
            $$ = ND_NEW_ARYOF($2);
            }
;

typeFields  : typeField
        | typeFields ',' typeField
            {
            $$ = f_psr_genAppend($1,$3);
            }
;

typeField   : none
        |
        ID ':' typeRef
            {
            if( yylexs == E_PSR_LS_ARGS )
                $<id>1 = f_psr_addID2CurrScp($1,ID_ARG);
            else if (  yylexs == E_PSR_LS_TYPEFEILD )
                $<id>1 = f_psr_addID2CurrScp($1,ID_FIELD);
            else yyerror(pPsrParams,"FATAL ERROR OCCURED!");
            $$ = ND_NEW_TFEILD($1,$3);
            }
;

varDec  : KW_VAR varDecInits
            {
            $$ = $2;
            }
;

varDecInits: varDecInit
        | varDecInits ',' varDecInit
            {
            $$ = f_psr_genAppend($1,$3);
        }
;

varDecInit: varId
        | varId assignOp unaryExp
            {
            ND_NEW_ASSIGN( $1,$3 );
            }
;

varId   : ID varType
            {
            $<id>1 = f_psr_addID2CurrScp($1,ID_VAR);
            $$ = ND_NEW_VAR($1,$2);
            }
;

varType :none
        | ':' typeRef
            {
            $$ = $2;
            }

/* Function Delaration & Definition */
funcDef : KW_FUNC ID 
            {
            // The function ID should be in previous scope
            $<id>2 = f_psr_addID2CurrScp($2,ID_FUNC);
            // When enter function body,new scope was opened
            f_psr_locScp_push();
            }
        funcArgsRet '=' compoundStmt
            {
            $$ = ND_NEW_FUNCDEF($2,$4,$6);
            f_psr_locScp_pop();
            }
;

funcArgsRet: '('
            {
            yylexs = E_PSR_LS_ARGS;
            }
        typeFields
            {
            int i = 0;
            for(;i < pPsrParams->psr_locScp->args->cap; i++)
            {
                char * pStr = f_psr_id2str(
                        pPsrParams,
                        pPsrParams->psr_locScp->args->table[i]->id,
                        ID_ARG
                    );
                // move arg to var
                f_psr_addID2CurrScp(pStr,ID_VAR);
            }
            yylexs = E_PSR_LS_UNDEF;
            }
        ')'
        funcRet
            {
            $$ = f_psr_funcArgsRet($3,$6);
            }
;

funcRet : none
        | ':' typeRef
            {
            $$ = $2;
            }
;

/* Statements */
compoundStmt: '(' ')'
            {
            $$ = 0;
            }
        | '(' decs ')'
            {
            $$ = $2;
            }
        | '(' stmts ')'
            {
            $$ = $2;
            }
        | '(' decs stmts ')'
            {
            $$ = $2;
            }
;

stmts   : stmt
        | stmts term stmt
            {
            $$ = f_psr_genAppend($1,$3);
            }
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
            {
            $$ = f_psr_genAppend($1,$3);
            }
;

selectionStmt: KW_IF exp KW_THEN stmt
            {
            $$ = ND_NEW_IF( f_psr_condExpCheck($2),$4,NULL );
            }
        | KW_IF exp KW_THEN stmt KW_ELSE stmt
            {
            $$ = ND_NEW_IF( f_psr_condExpCheck($2),$4,$6 );
            }
;

iterationStmt: KW_WHILE exp KW_DO stmt
            {
            $$ = ND_NEW_WHILE( f_psr_condExpCheck($2),$4 );
            }
        | KW_FOR assignExp KW_TO exp KW_DO stmt
            {
            //f_psr_typeConCheck(ND_NEW_TYPEDEC(PSR_STR2ID("int"),NULL),$2,$4);
            $$ = ND_NEW_FOR( $2,$4,$6 );
            }
;

jumpStmt: KW_BREAK
            {
            $$ = ND_NEW_BREAK( NULL );
            }
;

letStmt : KW_LET
            {
            f_psr_locScp_push();
            }
        decs KW_IN exp KW_END
            {
            $$ = ND_NEW_LET( $3,$5 );
            f_psr_locScp_pop();
            }
;

terms   : term
        | terms ';'
            {
            yyerrok;
            }
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

prog    :
            {
            f_psr_locScp_push();// the top level scope
            }
        extDec
            {
            //$$ = $2;
            f_psr_locScp_pop();
            }
        | prog extDec
            {
            //$$ = f_psr_extDecAppend($1,$2);
            }
;

/* End of grammar. */

%%
/*********************
 * User code section *
 *********************/

/******************************************************************************
 *
 *  Tiger Level Related Funtions
 *
 *****************************************************************************/

#ifdef __cplusplus
#   define ANYARGS ...
#else
#   define ANYARGS
#endif

// KINP --- Keyword ID Name Pair
// !DEPRECATED from version 3.1.0,use gperf to generate keywords facility
static const struct tg_KINP_s {
    tg_id_t id;
    const char * name;
} tTgKINPs[] = {
    { KW_IF,"if" },
    { KW_THEN,"then" },
    { KW_ELSE,"else" },
    { KW_END,"end" },
    { KW_WHILE,"while" },
    { KW_DO,"do" },
    { KW_FOR,"for" },
    { KW_BREAK,"break" },
    { KW_TO,"to" },
    { KW_IN,"in" },
    { KW_LET,"let" },
    { KW_VAR,"var" },
    { KW_NIL,"nil" },
    { KW_TYPE,"type" },
    { KW_INT,"int" },
    { KW_STR,"string" },
    { KW_FUNC,"function" },
    { KW_ARRAY_OF,"array of" },
    { KW_OF,"of" },
    { KW_LINE,"__LINE__" },
    { KW_FILE,"__FILE__" },
    { 0,NULL }
};

// BIF --- Built-In Type Index Table
static const struct tg_KINP_s tTgBITs[] = {
    { 1,"int" },
    { 2,"string" },
    { 0,NULL }
};

// BIF --- Built-In Function Index Table
static const struct tg_BIF_s {
    int (*bif)(ANYARGS);
    const char * name;
} tTgBIFIT[] = {
    { printf,"print" },
    { NULL,NULL}
};

static const char *
f_tg_kw_id2str(tg_id_t id)
{
    const struct tg_KINP_s *tKINP;

    for( tKINP = tTgKINPs; tKINP->id; tKINP++ )
        if ( tKINP->id == id ) return tKINP->name;

    return NULL;
}

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
f_tg_initSymbolTables(tg_symbols_t * pTgSymbols,int pSize)
{
    pTgSymbols->str2idTbl = f_st_initTable(&cl_tg_strHashType,pSize);
    pTgSymbols->id2strTbl = f_st_initTable(&cl_tg_numHashType,pSize);
}



void
f_tg_initVarSymbolTables(tg_symbols_t * pTgSymbols,int pSize)
{
    pTgSymbols->lastId = tLAST_ID;
    f_tg_initSymbolTables(pTgSymbols,pSize);
}

void
f_tg_initArgSymbolTables(tg_symbols_t * pTgSymbols,int pSize)
{
    pTgSymbols->lastId = 0;
    f_tg_initSymbolTables(pTgSymbols,pSize);
}

void
f_tg_initTypeSymbolTables(tg_symbols_t * pTgSymbols,int pSize)
{
    const struct tg_KINP_s *tKINP;

    pTgSymbols->lastId = 0;
    f_tg_initSymbolTables(pTgSymbols,pSize);

    // Add BIT to type symbol table
    for( tKINP = tTgBITs; tKINP->id; tKINP++ )
    {
        f_tg_regToSymbolTable(tKINP->name,ID_TYPE,pTgSymbols);
    }
}

void
f_tg_initFuncSymbolTables(tg_symbols_t * pTgSymbols,int pSize)
{
    const struct tg_BIF_s *tBIFIT;

    pTgSymbols->lastId = 0;
    f_tg_initSymbolTables(pTgSymbols,pSize);

    // Add BIFs to symbols
    for( tBIFIT = tTgBIFIT; tBIFIT->bif; tBIFIT++ )
        f_tg_regToSymbolTable(tBIFIT->name,ID_FUNC,pTgSymbols);
}

void
f_psr_initTopScope(psr_localScope_t *pLocScp)
{
}

bool
f_tg_symbolExisted(
    const char * pYyText,
    tg_symbols_t *pTgSymbols,
    tg_id_t * pId
)
{
    return f_st_lookup(pTgSymbols->str2idTbl,pYyText,pId);
}

tg_id_t
f_tg_regToSymbolTable(const char * pYyText,int iIdType,tg_symbols_t *pTgSymbols)
{
    tg_id_t tId = iIdType | (++pTgSymbols->lastId << ID_SCOPE_SHIFT);

    // f_lxr_arrest will arrest the YYTEXT
    /*
    int iStrLen = strlen(pYyText);
    char * pStr = MEM_CALLOC(0,iStrLen+1);
    MEM_COPY(pStr,pYyText,char,iStrLen);
    pStr[iStrLen] = '\0';
    */

    f_st_add(pTgSymbols->str2idTbl,pYyText,tId);
    f_st_add(pTgSymbols->id2strTbl,tId,pYyText);

    return tId;
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


// NOT IMPLEMENTED YET
tg_node_t *
f_psr_getNodeById(psr_params_t *pPsrParams,tg_id_t id)
{
    return NULL;
}

// NOT IMPLEMENTED YET
tg_id_t
f_psr_str2Id(psr_params_t *pPsrParams,const char * pStr,int iIdType)
{
    tg_id_t *pId;
    tg_symbols_t *pSymbols;
    switch(iIdType)
    {
        case ID_VAR:
            pSymbols= pPsrParams->psr_tgVarSymbols;
            break;
        case ID_ARG:
            pSymbols= pPsrParams->psr_tgArgSymbols;
            break;
        case ID_TYPE:
            pSymbols= pPsrParams->psr_tgTypeSymbols;
            break;
        case ID_FIELD:
            pSymbols= pPsrParams->psr_tgArgSymbols;
            break;
        case ID_FUNC :
            pSymbols= pPsrParams->psr_tgFuncSymbols;
            break;
        default :
            // unreachable!
            return NULL;
    }
    if( f_st_lookup(pSymbols->str2idTbl,pStr,pId) )
        return *pId;
    else
        return NULL;
}

char *
f_psr_id2str(psr_params_t *pPsrParams,tg_id_t tId,int iIdType)
{
    char ** pStr;
    tg_symbols_t *pSymbols;
    switch(iIdType)
    {
        case ID_VAR:
            pSymbols= pPsrParams->psr_tgVarSymbols;
            break;
        case ID_ARG:
            pSymbols= pPsrParams->psr_tgArgSymbols;
            break;
        case ID_TYPE:
            pSymbols= pPsrParams->psr_tgTypeSymbols;
            break;
        case ID_FIELD:
            pSymbols= pPsrParams->psr_tgArgSymbols;
            break;
        case ID_FUNC :
            pSymbols= pPsrParams->psr_tgFuncSymbols;
            break;
        default :
            // unreachable!
            return NULL;
    }
    if( f_st_lookup(pSymbols->str2idTbl,tId,pStr) )
        return *pStr;
    else
        return NULL;

}

/* ^Hidden _Funtion!Don't call it explicitly! */

// transform external identifier to internal ID
static tg_id_t
_f_psr_intern(psr_params_t *pPsrParams,const tg_id_t tExtId,int iIdType)
{
    const char * pExtId = (char *)tExtId;
    tg_id_t tId;
    tg_symbols_t *pSymbols;

    switch(iIdType)
    {
        case ID_VAR:
            pSymbols= pPsrParams->psr_tgVarSymbols;
            break;
        case ID_ARG:
            pSymbols= pPsrParams->psr_tgArgSymbols;
            break;
        case ID_TYPE:
            pSymbols= pPsrParams->psr_tgTypeSymbols;
            break;
        case ID_FIELD:
            pSymbols= pPsrParams->psr_tgArgSymbols;
            break;
        case ID_FUNC :
            pSymbols= pPsrParams->psr_tgFuncSymbols;
            break;
        default :
            // unreachable!
            return NULL;
    }

    if( !f_tg_symbolExisted(pExtId,pSymbols,&tId) )
    {
        return f_tg_regToSymbolTable(pExtId,iIdType,pSymbols);
    }

    return tId;
}

// Add ID in current scope
static tg_id_t
_f_psr_addID2CurrScp(psr_params_t *pPsrParams,const tg_id_t tExtId,int iIdType)
{
    psr_iTable_t *pTable;
    char * errorMsg;
    tg_id_t tId = _f_psr_intern(pPsrParams,tExtId,iIdType);

    switch(iIdType)
    {
        case ID_VAR:
            pTable = PSR_LOC_SCP->vars;
            errorMsg = "Duplicated identifier declaration!";
            break;
        case ID_ARG:
            pTable = PSR_LOC_SCP->args;
            errorMsg = "Duplicated argument declaration!";
            break;
        case ID_TYPE:
            pTable = PSR_LOC_SCP->types;
            errorMsg = "Duplicated type declaration!";
            break;
        case ID_FIELD:
            pTable = PSR_LOC_SCP->temp;
            errorMsg = "Duplicated field identifier!";
            break;
        case ID_FUNC:
            pTable = PSR_LOC_SCP->funcs;
            errorMsg = "Duplicated function declaration!";
            break;
        default:
            break;
    }

    if( _f_psr_isIDinCurrScp(PSR_LOC_SCP,tId,iIdType) )
    {
        yyerror(pPsrParams,errorMsg);
    }
    else
    {
    /*
        if( (ID_VAR == iIdType) &&
            _f_psr_isIDinCurrScp(
                PSR_LOC_SCP,
                f_psr_str2Id(pPsrParams,(char *)tExtId,ID_ARG),
                ID_ARG
            ) 
        ) yyerror(pPsrParams,"The identifier has declared as an argument!");
        else
    */
        f_psr_iTable_add( pTable,f_tg_bindId_new(tId,NULL) );
    }

    return tId;
}

// Is ID in current scope?
static bool
_f_psr_isIDinCurrScp(psr_localScope_t *pLocScp,const tg_id_t tId,int iIdType)
{
    psr_iTable_t *pTable;

    switch(iIdType)
    {
        case ID_VAR:
            pTable = pLocScp->vars;
            break;
        case ID_ARG:
            pTable = pLocScp->args;
            break;
        case ID_TYPE:
            pTable = pLocScp->types;
            break;
        case ID_FIELD:
            pTable = pLocScp->temp;
            break;
        case ID_FUNC:
            pTable = pLocScp->funcs;
            break;
        default:
            break;
    }

    return f_psr_iTable_include(pTable,tId);
}

static bool
_f_psr_idDefined(psr_params_t *pPsrParams,const tg_id_t tId,int iIdType)
{
    psr_localScope_t *pScope = PSR_LOC_SCP;
    char * errorMsg;

    switch(iIdType)
    {
        case ID_VAR:
            errorMsg = "Undeclared identifier declaration!";
            break;
        case ID_ARG:
            errorMsg = "Undeclared argument declaration!";
            break;
        case ID_TYPE:
            errorMsg = "Undefined type declaration!";
            break;
        case ID_FIELD:
            errorMsg = "Undefined field identifier!";
            break;
        case ID_FUNC:
            errorMsg = "Undefined function declaration!";
            break;
        default:
            break;
    }

    while( pScope )
    {
        if( _f_psr_isIDinCurrScp(pScope,tId,iIdType) ) return TRUE;
        pScope = pScope->prevScope;
    }

    yyerror(pPsrParams,errorMsg);
    return FALSE;
}

static void
_f_psr_tmpScp_new(psr_params_t * pPsrParams)
{
    psr_iTable_t * pNewTmpTable = f_psr_iTable_new(PSR_LOC_SCP->temp);

    PSR_LOC_SCP->temp = pNewTmpTable;
}

static void
_f_psr_tmpScp_rmv(psr_params_t * pPsrParams)
{
    psr_iTable_t * pTmpTable = NULL;

    if( PSR_LOC_SCP && PSR_LOC_SCP->temp )
    {
        if( PSR_LOC_SCP->temp->prevTbl )
        {
            pTmpTable = PSR_LOC_SCP->temp->prevTbl;
        }
        MEM_FREE(PSR_LOC_SCP->temp);
        PSR_LOC_SCP->temp = pTmpTable;
    }
}

static void
_f_psr_locScp_push(psr_params_t * pPsrParams)
{
    psr_localScope_t * pNewLocScp = MEM_ALLOC(psr_localScope_t);

    pNewLocScp->prevScope = PSR_LOC_SCP;
    pNewLocScp->types= f_psr_iTable_new(NULL);
    pNewLocScp->args = f_psr_iTable_new(NULL);
    pNewLocScp->vars = f_psr_iTable_new(NULL);
    pNewLocScp->temp = f_psr_iTable_new(NULL);
    pNewLocScp->funcs= f_psr_iTable_new(NULL);

    PSR_LOC_SCP = pNewLocScp;
}

static void
_f_psr_locScp_pop(psr_params_t * pPsrParams)
{
    psr_localScope_t * pLocScp = PSR_LOC_SCP->prevScope;
    MEM_FREE(PSR_LOC_SCP->types);
    MEM_FREE(PSR_LOC_SCP->args);
    MEM_FREE(PSR_LOC_SCP->vars);
    MEM_FREE(PSR_LOC_SCP);

    PSR_LOC_SCP = pLocScp;
}

static tg_id_t *
_f_psr_locScp_whole(psr_params_t * pPsrParams)
{
    int iCount = PSR_ITBL_SIZE(PSR_LOC_SCP->types) +
                 PSR_ITBL_SIZE(PSR_LOC_SCP->args) +
                 PSR_ITBL_SIZE(PSR_LOC_SCP->temp) +
                 PSR_ITBL_SIZE(PSR_LOC_SCP->funcs) +
                 PSR_ITBL_SIZE(PSR_LOC_SCP->vars);
    tg_id_t * pBuf;

    if(iCount < 0) return 0;

    pBuf = MEM_ALLOCN(tg_id_t,iCount + 1);

    f_psr_iTable_idCopy(pBuf,PSR_LOC_SCP->types);
    f_psr_iTable_idCopy(pBuf,PSR_LOC_SCP->args);
    f_psr_iTable_idCopy(pBuf,PSR_LOC_SCP->vars);
    f_psr_iTable_idCopy(pBuf,PSR_LOC_SCP->funcs);
    f_psr_iTable_idCopy(pBuf,PSR_LOC_SCP->temp);

    // set buf size
    pBuf[0] = iCount;
    return pBuf;
}

// NOT IMPLEMENTED YET
static tg_id_t *
_f_psr_funcArgsRet(psr_params_t *pPsrParams,tg_node_t * args,tg_node_t * ret)
{
    return NULL;
}
// NOT IMPLEMENTED YET
static tg_node_t *
_f_psr_extDecAppend(psr_params_t *pPsrParams,tg_node_t * head,tg_node_t * tail)
{
    tg_node_t * h = head,*nd;

    if(NULL==tail) return head;

    if(NULL==h) return tail;
    return NULL;
}

// NOT IMPLEMENTED YET
static tg_node_t *
_f_psr_genAppend(psr_params_t *pPsrParams,tg_node_t * head,tg_node_t * tail)
{
    tg_node_t * h = head,*nd;

    if(NULL==tail) return head;

    if(NULL==h) return tail;
    return NULL;
}

// Condition expression check
static tg_node_t *
_f_psr_condExpCheck(psr_params_t *pPsrParams,tg_node_t * pNode)
{
    if(NULL == pNode) return 0;

    switch( ND_GET_TYPE(pNode) ){

        case E_NODE_TYPE_STR:
            PSR_LOG_WARNING("Condition can't be a string!");

        default:
            break;
    }

    return pNode;

}

static tg_node_t *
_f_psr_binCall(
    psr_params_t *pPsrParams,
    tg_node_t *pLeft,
    tg_id_t tOp,
    tg_node_t *pRight
)
{
    return NULL;
}

/*
static tg_node_t *
_f_psr_unaCall(
    psr_params_t *pPsrParams,
    tg_node_t *pExp,
    tg_id_t tOp
)
{
    return NULL;
}
*/

static void
_f_psr_typeConCheck(
    psr_params_t *pPsrParams,
    tg_node_t *pType,
    tg_node_t *pNode1,
    tg_node_t *pNode2)
{
    if( ND_GET_TYPE(pNode1) != ND_GET_TYPE(pNode2) )
    {
        switch( ND_GET_TYPE(pNode1) ) {
            case E_NODE_TYPE_STR:
            case E_NODE_TYPE_NUM:
                PSR_LOG_ERROR("RVaule & LValue Type unmatch!");

            default:
                break;
        }
    }
}

// NOT IMPLEMENTED YET
static tg_node_t *
_f_psr_assignCheck(
    psr_params_t *pPsrParams,
    tg_id_t tId,
    tg_node_t *pType,
    tg_node_t *pNode)
{
    return NULL;
}
/* $Hidden _Funtion!Don't call it explicitly! */

/******************************************************************************
 *
 *  Parser initiation Funtions
 *
 *****************************************************************************/

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

    tg_symbols_t * pTgVarSymbols = MEM_ALLOC(tg_symbols_t);
    tg_symbols_t * pTgArgSymbols = MEM_ALLOC(tg_symbols_t);
    tg_symbols_t * pTgTypeSymbols = MEM_ALLOC(tg_symbols_t);
    tg_symbols_t * pTgFuncSymbols = MEM_ALLOC(tg_symbols_t);

    //psr_localScope_t * pLocalScope = MEM_ALLOC(psr_localScope_t);
    psr_localScope_t * pLocalScope = NULL;

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


    f_tg_initVarSymbolTables(pTgVarSymbols,1000);
    f_tg_initArgSymbolTables(pTgArgSymbols,10);
    f_tg_initTypeSymbolTables(pTgTypeSymbols,100);
    f_tg_initFuncSymbolTables(pTgFuncSymbols,100);

    f_psr_initTopScope(pLocalScope);

    /*
    */

    pPsrParams->psr_srcFileName = 0;
    pPsrParams->psr_yylval = pYyVal;
    pPsrParams->psr_yylloc = pYyLoc;
    pPsrParams->psr_locScp = pLocalScope;
    pPsrParams->psr_lexState = E_PSR_LS_UNDEF;
    pPsrParams->psr_tgVarSymbols  = pTgVarSymbols;
    pPsrParams->psr_tgArgSymbols  = pTgArgSymbols;
    pPsrParams->psr_tgTypeSymbols = pTgTypeSymbols;
    pPsrParams->psr_tgFuncSymbols = pTgFuncSymbols;
}

psr_params_t *
f_psr_new(void)
{
    psr_params_t *pPsrParams = MEM_ALLOC(psr_params_t);

    f_psr_initPsrParams(pPsrParams);
    return pPsrParams;
}

void
f_psr_log(
    psr_dbgLevel_t pDbgLevel,
    psr_params_t * pPsrParams,
    char const * errorMsg
)
{
    // Implement this funtion fully later
    yyerror(pPsrParams,errorMsg);
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

#include "keywords.c"

