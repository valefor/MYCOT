# 
# Makefile for tiger-sample
# The purpose is making a tiny compiler for execise use
#
AS =as
LD =ld
CC =gcc
CFLAG =-Wall -O

ACHIIVES=*

.c.s:
	$(CC) $(CFLAG) \
	-S -o $*.s $<
.c.o:
	$(CC) $(CFLAG) \
	-c -o $*.o $<

OBJS = engine.o template.o

all: $(OBJS)
	$(LD) -r -o tinyUtil.o $(OBJS)

obj:
	$(CC) $(CFLAG) -c *.c

asm:
	$(CC) $(CFLAG) -S *.c

build:
	$(CC) -o calc $(OBJS)

debug:
	$(CC) -g -o calc *.c

clean:
	rm -f *.o *.s *.exe
