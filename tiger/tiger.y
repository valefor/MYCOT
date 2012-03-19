/* Declarations */
%{

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include "tiger_types.h" /* Contains definition of 'symrec' */
int yylex(void);
void yyerror(char const *);
%}

%union{
    char * id;
    double  val;
    typeDef
    symrec  *tptr;
}

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
    KW_ASSIGN
    KW_ARRAY_OF

%token <val>    NUM
%token <id>     ID TYPE_ID
%type  <val>    exp

/*
<<Operator precedence>>:
The relative precedence of different operators is controlled by the order in which they are declared.
*/

%right  '='
%left   '-' '+'
%left   '*' '/'
%left   NEG
%right  '^'
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

typeDec : KW_TYPE TYPE_ID '=' typeDef { /* if typeDef is not defined yet,through out an parse error*/ }
;

typeDef :type 
        |typeBuildin
;

type: TYPE_ID
    | '{' typeFields '}'
    | KW_ARRAY_OF typeDef
;

typeFields  : typeField
    | typeFields ',' typeField
;

typeField   : none
    | ID ':' typeDef
;

typeBuildin: KW_TYPE_INT
           | KW_TYPE_STR
;


varDec  : KW_VAR ID ASSIGN exp
        | KW_VAR ID ':' typeDef ASSIGN exp
;

funcDec : KW_FUNC ID '(' typeFields ')' '=' non_nil_stmts
        | KW_FUNC ID '(' typeFields ')' ':' typeDef '=' non_nil_stmts
;

exp : KW_NIL
    | seqExp
    | arithExp
    | compareExp
    | assignExp
;

non_nil_stmts: stmt
    | stmts term stmt
;

stmts: none
    | non_nil_stmts
;

stmt: KW_IF expr KW_THEN stmts opt_else
    | KW_WHILE expr KW_DO stmts
    | KW_FOR id KW_ASSIGN value KW_TO value KW_DO stmts
    | KW_BREAK
    | KW_LET decs in exps KW_END
    | decs
    | exps
    | '(' stmt ')'
;

opt_else: none
    | KW_ELSE non_nil_stmts
;

exps: none
    | exps term exp
;

exp : none
    | 
;

assignExp   : KW_VAR ID ':' typeId KW_ASSIGN exp
;

terms : term
    | terms ';' { yyerrok; }
;

term : ';' { yyerrok; }
    | '\n'
;

none    :
        {
        $$ = 0;
        }
;

/* End of grammar. */

%%

