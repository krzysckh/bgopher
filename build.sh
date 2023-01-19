#!/bin/sh

# i have no clue how to compile freebasic correctly on openbsd
# if you use openbsd, please check if LDFLAGS are correct for your system

FBC="fbc"

BASFILES="client.bas bgopher.bas ui.bas"
BCFLAGS="-lang fb"
BLFLAGS=

CC=clang
CFLAGS=
LDFLAGS="-L/usr/local/lib -L/usr/local/lib/freebasic/openbsd-x86_64/ -lfb -lpthread -lcurses"

TARGET="bgopher"

_die() {
  echo "  [FAIL]  $@"
  exit 1
}

compile() {
  if [ `uname -s` = "OpenBSD" ]; then
    echo "  [FBC]   $1"
    fbc -gen gcc -r $1 -m bgopher || _die
    echo "  [CC]    `echo $1 | sed 's/bas/c/'`"
    $CC $CFLAGS -c $(echo $1 | sed 's/bas/c/') || _die
  else
    echo "  [FBC]   $1"
    $FBC $BCFLAGS -m bgopher -c $1 || _die
  fi
}

link() {
  if [ `uname -s` = "OpenBSD" ]; then
    echo "  [CCLD]  $@"
    $CC $LDFLAGS -o $TARGET $@ || _die
  else
    echo "  [FBLD]  $@"
    $FBC -x $TARGET $BLFLAGS $@ || _die
  fi
}

clean() {
  echo "  [RM]   *.o *.c $TARGT"
  rm -rf *.o *.c $TARGET
}

if [ "$1" = "clean" ]; then
  clean
elif [ "$1" = "install" ]; then
  echo "not yet"
else
  for f in $BASFILES; do
    compile $f
  done

  link $(echo $BASFILES | sed 's/bas/o/g')

  echo "  [INFO]  built $TARGET"
fi
