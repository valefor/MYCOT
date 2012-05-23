/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Syntax Tree - Node$\ }
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
 *
 * }
 *
 * @Abbreviations:{
 *      tg      <->     tiger
 *      nd      <->     node
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/
#include "tiger.h"
#include "node.h"

tg_node_t * f_nd_new(
    tg_nodeType_t tNodeType,
    tg_value_t tV1,
    tg_value_t tV2,
    tg_value_t tV3
)
{
    tg_node_t * pNewNode = MEM_ALLOC(tg_node_t);
    pNewNode->nodeType = tNodeType;

    pNewNode->u1.value = tV1;
    pNewNode->u2.value = tV2;
    pNewNode->u3.value = tV3;

    f_nd_setLRvalue(pNewNode,tNodeType);
    return pNewNode;
}

void f_nd_setLRvalue(tg_node_t *pNode,tg_nodeType_t tNodeType)
{
    pNode->flags = 0;
    switch(tNodeType) {
        case E_NODE_TYPE_TFEILD:
        case E_NODE_TYPE_ARITH:
        case E_NODE_TYPE_FUNCALL:
        case E_NODE_TYPE_CONDEXP:
        case E_NODE_TYPE_RELAT:
        case E_NODE_TYPE_LOGIC:
            ND_SET_RVALUE(pNode);
            break;
        case E_NODE_TYPE_TYPEDEC:
        case E_NODE_TYPE_ASSIGN:
            ND_SET_RVALUE(pNode);
            ND_SET_LVALUE(pNode);
            break;
        default:
            break;
    }
}
