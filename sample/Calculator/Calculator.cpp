enum SymbolConstants
{
   SYM_EOF            =  0, // (EOF)
   SYM_ERROR          =  1, // (Error)
   SYM_COMMENT        =  2, // Comment
   SYM_NEWLINE        =  3, // NewLine
   SYM_WHITESPACE     =  4, // Whitespace
   SYM_TIMESDIV       =  5, // '*/'
   SYM_DIVTIMES       =  6, // '/*'
   SYM_DIVDIV         =  7, // '//'
   SYM_MINUS          =  8, // '-'
   SYM_LPAREN         =  9, // '('
   SYM_RPAREN         = 10, // ')'
   SYM_TIMES          = 11, // '*'
   SYM_DIV            = 12, // '/'
   SYM_PLUS           = 13, // '+'
   SYM_DECLITERAL     = 14, // DecLiteral
   SYM_PRINT          = 15, // print
   SYM_CALCULATE      = 16, // <Calculate>
   SYM_CALCULATIONS   = 17, // <Calculations>
   SYM_EXPRESSION     = 18, // <Expression>
   SYM_MULTIPLYDIVIDE = 19, // <MultiplyDivide>
   SYM_VALUE          = 20  // <Value>
};

enum ProductionConstants
{
   PROD_CALCULATIONS                  =  0, // <Calculations> ::= <Calculate> <Calculations>
   PROD_CALCULATIONS2                 =  1, // <Calculations> ::= 
   PROD_CALCULATE_PRINT_LPAREN_RPAREN =  2, // <Calculate> ::= print '(' <Expression> ')'
   PROD_EXPRESSION_PLUS               =  3, // <Expression> ::= <MultiplyDivide> '+' <Expression>
   PROD_EXPRESSION_MINUS              =  4, // <Expression> ::= <MultiplyDivide> '-' <Expression>
   PROD_EXPRESSION                    =  5, // <Expression> ::= <MultiplyDivide>
   PROD_MULTIPLYDIVIDE_TIMES          =  6, // <MultiplyDivide> ::= <Value> '*' <MultiplyDivide>
   PROD_MULTIPLYDIVIDE_DIV            =  7, // <MultiplyDivide> ::= <Value> '/' <MultiplyDivide>
   PROD_MULTIPLYDIVIDE                =  8, // <MultiplyDivide> ::= <Value>
   PROD_VALUE_DECLITERAL              =  9, // <Value> ::= DecLiteral
   PROD_VALUE_LPAREN_RPAREN           = 10  // <Value> ::= '(' <Expression> ')'
};
