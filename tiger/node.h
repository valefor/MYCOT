/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Syntax Tree - Node Header File$\ }
 * 
 * @Author:{
 *  Name  : Adrian Hu
 *  Email : adrain.f.tepes@gmail.com
 * }
 * 
 *
 * @Progress:{
 * 
 * }
 * 
 * @Module:{
 *  LocalModule:syntax Tree
 * }
 * 
 * @CGL:{
 *  Contract: Obey
 * }
 * 
 * @Doc:{
 *
 *  x. Abbreviations:
 *      tg      <->     tiger
 *      nd      <->     node
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/
#define ND_NEW(t,v1,v2,v3) f_nd_new((t),\
    (tg_value_t)(v1),\
    (tg_value_t)(v2),\
    (tg_value_t)(v3)\
)

#define ND_NEW_NUM(num) ND_NEW(E_NODE_TYPE_NUM,num,0,0)
#define ND_NEW_STR(str) ND_NEW(E_NODE_TYPE_STR,str,0,0)
#define ND_NEW_IF(c,t,e) ND_NEW(E_NODE_TYPE_IF,c,t,e)
#define ND_NEW_WHILE(c,d) ND_NEW(E_NODE_TYPE_WHILE,c,d,0)
#define ND_NEW_BREAK(s) ND_NEW(E_NODE_TYPE_BREAK,s,0,0)
#define ND_NEW_ARYOF(t) ND_NEW(E_NODE_TYPE_ARRAY_OF,t,0,0)
#define ND_NEW_TFEILD(i,t) ND_NEW(E_NODE_TYPE_TFEILD,i,t,0)
#define ND_NEW_TYPEDEC(i,d) ND_NEW(E_NODE_TYPE_TYPEDEC,i,d,0)
#define ND_NEW_FUNCDEF(i,a,s) ND_NEW(E_NODE_TYPE_FUNCDEF,i,a,s)
#define ND_NEW_FUNCALL(i,args) ND_NEW(E_NODE_TYPE_FUNCALL,i,args,0)
#define ND_NEW_LET(d,e) ND_NEW(E_NODE_TYPE_LET,d,e,0)
#define ND_NEW_FOR(f,t,s) ND_NEW(E_NODE_TYPE_FOR,f,t,s)
#define ND_NEW_ASSIGN(i,v) ND_NEW(E_NODE_TYPE_ASSIGN,i,v,0)
#define ND_NEW_CONDEXP(c,e1,e2) ND_NEW(E_NODE_TYPE_CONDEXP,c,e1,e2)
#define ND_NEW_ARITH(l,o,r) ND_NEW(E_NODE_TYPE_ARITH,l,o,r)
#define ND_NEW_RELAT(l,o,r) ND_NEW(E_NODE_TYPE_RELAT,l,o,r)
#define ND_NEW_LOGIC(l,o,r) ND_NEW(E_NODE_TYPE_LOGIC,l,o,r)
#define ND_NEW_AND(l,r) ND_NEW(E_NODE_TYPE_AND,l,r,0)
#define ND_NEW_OR(l,r) ND_NEW(E_NODE_TYPE_OR,l,r,0)
#define ND_NEW_SCOPE(l,a,b) ND_NEW(E_NODE_TYPE_SCOPE,l,b,a)

#define ND_GET_TYPE(node) (node)->nodeType
#define ND_SET_TYPE(node,type) (node)->nodeType = (type)

#define ND_MASK_LVALUE  (tg_value_t)1
#define ND_MASK_RVALUE  ((tg_value_t)1<<1)
#define ND_IS_LVALUE(node) ( (node)->flags & ND_MASK_LVALUE )
#define ND_IS_RVALUE(node) ( (node)->flags & ND_MASK_RVALUE ) 
#define ND_SET_LVALUE(node) ( (node)->flags |= ND_MASK_LVALUE )
#define ND_SET_RVALUE(node) ( (node)->flags |= ND_MASK_RVALUE ) 

typedef enum tg_nodeType_e tg_nodeType_t;

enum tg_nodeType_e
{
    E_NODE_TYPE_IF,
    E_NODE_TYPE_WHILE,
    E_NODE_TYPE_FOR,
    E_NODE_TYPE_BREAK,
    E_NODE_TYPE_TFEILD,
    E_NODE_TYPE_TYPEDEC,
    E_NODE_TYPE_FUNCDEF,
    E_NODE_TYPE_FUNCALL,
    E_NODE_TYPE_LET,
    E_NODE_TYPE_ASSIGN,
    E_NODE_TYPE_CONDEXP,
    E_NODE_TYPE_ARITH,
    E_NODE_TYPE_RELAT,
    E_NODE_TYPE_LOGIC,
    E_NODE_TYPE_AND,
    E_NODE_TYPE_OR,
    E_NODE_TYPE_SCOPE,
    E_NODE_TYPE_LVAR,
    E_NODE_TYPE_NIL,
    E_NODE_TYPE_FUNC,
    E_NODE_TYPE_ARRAY_OF,
    E_NODE_TYPE_OF,
    E_NODE_TYPE_END,
    E_NODE_TYPE_NUM,
    E_NODE_TYPE_STR,
    E_NODE_TYPE_LAST
};

typedef struct tg_node_s tg_node_t;

struct tg_node_s{
    /********************************************/
    /*  The Ruby Flags intro:                   */
    /*                        Node Type         */
    /*        line Number       |               */
    /*  |<------------------>|<-----> |       | */
    /*  0000 0000 0000 0000 0000 0000 0000 0000 */
    /********************************************/
    /*              Node Type Mask              */
    /*  0000 0000 0000 0000 0111 1111 0000 0000 */
    /********************************************/
    /*              File Line Mask              */
    /*  0000 0000 0000 0001 1111 1111 1111 1111 */
    /********************************************/
    /* I give up the ruby's proposal,try to use */
    /* type 'nodeType' and 'lineNbr' to         */
    /* indicates node type and line number      */
    /********************************************/

    /********************************************/
    /*  The Tiger Flags intro:                  */
    /*                                  L-Value */
    /*                                 R-Value| */
    /*                                       || */
    /*  0000 0000 0000 0000 0000 0000 0000 0000 */
    /********************************************/
    /*              IS L-Value Mask             */
    /*  0000 0000 0000 0000 0000 0000 0000 0001 */
    /********************************************/
    /*              IS R-Value Mask             */
    /*  0000 0000 0000 0000 0000 0000 0000 0010 */
    /********************************************/
    unsigned int flags;
    tg_nodeType_t nodeType;
    unsigned long lineNbr;
    union {
        tg_id_t id;
        tg_node_t * node;
        tg_value_t value;
    } u1;
    union {
        tg_id_t id;
        tg_node_t * node;
        tg_value_t value;
        long argc;
    } u2;
    union {
        tg_id_t id;
        tg_node_t * node;
        tg_value_t value;
    } u3;
};

void f_nd_setLRvalue(tg_node_t *,tg_nodeType_t);
tg_node_t * f_nd_new(tg_nodeType_t,tg_value_t,tg_value_t,tg_value_t);




