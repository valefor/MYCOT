# 
# Makefile for tiger-sample
# The purpose is making a tiny compiler for execise use
#
AS =as
LD =ld
CC =gcc
CFLAG =-Wall -O
YACC =bison -d
LEX	=flex

ACHIIVES=*

.c.s:
	$(CC) $(CFLAG) \
	-S -o $*.s $<
.c.o:
	$(CC) $(CFLAG) \
	-c -o $*.o $<

OBJS = hash.o test.o

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

clean:
	rm -f *.o *.s *.exe *.stackdump

