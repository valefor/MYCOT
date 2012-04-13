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
    KW_TYPE
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
%token <id>     IDENTIFIER
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

/* Expressions */
primaryExp
        : IDENTIFIER
        | NUMBER
        | STRING
        | '(' exp ')'
;

postfixExp
        : primaryExp
        | postfixExp '[' exp ']' 
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

*/

/* Delarations */
decs: none
    | dec
    | decs terms dec
;

dec : typeDec
    | varDec
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

typeField   :  none
            | IDENTIFIER ':' typeDef
;

varDec  : KW_VAR IDENTIFIER ':' typeDef
        | KW_VAR IDENTIFIER ':' typeDef assignOp assignExp
;

/* Function Delaration & Definition */

funcDef : KW_FUNC IDENTIFIER '(' typeFields ')' '=' compoundStmt
        | KW_FUNC IDENTIFIER '(' typeFields ')' ':' typeDef '=' compoundStmt
;

/* Statements */
compoundStmt
        : decs
        |
;

nonNilStmts : stmt
            | nonNilStmts term stmt
;

stmts: none
    | nonNilStmts
;

stmt: KW_IF compExp KW_THEN stmts optElse
    | KW_WHILE compExp KW_DO stmts
    | KW_FOR IDENTIFIER tASSIGN value KW_TO value KW_DO stmts
    | KW_BREAK
    | KW_LET decs in stmts KW_END
    | dec
    | exp
    | '(' stmt ')'
;

optElse: none
    | KW_ELSE nonNilStmts
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
prog: none
    | extDec 
    | prog extDec
;

extDec
    : funcDef
    | decs
;

/* End of grammar. */

%%

