/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Std Types Header File$\ }
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
 *  LocalMoudle:STD
 * }
 * 
 * @CGL:{
 *  Contract: Obey
 * }
 * 
 * @Doc:{
 *
 *  x. Abbreviations:
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/

typedef unsigned char U8;
typedef unsigned short U16;
typedef unsigned int U32;

typedef signed short I16;
typedef signed int I32;

typedef float F32;
typedef double F65;

#if !defined(__cplusplus) && !defined(_BASE_TYPES_H)
    #ifndef bool
    typedef U8 bool;
    #endif
#endif

#ifndef FALSE
    #define FALSE 0
#endif

#ifndef TRUE
    #define TRUE 1
#endif

#ifndef NULL
    #define NULL 0
#endif
