/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Syntax Tree Header File$\ }
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
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/
typedef struct s_tg_node tg_node_t;

struct s_tg_node{
    union {
        tg_id_t * id;
        tg_node_t * node;
        tg_value_t * value;
    } u1;
    union {
        tg_id_t * id;
        tg_node_t * node;
        tg_value_t * value;
    } u2;
    union {
        tg_id_t * id;
        tg_node_t * node;
        tg_value_t * value;
    } u3;
};

enum e_tg_nodeType
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
    E_NODE_TYPE_LAST
};
