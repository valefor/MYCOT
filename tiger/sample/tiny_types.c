#include "tiny_types.h"
#include "tiny_util.h"

A_stm A_CompoundStm(A_stm stm1,A_stm stm2)
{
    A_stm s = checked_malloc(sizeof(*s));
    s->kind = A_compoundStm;
    s->uni.compound.stm1 = stm1;
    s->uni.compound.stm2 = stm2;
    return s;
}

A_stm A_AssignStm(string id, A_exp exp)
{
    A_stm s = checked_malloc(sizeof(*s));
    s->kind = A_assignStm;
    s->uni.assign.id = id;
    s->uni.assign.exp = exp;
    return s;
}

A_stm A_PrintStm(A_expList exps)
{
    A_stm s = checked_malloc(sizeof(*s));
    s->kind = A_printStm;
    s->uni.print.exps = exps;
    return s;
}

A_exp A_IdExp(string id)
{
    A_exp e = checked_malloc(sizeof(*e));
    e->kind = A_idExp;
    e->uni.id = id;
    return e;
}

A_exp A_NumExp(int num)
{
    A_exp e = checked_malloc(sizeof(*e));
    e->kind = A_numExp;
    e->uni.num = num;
    return e;
}

A_exp A_OpExp(A_exp left,A_binop op, A_exp right)
{
    A_exp e = checked_malloc(sizeof(*e));
    e->kind = A_opExp;
    e->uni.oper.left = left;
    e->uni.oper.op = op;
    e->uni.oper.right = right;
    return e;
}

A_exp A_EseqExp(A_stm stm,A_exp exp)
{
    A_exp e = checked_malloc(sizeof(*e));
    e->kind = A_eseqExp;
    e->uni.eseq.stm = stm;
    e->uni.eseq.exp = exp;
    return e;
}

A_expList A_PairExpList(A_exp head,A_expList tail)
{
    A_expList el = checked_malloc(sizeof(*el));
    el->kind = A_pairExpList;
    el->uni.pair.head = head;
    el->uni.pair.tail = tail;
    return el;
}

A_expList A_LastExpList(A_exp last)
{
    A_expList el = checked_malloc(sizeof(*el));
    el->kind = A_lastExpList;
    el->uni.last = last;
    return el;
}

Table_ Table(string id,int value, Table_ tail)
{
    Table_ t = checked_malloc(sizeof(*t));
    t->id = id;
    t->value = value;
    t->tail = tail;
    return t;
}
