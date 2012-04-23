#
# @Proj:Tiger Compiler
#
# @FileDesc:{ /$The Makefile$\ }
# 
# @Author:{
#  Name  : Adrian Hu
#  Email : adrain.f.tepes@gmail.com
# }
# 
#
# @Progress:{
# 
# }
# 
# @Module:{
#  LocalMoudle:utils
# }
# 
# @CGL:{
#  Contract: Disobey
# }
# 
# @Doc:{
#
# }
#****** THIS LINE IS 80 CHARACTERS WIDE - DO *NOT* EXCEED 80 CHARACTERS! ******# 
# 
#
AS =as
LD =ld
CC =gcc
YACC =bison
LEX	=flex

# Flags
HDR_DIR =include/
CFLAG = -I$(HDR_DIR) -Wall -O -g
YACC_FLAG = -dt -v

ACHIIVES=tiger

.c.s:
	$(CC) $(CFLAG) \
	-S -o $*.s $<
.c.o:
	$(CC) $(CFLAG) \
	-c -o $*.o $<

TEST_TARGET = testMain
TEST_OBJS = test.o
GEN_SRC = tiger_parser.c tiger_lexer.c
GEN_HDR = $(GEN_SRC:.c=.h)
HEADERS = $(HDR_DIR)*.h

OBJS = $(GEN_SRC:.c=.o) hash.o st.o

$(OBJS): $(GEN_SRC) $(HEADERS)

all: $(OBJS)
	$(LD) -r -o tiger.o $(OBJS)

obj:
	$(CC) $(CFLAG) -c *.c

asm:
	$(CC) $(CFLAG) -S *.c

build:$(OBJS)
	$(CC) -o $(ACHIIVES) $(OBJS)

test:$(OBJS) $(TEST_OBJS)
	$(CC) $(CFLAG) -o $(TEST_TARGET) $(OBJS) $(TEST_OBJS)

debug:
	$(CC) -g -o $(ACHIIVES) *.c

lexer:tiger_lexer.o
	$(CC) -o $@ $<

ctags:$(GEN_SRC)
	ctags -R

clean:
	rm -f *.o *.s *.exe *.stackdump *.output tags
	rm -f $(GEN_SRC) $(GEN_HDR)

tiger_parser.c: tiger.y
	$(YACC) $(YACC_FLAG) -o $@ $<

tiger_lexer.c: tiger.l tiger_parser.c 
	$(LEX) --header-file=tiger_lexer.h -o $@ $<
