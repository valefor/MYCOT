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
    double  val;
    typeDef
    symrec  *tptr;
}

%token <val>    NUM
%token <tptr>   VAR FNCT
%type  <val>    exp

%right  '='
%left   '-' '+'
%left   '*' '/'
%left   NEG
%right  '^'
%start prog
%% /* Grammar rules and actions follow */

prog:
    | decs
;

decs: 
    | dec
    | decs dec
;

dec : typeDec
    | varDec
    | funcDec
;

typeDec : KW_TYPE typeId '=' type
;

type: typeId
    | '{' typeFields '}'
    | KW_ARRAY_OF typeId
;

typeId  : INT
    | STR
    | ID
;

typeFields  : typeField
    | typeFields ',' typeField
;

typeField   :
    | ID ':' typeId
;

varDec  : KW_VAR ID ASSIGN exp
        | KW_VAR ID ':' typeId ASSIGN exp
;

funcDec : KW_FUNC ID '(' typeFields ')' '=' exp
        | KW_FUNC ID '(' typeFields ')' ':' typeId '=' exp
;

exp : KW_NIL
    | seqExp
    | constExp
    | refExp
    | arithExp
    | compareExp
    | boolExp
    | assignExp
    | controlExp
;

assignExp   : KW_VAR ID ':' typeId KW_ASSIGN exp
;

/* End of grammar. */

%%

