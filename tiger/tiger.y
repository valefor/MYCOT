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
int yylex(void);
void yyerror(char const *);
%}

%union{
    char * id;
    int val;
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
    KW_LET
    KW_VAR
    KW_NIL
    KW_TYPE_INT
    KW_TYPE_STR
    KW_FUNC
    KW_ARRAY_OF

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
%token <val>    NUM
%token <id>     ID
%type  <val>    exp

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

prog: none
    | stmts
;

decs: none
    | dec
    | decs terms dec
;

dec : typeDec
    | varDec
    | funcDec
;

typeDec : KW_TYPE ID '=' typeDef { /* if typeDef is not defined yet,through out an parse error*/ }
;

typeDef : type 
        | KW_TYPE_INT
        | KW_TYPE_STR
;

type: ID
    | '{' typeFields '}'
    | KW_ARRAY_OF typeDef
;

typeFields  : typeField
            | typeFields ',' typeField
;

typeField   :  none
            | ID ':' typeDef
;

varDec  : KW_VAR ID ':' typeDef
        | KW_VAR ID ':' typeDef tASSIGN exp
;

funcDec : KW_FUNC ID '(' typeFields ')' '=' nonNilStmts
        | KW_FUNC ID '(' typeFields ')' ':' typeDef '=' nonNilStmts
;

nonNilStmts : stmt
            | nonNilStmts term stmt
;

stmts: none
    | nonNilStmts
;

stmt: KW_IF compExp KW_THEN stmts optElse
    | KW_WHILE compExp KW_DO stmts
    | KW_FOR ID tASSIGN value KW_TO value KW_DO stmts
    | KW_BREAK
    | KW_LET decs in stmts KW_END
    | dec
    | exp
    | '(' stmt ')'
;

optElse: none
    | KW_ELSE nonNilStmts
;

exp : primary
    | assignExp
    | compExp
    | arithExp
    | call
;

assignExp: ID tASSIGN exp
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

arithExp: exp '+' exp
        | exp '-' exp
        | exp '*' exp
        | exp '/' exp
        | '-' exp %prec tUMINUS
        | '(' exp ')'
;

primary : KW_NIL
        | number
        | string
        | ID
;

call: ID "(" argsX ')'
;

argsX :none
    | args
;

args: arg
    | args ',' arg
;

arg : primary
;

number  : tINT
;

string  : tSTR
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

/* End of grammar. */

%%

