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
#define F_ND_NEW(t,v1,v2,v3) f_nd_new((t),\
    (tg_value_t)(v1),\
    (tg_value_t)(v2),\
    (tg_value_t)(v3)\
)

#define F_ND_NEW_NUM(num) F_ND_NEW(E_NODE_TYPE_NUM,num,0,0)
#define F_ND_NEW_STR(str) F_ND_NEW(E_NODE_TYPE_STR,str,0,0)

typedef enum tg_nodeType_e tg_nodeType_t;

enum tg_nodeType_e
{
    E_NODE_TYPE_IF,
    E_NODE_TYPE_THEN,
    E_NODE_TYPE_ELSE,
    E_NODE_TYPE_WHILE,
    E_NODE_TYPE_DO,
    E_NODE_TYPE_FOR,
    E_NODE_TYPE_BREAK,
    E_NODE_TYPE_TO,
    E_NODE_TYPE_IN,
    E_NODE_TYPE_LET,
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
    //unsigned int flags;
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
    } u2;
    union {
        tg_id_t id;
        tg_node_t * node;
        tg_value_t value;
    } u3;
};

tg_node_t * f_nd_new(tg_nodeType_t,tg_value_t,tg_value_t,tg_value_t);




