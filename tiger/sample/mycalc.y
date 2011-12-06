/* Declarations */

%{
#define YYSTYPE double
#include <math.h>
#include <ctype.h>
#include <stdio.h>
int yylex (void);
void yyerror (char const *);
%}

%token NUM

%% /* Grammar rules and actions follow */

input: /* empty */
     | input line
;

line:   '\n'
    | exp '\n' { printf ("\t%.10g\n", $1); }
;

exp:    NUM         { $$ = $1; }
   |    exp exp '+' { $$ = $1 + $2; }
   |    exp exp '-' { $$ = $1 - $2; }
   |    exp exp '*' { $$ = $1 * $2; }
   |    exp exp '/' { $$ = $1 / $2; }
   |    exp exp '^' { $$ = pow($1,$2); }
   |    exp exp 'n' { $$ = -$1; }

%%


int yylex(void)
{
    int c;

    /* skip white space. */
    while((c = getchar()) == ' ' || c == '\t');

    /* Process numbers */
    if( c == '.' || isdigit(c) )
    {
        ungetc(c, stdin);
        scanf("%lf",&yylval);
        return NUM;
    }

    /* Return EOF */
    if( c== EOF )
    return 0;

    /* Return a single char. */
    return c;
}

void yyerror(char const *s)
{
    fprintf(stderr,"%s\n",s);
}

int main(void)
{
    return yyparse();
}
