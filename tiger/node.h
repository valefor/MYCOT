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
 *  LocalMoudle:syntax Tree
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
