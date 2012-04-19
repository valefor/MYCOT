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
#include "st.h"
#include "utils.h"

typedef struct s_st_tableEntry st_tableEntry;

struct s_st_tableEntry 
{
    st_index_t      hashCode;
    st_data_t       key;
    st_data_t       value;
    st_tableEntry   *next;
    st_tableEntry   *fore, *back;
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

/*
 * MINSIZE is the minimum size of a dictionary.
 */

#define ST_TABLE_MINSIZE 8

/*
Table of prime numbers 2^n+a, 2<=n<=30.
*/
static const unsigned int cl_primes[] = {
	8 + 3,
	16 + 3,
	32 + 5,
	64 + 3,
	128 + 3,
	256 + 27,
	512 + 9,
	1024 + 9,
	2048 + 5,
	4096 + 3,
	8192 + 27,
	16384 + 43,
	32768 + 3,
	65536 + 45,
	131072 + 29,
	262144 + 3,
	524288 + 21,
	1048576 + 7,
	2097152 + 17,
	4194304 + 15,
	8388608 + 9,
	16777216 + 43,
	33554432 + 35,
	67108864 + 15,
	134217728 + 29,
	268435456 + 3,
	536870912 + 11,
	1073741824 + 85,
	0
};

/* The poor FNV1 -_- */
#define FNV1_32A_INIT 0x811c9dc5
/*
 * 32 bit magic FNV-1a prime
 */
#define FNV_32_PRIME 0x01000193

/* ST UTIL MARCO Section */
#define ST_ENTRY_EQUAL(table,x,y) ((x)==(y) || \
        (*(table)->hashType->compare)((x),(y)) == 0)

#define ST_PTR_NOT_EQUAL(table, ptr_tableEntry, vl_hashVal, key) \
    ((ptr_tableEntry) != 0 && ( (ptr_tableEntry)->hashCode != (vl_hashVal) || \
    !ST_ENTRY_EQUAL((table),(key),(ptr_tableEntry)->key) ) )
#define ST_DO_HASH(table,key) (unsigned int)(st_index_t)\
    (*(table)->hashType->hash)((key)) 

#define ST_DO_HASH_BIN(table,key) (ST_DO_HASH((key), \
    (table))%(table)->binsNbr)

#define ST_FIND_ENTRY(table, ptr_tableEntry, vl_hashVal, vl_binPos) do{ \
    (vl_binPos) = (vl_hashVal)%(table)->binsNbr; \
    (ptr_tableEntry) = (table)->bins[(vl_binPos)]; \
    if(ST_PTR_NOT_EQUAL((table),(ptr_tableEntry),(vl_hashVal),key)) { \
    while(ST_PTR_NOT_EQUAL((table),(ptr_tableEntry)->next,(vl_hashVal),key)){ \
        (ptr_tableEntry) = (ptr_tableEntry)->next; \
    } \
    (ptr_tableEntry) = (ptr_tableEntry)->next; \
    } \
} while (0)

static st_index_t
f_st_newHashSize(st_index_t size)
{
    int i;

    st_index_t vl_newSize;

    for(i = 0,vl_newSize = ST_TABLE_MINSIZE ; 
            i < ARY_ITEM_NUMBER(cl_primes)  ; i++,vl_newSize <<=1 ) {
        if (vl_newSize > size) return cl_primes[i];
    }

    /* Ran out of polynomial */
    fprint(stderr,"symbol table too big!\n");

    return -1;
}

static void
f_st_rehash(register st_table *table)
{
    register st_tableEntry *ptr_tableEntry, ** p2_newBins;
    st_index_t i,vl_newBinsNbr,vl_hashVal;

    vl_newBinsNbr = f_st_newHashSize(table->binsNbr+1);

    p2_newBins = (st_tableEntry**) 
        realloc(table->bins, vl_newBinsNbr * sizeof(st_tableEntry *));
    for(i = 0; i < vl_newBinsNbr; ++i) p2_newBins[i] = 0;
    table->binsNbr = vl_newBinsNbr;
    table->bins = p2_newBins;

    if((ptr_tableEntry = table->head) != 0 )
    {
        do {
            vl_hashVal = ptr_tableEntry->hashCode % vl_newBinsNbr;
            ptr_tableEntry->next = p2_newBins[vl_hashVal];
            p2_newBins[vl_hashVal] = ptr_tableEntry;
        } while ( (ptr_tableEntry = ptr_tableEntry->fore) != 0 );
    }
}

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
    st_index_t vl_hashVal,vl_binPos;
    register st_tableEntry *ptr_tableEntry;

    vl_hashVal = ST_DO_HASH(table,key);
    ST_FIND_ENTRY(table,ptr_tableEntry,vl_hashVal,vl_binPos);

    if(!ptr_tableEntry)
    {
    }
    return 0;
}

int f_st_lookup(st_table * table,register st_data_t key,st_data_t * value)
{
    return 0;
}
