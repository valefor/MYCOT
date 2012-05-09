#include <stdio.h>
#include <stdlib.h>

#include "st.h"
#include "tiger.h"
#include "node.h"
#include "tiger_parser.h"
#include "tiger_lexer.h"

int main( int argc, char ** argv)
{
/*
    int i,j;
    avalancheMatrix(1000000,1,32);
*/

    ++argv,--argc; // skip over program name

    struct psr_params_s *pPsrParams = f_psr_new();
    yyscan_t scanner;
    if( argc > 0 )
    pPsrParams->psr_srcFileName = argv[0];
    yyparse(pPsrParams,scanner);
    /*
    FILE * srcFile;
    yyscan_t scanner;
    YYSTYPE * v_yyVal = malloc(sizeof(YYSTYPE));
    YYLTYPE * v_yyLoc = malloc(sizeof(YYLTYPE));

    v_yyVal->val = 0;
    v_yyLoc->first_line = 0;
    v_yyLoc->first_column = 0;
    v_yyLoc->last_line = 0;
    v_yyLoc->last_column = 0;

    if( argc > 0 )
        srcFile = fopen( argv[0],"r");
    else
        srcFile = stdin;

    int tok;
    yylex_init(&scanner);

    yyset_in(srcFile,scanner);

    while((tok=yylex(v_yyVal,v_yyLoc,scanner))>0)
        printf("token=%d yytext=%s\n",tok,yyget_text(scanner));

    yylex_destroy(scanner);
    */

    return 0;
}

