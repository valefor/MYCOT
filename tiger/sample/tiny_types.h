typedef char boolean;

typedef char * string;
string String(char *);

#define TRUE 1
#define FALSE 0

typedef struct A_stm_ * A_stm;
typedef struct A_exp_ * A_exp;
typedef struct A_expList_ * A_expList;

typedef enum {A_plus, A_minus,A_times,A_div} A_binop;

struct A_stm_ {
    enum {
        A_compoundStm,
        A_assignStm,
        A_printStm
    } kind;
    union {
        struct { A_stm stm1, stm2; } compound;
        struct { string id; A_exp exp; } assign;
        struct { A_expList exps; } print;
    } uni;
};

A_stm A_CompoundStm(A_stm stm1,A_stm stm2);
A_stm A_AssignStm(string id, A_exp exp);
A_stm A_PrintStm(A_expList exps);

struct A_exp_ {
    enum {
        A_idExp,
        A_numExp,
        A_opExp,
        A_eseqExp
    } kind;
    union {
        string id;
        int num;
        struct {
            A_exp left;
            A_binop op;
            A_exp right;
        } oper;
        struct {
            A_stm stm;
            A_exp exp;
        } eseq;
    } uni;
};

A_exp A_IdExp(string id);
A_exp A_NumExp(int num);
A_exp A_OpExp(A_exp left,A_binop op, A_exp right);
A_exp A_EseqExp(A_stm stm,A_exp exp);

struct A_expList_ {
    enum {
        A_pairExpList,
        A_lastExpList
    } kind;
    union {
        struct {
            A_exp head;
            A_expList tail;
        } pair;
        A_exp last;
    } uni;
};

A_expList A_PairExpList(A_exp head,A_expList tail);
A_expList A_LastExpList(A_exp last);

typedef struct table * Table_;

struct table {
    string id;
    int value;
    Table_ tail;
};

Table_ Table(string id,int value, Table_ tail);

typedef struct tree * T_tree;
struct tree {
    T_tree left;
    string key;
    T_tree right;
};

T_tree Tree(T_tree,string,T_tree);

// AVL Tree
typedef struct atree * A_tree;
struct atree {
};

// Balanced Binary Tree
typedef struct btree * B_tree;
struct btree {
    B_tree lch; // left child
    int ldp;    // deep of left sub tree
    string key;
    B_tree rch; // right child
    int rdp;    // deep of right sub tree
    B_tree fth; // father
};

// Balanced Binary Tree functions
B_tree BTree(B_tree lch,string key,B_tree rch,B_tree fth);
int BT_deep(B_tree t);
B_tree BT_insert(string key, B_tree t);
void BT_zag(B_tree t);
void BT_zig(B_tree t);
void BT_print(B_tree t);

// Splay Tree
typedef struct stree * S_tree;
struct stree {
};


