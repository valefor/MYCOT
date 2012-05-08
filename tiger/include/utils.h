/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Utils Header File$\ }
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
 *  LocalModule:utils
 * }
 * 
 * @CGL:{
 *  Contract: Obey
 * }
 * 
 * @Doc:{
 *
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/

/* Calculate the number of array's items */
#define ARY_ITEM_NUMBER(array) (int)(sizeof(array)/ sizeof((array)[0]))

/* Memory Management */
#define MEM_ALLOC(type) (type*)malloc((size_t)sizeof(type))
#define MEM_CALLOC(n,s) (char*)calloc((n),(s))
#define MEM_ZERO(p,type,n) memset((p),0,sizeof(type)*(n))
#define MEM_MOVE(to,from,type,n) memmove((to),(from),sizeof(type)*(n))
#define MEM_COPY(to,from,type,n) memcpy((to),(from),sizeof(type)*(n))
#define MEM_CMP(p1,p2,type,n) memcmp((p1),(p2),sizeof(type)*(n))
