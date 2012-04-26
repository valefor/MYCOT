#include <stdio.h>
#include <math.h>

typedef double(*func_t) (double);

struct symrec
{
    char * name;
    int type;
    union
    {
        double var;
        func_t fnctptr;
    } value;
    struct symrec *next;
};

typedef struct symrec symrec;

extern symrec * sym_table;

symrec * putsym ( char const*,int );
symrec * getsym ( char const* );

struct init
{
    char const * fname;
    double (*fnct) (double);
};

struct init const arith_fncts[] = 
{
    {"sin",sin},
    {"cos",cos},
    {"atan",atan},
    {"ln",log},
    {"exp",exp},
    {"sqrt",sqrt},
    0,0
};

