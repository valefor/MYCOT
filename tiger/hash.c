

typedef UINT unsigned int;

UINT hashMix(UINT hash)
{
    hash += (hash << 12);
    hash ^= (hash >> 22);
    hash += (hash << 4);
    hash ^= (hash >> 9);
    hash += (hash << 10);
    hash ^= (hash << 2);
    hash += (hash << 7);
    hash ^= (hash >> 12);
    return hash;
}

double ** AvalancheMatrix(int trials,int repetitions)
{
    int size = 32;
}
