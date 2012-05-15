/*
 * @Proj:Tiger Compiler
 *
 * @FileDesc:{ /$ Tiger Header File$\ }
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
 *
 *  ( abstract module ) which is a logically module
 *  [ real module ]
 *
 *  *** MODULE TREE ***
 *
 *                       [tiger]
 *                          |
 *                          |   *** The Fundamental Functionality 
 *                          |
 *                          |                /  [ ]
 *                          |               /
 *                          |---------[cli]---- [ compilerOptions ]
 *                          |               \
 *                          |                \  [ ]
 *                          |
 *                          |
 *                          |                   / 
 *                          |                  /  [ stdtypes(types) ]
 *                          |                 /
 *                          |---------[utils]---- [ utils(Macros,functions) ]
 *                          |                 \
 *                          |                  \  [ test ]
 *                          |                   \ [ symbolTable ]
 *                          |
 *                          |
 *   -----------------------+-----------------------
 *  /                       |                       \
 *  | *** Syntax Parser     |                       |
 *  |                       |                       |
 *  |                       |                       |
 *  |                       |                       |
 *  |                       |                       |
 *  |                       |                       |
 *  |         / [ lexer ]   |                       |
 *  |        /      |       |                       |
 *  |       /       v       |                       |
 *  `--(sp)---- [ parser ]  |                       |
 *          \       |       |                       |
 *           \      v       |                       |
 *            \ [absSyntax] |                       |
 *                          |                       |
 *                          |                       |
 *                          |                       |
 *                          | *** Intermediate Code |
 *                          `-------- TO BE CONTINUED
 *                                                  |
 *                                                  |
 *                                                  |
 *                                                  |
 *                                                  |
 *                                                  |
 *                                                  |
 *                                  Target code *** |
 *                      TO BE CONTINUED-------------/
 *
 *
 *
 *
 *
 *
 *
 *
 * }
 * 
 * @CGL:{
 *  Contract: Obey
 * }
 * 
 * @Doc:{
 *
 * <<The CGL(Coding Guide Line)>>
 * All the naming should be as symbolic as possible,then as laconic as possible
 * 
 * The naming out of this program's scope will not be constrained,e.g the yacc
 * or lex built-in declaration & macro.
 * 
 * Use all uppercase letters words carefully.Don't mix them up with MARCO 
 *
 *  1. Nameing:
 *    #1 Declaration:
 *      $1. <scopeSpec><[Module_]><Name> : 
 *        %1. <scopeSpec> ~~~ scope specifers:
 *          &1. g_  : global variable
 *          &2. v_  : local variable
 *          &3. pm  : parameter.
 *          &4. cl_ : local const,e.g static const or static
 *          &5. cg_ : global const
 *
 *        %2. [<Module_>] ~~~ module name is optional
 *
 *        %3. xxx_<Name>:the <Name> is recommended to be written in camelStyle,
 *              underscode_style is not recommended
 *
 *      $2. <typeSpec><Name>:Sometimes a local variable "v_murMurMur" isn't fit
 *            your style,there are so many local variables,this rule use type
 *            specifer to make variables more accurate.
 *        %1. <typeSpec>:
 *          &1. i : integer
 *          &2. b : boolean
 *          &3. s : string
 *          &4. c : char
 *          &5. p : pointer
 *          &6. t : user defined type
 *
 *        %2. <Name> : follow rule:[$1%3],then what ever...
 *
 *      $3. xxx_<Name>_<Typedef_tag> :the tailed <TypeDef_tag>('_t') is allowed 
 *
 *      $4. temporary variables ain't forced to follow above rules,e.g i,j,...
 *
 *      $5. abbrevs in Naming can be written in UPPERCASE,e.g tg_KINP_s
 *
 *    #2 Definition:
 *      $1. MARCO : macro definitions with UPPERCASE letters
 *      $2. f_<Module>_<funcName> : local variables 
 *      $3. s_<structName> : struct
 *      $4. e_<enumName> : enumeration,the identifiers in enumeration list should
 *          be written with uppercase letters
 *
 *  2. Consistency:
 *
 *  3. Comments:
 *    #1. "//" Only use this for single line comment.
 *    #2. the function header comments are not mandatory,but it'll be greate
 *      if it has,it will help others understand the function more quickly.
 *  The Tiger specified header file which contained Tiger compiler dedicated
 *  definitions.
 *
 *  x. Abbreviations:
 *      tg      <->     tiger
 *      cli     <->     command line interface
 *      st      <->     symbol table
 *      lxr     <->     lexer
 *      psr     <->     parser
 *      param   <->     parameter
 *
 * }
 ****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******/
#include <stdio.h>
#include <stdlib.h>
#include "stdtypes.h"
#include "utils.h"
#include "config.h"

// tiger ID
typedef unsigned long tg_id_t;

// tiger VALUE
typedef unsigned long tg_value_t;
