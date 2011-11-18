#include "tiny_types.h"
#include <stdio.h>

/*
 * a := 5 + 3; b := ( print( a , a-1 ) , 10*a ) ; print(b)
 *
 *
 */

int main(int argc, char ** argv)
{
    /*
    A_stm program =
        A_CompoundStm(
            A_AssignStm(
                "a",
                A_OpExp(A_NumExp(5),A_plus,A_NumExp(3))
            ),
            A_CompoundStm(
                A_AssignStm(
                    "b",
                    A_EseqExp(
                        A_PrintStm(
                            A_PairExpList(
                                A_IdExp("a"),
                                A_LastExpList(A_OpExp(A_IdExp("a"),A_minus,A_NumExp(1)))
                            )
                        ),
                        A_OpExp(A_NumExp(10),A_times,A_IdExp("a"))
                    )
                ),
                A_PrintStm(A_LastExpList(A_IdExp("b")))
            )
        );
    */
    string s[] = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n"};
    B_tree t = BTree(NULL,"z",NULL,NULL);
    //BT_insert("b",t);
    /*
    string * sptr = s;
    while( sptr )
    {
        BT_insert(*sptr,t);
        sptr ++;
    }

    BT_print(t);
    
    return 0;
    */
}

