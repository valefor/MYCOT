/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Symbol Table Header File$\ }
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
 *  LocalModule:symbolTable
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
 *      st      <->     symbol table
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/
typedef unsigned long long uint64_t;
typedef unsigned long st_data_t;

typedef st_data_t st_index_t;

#ifdef __cplusplus
#   define ANYARGS ...
#else
#   define ANYARGS
#endif

struct st_hashType_s
{
    int (*compare)(ANYARGS);
    st_index_t (*hash)(ANYARGS);
};
typedef struct st_hashType_s st_hashType_t;

struct st_table_s
{
    const struct st_hashType_s *hashType;
    st_index_t  binsNbr;
    st_index_t  totalEntryNbr;
    struct st_tableEntry_s  **bins;
    struct st_tableEntry_s  *head,*tail;
};
typedef struct st_table_s st_table_t;

/**/

typedef struct st_tableEntry_s st_tableEntry_t;

struct st_tableEntry_s 
{
    st_index_t      hashCode;
    st_data_t       key;
    st_data_t       value;
    st_tableEntry_t   *next;
    st_tableEntry_t   *fore, *back;
};

/* symbol table functions - initiating */
st_table_t * f_st_initTable(const st_hashType_t *hashType,st_index_t size);
int f_st_numCmp(st_data_t, st_data_t);
st_index_t f_st_numHash(st_data_t );

/* symbol table functions - operating */
void f_st_add(st_table_t *,st_data_t ,st_data_t);
int f_st_insert(st_table_t *,st_data_t ,st_data_t );
int f_st_delete(st_table_t *,st_data_t *,st_data_t *);
int f_st_lookup(st_table_t *,st_data_t ,st_data_t *);

/* Hash Functions*/

// murmur hash
uint64_t MurmurHash64A ( const void * key, int len, unsigned int seed );
uint64_t MurmurHash64B ( const void * key, int len, unsigned int seed );

/* Tiger dedicated hash type */
st_index_t f_tg_strHash(st_data_t);
st_index_t f_tg_numHash(st_data_t);
int f_tg_numCmp(st_data_t x, st_data_t y);
