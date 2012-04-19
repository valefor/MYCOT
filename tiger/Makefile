# 
# Makefile for Tiger Compiler Alpha
#
AS =as
LD =ld
CC =gcc
CFLAG =-Wall -O -g
YACC =bison
YACC_FLAG = -dt -v
LEX	=flex

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
HEADERS = config.h st.h $(GEN_HDR)

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

clean:
	rm -f *.o *.s *.exe *.stackdump *.output
	rm -f $(GEN_SRC) $(GEN_HDR)

tiger_parser.c: tiger.y
	$(YACC) $(YACC_FLAG) -o $@ $<

tiger_lexer.c: tiger.l tiger_parser.c 
	$(LEX) --header-file=tiger_lexer.h -o $@ $<
