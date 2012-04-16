# 
# Makefile for Tiger Compiler Alpha
#
AS =as
LD =ld
CC =gcc
CFLAG =-Wall -O
YACC =bison
YACC_FLAG = -dt -v
LEX	=flex

ACHIIVES=*

.c.s:
	$(CC) $(CFLAG) \
	-S -o $*.s $<
.c.o:
	$(CC) $(CFLAG) \
	-c -o $*.o $<

GEN_SRC = tiger_parser.c tiger_lexer.c
GEN_HDR = $(GEN_SRC:.c=.h)

OBJS = $(GEN_SRC:.c=.o) hash.o test.o 

all: $(OBJS)
	$(LD) -r -o testMain.o $(OBJS)

obj:
	$(CC) $(CFLAG) -c *.c

asm:
	$(CC) $(CFLAG) -S *.c

build:$(OBJS)
	$(CC) -o testMain $(OBJS)

debug:
	$(CC) -g -o testMain *.c

lexer:tiger_lexer.o
	$(CC) -o $@ $<

clean:
	rm -f *.o *.s *.exe *.stackdump *.output
	rm -f $(GEN_SRC) $(GEN_HDR)

tiger_parser.c: tiger.y
	$(YACC) $(YACC_FLAG) -o $@ $<

tiger_lexer.c: tiger.l tiger_parser.c 
	$(LEX) --header-file=tiger_lexer.h -o $@ $<
