.PHONY: clean distclean

# OS type: Linux/Win DJGPP
ifdef OS
   EXE=.exe
else
   EXE=
endif

CFILES   = lexer.c parser.c
HFILES   = parser.h
OBJFILES = $(patsubst %.c,%.o,$(CFILES))
EXEFILES = compiler$(EXE)
SRCFILES = $(HFILES) $(CFILES) lexer.l parser.y

CC=gcc
CFLAGS=-Wall -ansi -pedantic -g

%.c: %.y

compiler$(EXE): lexer.o parser.tab.o
	$(CC) $(CFLAGS) -o $@ $^

lexer.c: lexer.l
	flex -it lexer.l >lexer.c

parser.tab.c parser.tab.h: parser.y
	bison -dv parser.y

lexer.o : lexer.c parser.tab.h
	$(CC) $(CFLAGS) -lfl -c -o $@ $<

parser.tab.o: parser.tab.c

clean:
	$(RM) $(OBJFILES) *~ lexer.c parser.tab.c parser.tab.h

distclean: clean
	$(RM) $(EXEFILES) parser.output
