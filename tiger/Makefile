# 
# Makefile for tiger-sample
# The purpose is making a tiny compiler for execise use
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

OBJS = hash.o test.o tiger_parser.o tiger_lexer.o
GENS = tiger_parser.c tiger_lexer.c

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

gen:
	$(YACC) tiger.y

clean:
	rm -f *.o *.s *.exe *.stackdump
	rm -f tiger_parser.* tiger_lexer.*

tiger_parser.c: tiger.y
	$(YACC) $(YACC_FLAG) -o $@ $<

tiger_lexer.c: tiger.l
	$(LEX) -o $@ $<
