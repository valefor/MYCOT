/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Symbol Table Implemetation File$\ }
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
 *      st      <->     symbol table
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tiger.h"

#include "st.h"

/******************************************************************************
 *
 *  Symbol Table Definitions
 *
 *****************************************************************************/
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
 * ST_MAX_BIN_SIZE is the default for the largest we allow the
 * average number of items per bin before increasing the number of
 * bins
 *
 * ST_INIT_TABLE_SIZE is the default for the number of bins
 * allocated initially
 *
 */
#define ST_MAX_BIN_SIZE 5
#define ST_INIT_TABLE_SIZE 11

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

/******************************************************************************
 *
 *  Symbol Table Util Marcos
 *
 *****************************************************************************/
#define ST_ENTRY_EQUAL(table,x,y) ((x)==(y) || \
        (*(table)->hashType->compare)((x),(y)) == 0)

#define ST_PTR_NOT_EQUAL(table, entry, hashVal, key) \
    ((entry) != 0 && ( (entry)->hashCode != (hashVal) || \
    !ST_ENTRY_EQUAL((table),(key),(entry)->key) ) )
#define ST_DO_HASH(table,key) (unsigned int)(st_index_t)\
    (*(table)->hashType->hash)((key)) 

#define ST_DO_HASH_BIN(table,key) (ST_DO_HASH((table), \
    (key)) % (table)->binsNbr)

#define ST_FIND_ENTRY(table, entry, hashVal, binPos) do{ \
    (binPos) = (hashVal)%(table)->binsNbr; \
    (entry) = (table)->bins[(binPos)]; \
    if(ST_PTR_NOT_EQUAL((table),(entry),(hashVal),key)) { \
    while(ST_PTR_NOT_EQUAL((table),(entry)->next,(hashVal),key)){ \
        (entry) = (entry)->next; \
    } \
    (entry) = (entry)->next; \
    } \
} while (0)

#define ST_INSERT_ENTRY(table, key, value, hashVal, binPos) do { \
    st_tableEntry_t * pEntry;\
    if((table)->totalEntryNbr > ST_MAX_BIN_SIZE * (table)->binsNbr) { \
        f_st_rehash(table); \
        (binPos) = (hashVal) % (table)->binsNbr; \
    }\
    pEntry = MEM_ALLOC(st_tableEntry_t); \
    pEntry->hashCode = (hashVal); \
    pEntry->key = (key); \
    pEntry->value = (value); \
    pEntry->next = (table)->bins[(binPos)]; \
    if((table)->head != 0) { \
        pEntry->fore = 0; \
        (pEntry->back = (table)->tail)->fore = pEntry; \
        (table)->tail = pEntry; \
    } \
    else { \
        (table)->head = (table)->tail = pEntry; \
        pEntry->fore = pEntry->back = 0; \
    }\
    (table)->bins[(binPos)] = pEntry; \
    (table)->totalEntryNbr++; \
    \
}while (0)

#define ST_REMOVE_ENTRY(table,entry) do { \
    if((entry)->fore == 0 && (entry)->back == 0) { \
        (table)->head = 0; \
        (table)->tail = 0; \
    } \
    else { \
        st_tableEntry_t *pFore = (entry)->fore, \
        *pBack = (entry)->back; \
        if(pFore) pFore->back = pBack; \
        if(pBack) pBack->fore = pFore; \
        if( (entry) == (table)->head ) (table)->head = pFore; \
        if( (entry) == (table)->tail ) (table)->tail = pBack; \
    } \
    (table)->totalEntryNbr--; \
} while(0)\

/******************************************************************************
 *
 *  Symbol Table Hash Functions
 *
 *****************************************************************************/
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
    fprintf(stderr,"symbol table too big!\n");

    return -1;
}

static void
f_st_rehash(register st_table_t *table)
{
    register st_tableEntry_t *pEntry, ** p2NewBins;
    st_index_t i,tNewBinsNbr,tHashVal;

    tNewBinsNbr = f_st_newHashSize(table->binsNbr+1);

    p2NewBins = (st_tableEntry_t**) 
        realloc(table->bins, tNewBinsNbr * sizeof(st_tableEntry_t *));
    for(i = 0; i < tNewBinsNbr; ++i) p2NewBins[i] = 0;
    table->binsNbr = tNewBinsNbr;
    table->bins = p2NewBins;

    if((pEntry = table->head) != 0 )
    {
        do {
            tHashVal = pEntry->hashCode % tNewBinsNbr;
            pEntry->next = p2NewBins[tHashVal];
            p2NewBins[tHashVal] = pEntry;
        } while ( (pEntry = pEntry->fore) != 0 );
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

st_index_t
f_tg_strHash(st_data_t arg)
{
    return f_st_strHash(arg);
}

int
f_tg_numCmp(st_data_t x, st_data_t y)
{
    return x != y;
}

st_index_t
f_tg_numHash(st_data_t arg)
{
    return f_st_numHash(arg);
}

/******************************************************************************
 *
 *  Symbol Table Operating Functions
 *
 *****************************************************************************/
st_table_t * 
f_st_initTable(const st_hashType_t *hashType,st_index_t size)
{
    st_table_t *pTable;

    /* round up to prime number */
    size = f_st_newHashSize(size);

    pTable = MEM_ALLOC(st_table_t);
    pTable->hashType = hashType;
    pTable->totalEntryNbr = 0;
    pTable->binsNbr = size;
    pTable->bins = (st_tableEntry_t**)MEM_CALLOC(size,sizeof(st_tableEntry_t*));
    pTable->head = NULL;
    pTable->tail = NULL;

    return pTable;
}

int f_st_insert(st_table_t * table,register st_data_t key,st_data_t value)
{
    st_index_t tHashVal,tBinPos;
    register st_tableEntry_t *pEntry;

    tHashVal = ST_DO_HASH(table,key);
    ST_FIND_ENTRY(table,pEntry,tHashVal,tBinPos);

    if(!pEntry)
    {
        ST_INSERT_ENTRY(table,key,value,tHashVal,tBinPos);
        return 0;
    }
    else
    {
        pEntry->value = value;
        return 1;
    }
}

int f_st_lookup(st_table_t * table,register st_data_t key,st_data_t * value)
{
    st_index_t tHashVal,tBinPos;
    register st_tableEntry_t *pEntry;

    tHashVal = ST_DO_HASH(table,key);
    ST_FIND_ENTRY(table,pEntry,tHashVal,tBinPos);

    if(!pEntry)
    {
        return 0;
    }
    else
    {
        if(value != 0) *value = pEntry->value;
        return 1;
    }
}

int f_st_delete(st_table_t * table ,register st_data_t * key,st_data_t * value)
{
    st_index_t tHashVal;
    st_tableEntry_t **p2Prev;
    register st_tableEntry_t *pEntry;
    
    tHashVal = ST_DO_HASH_BIN(table,*key);

    for(p2Prev = &table->bins[tHashVal];
            (pEntry = *p2Prev) !=0 ; p2Prev = &pEntry->next)
    {
        if( ST_ENTRY_EQUAL(table, *key, pEntry->key) )
        {
            *p2Prev = pEntry->next;
            ST_REMOVE_ENTRY(table,pEntry);
            if(value != 0) *value = pEntry->value;
            *key = pEntry->key;
            free(pEntry);
            return 1;
        }
    }

    if(value != 0) *value = 0;
    return 0;
}

