/* Declarations */
%{

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include "calc.h" /* Contains definition of 'symrec' */
int yylex(void);
void yyerror(char const *);
%}

%union{
    double  val;
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

%% /* Grammar rules and actions follow */

input: /* empty */
     | input line
;

line:   '\n'
    | exp '\n'      { printf ("\t%.10g\n", $1); }
    | error '\n'    { yyerrok; }
;

exp:    NUM             { $$ = $1; }
    |   VAR             { $$ = $1 -> value.var; }
    |   VAR '=' exp     { $$ = $3; $1 -> value.var = $3; }
    |   FNCT '(' exp ')'{ $$ = (*($1->value.fnctptr))($3); }
    |   exp '+' exp     { $$ = $1 + $3; }
    |   exp '-' exp     { $$ = $1 - $3; }
    |   exp '*' exp     { $$ = $1 * $3; }
    |   exp '/' exp     { $$ = $1 / $3; }
    |   '-' exp %prec NEG{ $$ = -$2; }
    |   exp '^' exp     { $$ = pow($1,$3); }
    |   '(' exp ')'     { $$ = $2; }
;
/* End of grammar. */

%%

symrec * sym_table;

void init_table(void)
{
    int i;
    symrec * ptr;
    for(i = 0; arith_fncts[i].fname != 0; i++)
    {
        ptr = putsym(arith_fncts[i].fname,FNCT);
        ptr->value.fnctptr = arith_fncts[i].fnct;
    }
}

symrec * putsym(char const * sym_name,int sym_type)
{
    symrec * ptr;
    //printf("insert:[%s] into symbol table\n",sym_name);
    ptr = (symrec *)malloc(sizeof(symrec));
    ptr->name = (char *)malloc(strlen(sym_name) + 1);
    strcpy(ptr->name,sym_name);
    ptr->type = sym_type;
    ptr->value.var = 0;
    ptr->next = (struct symrec *) sym_table;
    sym_table = ptr;
    return ptr;
}

symrec * getsym(char const * sym_name)
{
    symrec * ptr;
    //printf("get:[%s] from symbol table\n",sym_name);
    for( ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next )
    {
        if(strcmp(ptr->name,sym_name) == 0)
            return ptr;
    }
    return 0;
}

int yylex(void)
{
    int c;

    /* skip white space. */
    while((c = getchar()) == ' ' || c == '\t');

    /* Return EOF */
    if( c== EOF )
    return 0;

    /* Process numbers */
    if( c == '.' || isdigit(c) )
    {
        ungetc(c, stdin);
        scanf("%lf",&yylval);
        return NUM;
    }

    /* Char starts an identifer => read the name. */
    if(isalpha(c))
    {
        symrec * s;
        static char * symbuf = 0;
        static int length = 0;
        int i;
        /* Initially make the buffer long enough for a 40-character symbol name*/
        if(length ==0 )
            length = 40,symbuf = (char *) malloc (length + 1);
        i = 0;
        do
        {
            /* If buffer is full make it bugger */
            if(i==length)
            {
                length *=2;
                symbuf = (char *)realloc(symbuf,length + 1);
            }
            /* Add this character to the buffer */
            symbuf[i++] = c;
            c = getchar();
        }while (isalnum(c));

        ungetc(c,stdin);
        symbuf[i] = '\0';

        s = getsym(symbuf);
        if(s == 0)
            s = putsym(symbuf,VAR);
        yylval.tptr = s;
        return s->type;
    }


    /* Any other character is a token by itself. */
    return c;
}

void yyerror(char const *s)
{
    fprintf(stderr,"%s\n",s);
}

int main(void)
{
    init_table();
    return yyparse();
}

