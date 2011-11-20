# 
# Makefile for tiger-sample
# The purpose is making an tiny compiler for execise use
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

OBJS = tiny_types.o tiny_util.o tiny_main.o

all: $(OBJS)
	$(LD) -r -o tinyUtil.o $(OBJS)

obj:
	$(CC) $(CFLAG) -c *.c

asm:
	$(CC) $(CFLAG) -S *.c

build:
	$(CC) -o tinyMain $(OBJS)

debug:
	$(CC) -g -o tinyMain *.c

clean:
	rm -f *.o *.s
