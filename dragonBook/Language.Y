%{
%}

%token IF ELSE WHILE DO BREAK
%token BASIC NUM REAL
%token BOOL AND EQ TRUE FALSE GE IF OR NE LE
%token ID INDEX MINUS TEMP

%% /* Grammar */

program     : block;
block       : '{' decls stmts '}';
decls       : decls decl
            |
            ;
decl        : type id;
type        : type '['num']'
            : basic
            ;
stmts       : stmts stmt
            |
            ;
stmt        : loc '=' boolexp;
            | IF '(' boolexp ')' stmt
            | IF '(' boolexp ')' stmt ELSE stmt
            | WHILE '(' boolexp ')' stmt
            | DO stmt WHILE '(' boolexp ')' ';'
            | BREAK ';'
            | block
            ;
loc         : loc '[' BOOL ']'
            | ID
            ;
boolexp     : boolexp OR join
            | join
            ;
join        : join AND equality 
            | equality
            ;
equality    : equality EQ rel
            | equality NE rel
            | rel
            ;
rel         : expr LE expr
            | expr GE expr
            | expr
            ;
expr        : expr '+' term
            | expr '-' term
            | term
            ;
term        : term '*' unary
            | term '/' unary
            | unary
            ;
unary       : '!' unary 
            | '-' unary
            | factor
            ;
factor      : '(' boolexp ')'
            | loc
            | NUM
            | REAL
            | TRUE
            | FALSE
            ;
