#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "config.h"

typedef unsigned int UINT;

UINT randInt();
UINT simpleMix(UINT);
void avalancheMatrix();


UINT hashMix(UINT hash)
{
    return simpleMix(hash);
}

UINT simpleMix(UINT hash)
{
    hash += (hash << 12);
    hash ^= (hash >> 22);
    hash += (hash << 4);
    hash ^= (hash >> 9);
    hash += (hash << 10);
    hash ^= (hash >> 2);
    hash += (hash << 7);
    hash ^= (hash >> 12);
    return hash;
}

void avalancheMatrix(int trials,int repetitions,int size)
{
    int i,j,r;
    //if(!am) am = (double**)malloc(sizeof(double)*size*size);
    double am[size][size];
    double dTrials = trials;
    UINT state, save, inb, outb,t[size][size];

    while( trials -- > 0 )
    {
        save = state = randInt();
        for( r = 0; r < repetitions; r++ ) {state = hashMix(state);}
        inb = state;

        for( i = 0; i < size; i++ )
        {
            state = save ^ (1U << i);
            for( r = 0; r < repetitions; r++ ) {state = hashMix(state);}
            outb = state ^ inb;
            for( j = 0; j < size; j++ )
            {
                if( (outb & 1) != 0 ) t[i][j]++;
                outb >>= 1;
            }
        }
    }

#if DEBUG_LEVEL > 8
    printf("   ");
    for( i = 0; i < size; i++ )
    {
        printf("%4d ",i);
    }
    printf("\n");

    for( i = 0; i < size; i++ )
    {
        printf("%2d ",i);
        for( j = 0; j < size; j++ )
        {
            am[i][j] = t[i][j]/dTrials;
            printf("%.2f ",am[i][j]);
        }
        printf("\n");
    }
#else
    for( i = 0; i < size; i++ )
    {
        for( j = 0; j < size; j++ )
        {
            am[i][j] = t[i][j]/dTrials;
        }
    }
#endif
}

/* get random unsigned int */
UINT randInt()
{
    //srand( time(NULL) );
    return (UINT) rand();
}

#define getByte32Bit(bytes,byteIdx)    getByteN(bytes,byteIdx,4)

UINT getByteN(UINT bytes, int byteIdx, int nBytes)
{
    byteIdx %= nBytes;

    return (UINT)(-1) | ( bytes << (8*(nBytes-byteIdx-1)) >> ( 8*byteIdx ) );
}

//-----------------------------------------------------------------------------  
// MurmurHash2, 64-bit versions, by Austin Appleby  
  
// The same caveats as 32-bit MurmurHash2 apply here - beware of alignment   
// and endian-ness issues if used across multiple platforms.  
  
// typedef unsigned long int uint64_t;  
  
// 64-bit hash for 64-bit platforms  
uint64_t MurmurHash64A ( const void * key, int len, unsigned int seed )  
{  
        const uint64_t m = 0xc6a4a7935bd1e995;  
        const int r = 47;  
  
        uint64_t h = seed ^ (len * m);  
  
        const uint64_t * data = (const uint64_t *)key;  
        const uint64_t * end = data + (len/8);  
  
        while(data != end)  
        {  
                uint64_t k = *data++;  
  
                k *= m;   
                k ^= k >> r;   
                k *= m;   
  
                h ^= k;  
                h *= m;   
        }  
  
        const unsigned char * data2 = (const unsigned char*)data;  
  
        switch(len & 7)  
        {  
            case 7: h ^= (uint64_t)(data2[6]) << 48;  
            case 6: h ^= (uint64_t)(data2[5]) << 40;  
            case 5: h ^= (uint64_t)(data2[4]) << 32;  
            case 4: h ^= (uint64_t)(data2[3]) << 24;  
            case 3: h ^= (uint64_t)(data2[2]) << 16;  
            case 2: h ^= (uint64_t)(data2[1]) << 8;  
            case 1: h ^= (uint64_t)(data2[0]);  
                    h *= m;  
        };  
   
        h ^= h >> r;  
        h *= m;  
        h ^= h >> r;  
  
        return h;  
}   
  
  
// 64-bit hash for 32-bit platforms  
uint64_t MurmurHash64B ( const void * key, int len, unsigned int seed )  
{  
        const unsigned int m = 0x5bd1e995;  
        const int r = 24;  
  
        unsigned int h1 = seed ^ len;  
        unsigned int h2 = 0;  
  
        const unsigned int * data = (const unsigned int *)key;  
  
        while(len >= 8)  
        {  
                unsigned int k1 = *data++;  
                k1 *= m; k1 ^= k1 >> r; k1 *= m;  
                h1 *= m; h1 ^= k1;  
                len -= 4;  
  
                unsigned int k2 = *data++;  
                k2 *= m; k2 ^= k2 >> r; k2 *= m;  
                h2 *= m; h2 ^= k2;  
                len -= 4;  
        }  
  
        if(len >= 4)  
        {  
                unsigned int k1 = *data++;  
                k1 *= m; k1 ^= k1 >> r; k1 *= m;  
                h1 *= m; h1 ^= k1;  
                len -= 4;  
        }  
  
        switch(len)  
        {  
        case 3: h2 ^= ((unsigned char*)data)[2] << 16;  
        case 2: h2 ^= ((unsigned char*)data)[1] << 8;  
        case 1: h2 ^= ((unsigned char*)data)[0];  
                        h2 *= m;  
        };  
  
        h1 ^= h2 >> 18; h1 *= m;  
        h2 ^= h1 >> 22; h2 *= m;  
        h1 ^= h2 >> 17; h1 *= m;  
        h2 ^= h1 >> 19; h2 *= m;  
  
        uint64_t h = h1;  
  
        h = (h << 32) | h2;  
  
        return h;  
}

