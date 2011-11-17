#include "tiny_util.h"
#include <stdlib.h>

void * checked_malloc(int len)
{
    void *p = malloc(len);
    assert(p);
    return p;
}
