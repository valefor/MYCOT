/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Symbol Table $\ }
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
 *  LocalMoudle:symbolTable
 * }
 * 
 * @Doc:{
 *
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/
#include  "st.h"

typedef struct s_st_tableEntry st_tableEntry;

struct s_st_tableEntry 
{
    st_index_t      hash;
    st_data_t       key;
    st_tableEntry   *next;
};

static const struct s_st_hashType cl_numHashType =
{
    f_st_numCmp,
    f_st_numHash,
};

#define f_st_strCmp strcmp
static st_index_t f_st_strHash(st_data_t);
static const struct s_st_hashType cl_strHashType =
{
    f_st_strCmp,
    f_st_strHash,
};


uint64_t MurmurHash64B( const void * , int, unsigned int );
/* The poor FNV1 -_- */
#define FNV1_32A_INIT 0x811c9dc5
/*
 * 32 bit magic FNV-1a prime
 */
#define FNV_32_PRIME 0x01000193

static st_index_t
f_st_strHash(st_data_t arg)
{
    register const char *string = (const char *)arg;
    return MurmurHash64B(string, strlen(string), FNV1_32A_INIT);
}

int
f_st_numCmp(st_data_t x, st_data_t y)
{
    return x != y;
}

st_index_t
f_st_numHash(st_data_t n)
{
    return (st_index_t)n;
}

int 
f_st_delete(st_table * table ,register st_data_t key ,st_data_t * value)
{
    return 0;
}

int f_st_insert(st_table * table,register st_data_t key,st_data_t * value)
{
    return 0;
}

int f_st_lookup(st_table * table,register st_data_t key,st_data_t * value)
{
    return 0;
}
