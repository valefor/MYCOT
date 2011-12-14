// Balanced Binary Tree
typedef struct symbolRecord * SB_Record;
struct symbolRecord {
    SB_Record lchild;  // left child
    int ldeep;        // deep of left sub tree
    void * value;
    SB_Record rchild; // right child
    int rdeep;    // deep of right sub tree
    SB_Record father; // father
};
