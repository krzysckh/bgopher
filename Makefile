OS=`uname | tr '[A-Z]' '[a-z]'`
OS=openbsd

.SUFFIXES: .bas .o

FBC=fbc
TARGET=bgopher
MAIN=bgopher
BASFILES=client.bas bgopher.bas ui.bas
OFILES=client.o bgopher.o ui.o
BCFLAGS=-lang fb -g
BLFLAGS=

.if ${OS} == "openbsd"
CC=clang
CFLAGS=-w -g
LDFLAGS=-L/usr/local/lib -L/usr/local/lib/freebasic/openbsd-x86_64/ -lfb \
	-lpthread -lcurses -lm
.endif

.bas.o:
.if ${OS} == "linux"
	@echo "  [FBC]    $<"
	${FBC} ${BCFLAGS} -m ${MAIN} -c $<
.elif ${OS} == "openbsd"
	@echo "  [FBC]    $<"
	@${FBC} -gen gcc -r $< -m ${MAIN}
	@echo "  [CC]     `echo $< | sed 's/bas/c/'`"
	@${CC} ${CFLAGS} -c `echo $< | sed 's/bas/c/'`
.else
	@echo "unsupported os ${OS} - try tinkering with Makefile"
	@false
.endif

target: ${OFILES}
.if ${OS} == "linux"
	@echo "  [FBLD]   $OFILES"
	${FBC} -x ${TARGET} ${BLFLAGS} ${OFILES}
.elif ${OS} == "openbsd"
	@echo "  [CCLD]   ${OFILES}"
	@${CC} ${LDFLAGS} -o ${TARGET} ${OFILES}
.endif

clean:
	rm -rf *.o *.c ${TARGET}
all: target
