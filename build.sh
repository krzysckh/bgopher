#!/bin/sh

FBC="fbc"

BASFILES="client.bas bgopher.bas ui.bas"
BCFLAGS="-lang fb"
BLFLAGS=

TARGET="bgopher"

_die() {
  echo "  [FAIL]  $@"
  exit 1
}

compile() {
  echo "  [FBC]   $1"
  $FBC $BCFLAGS -m bgopher -c $1 || _die
}

link() {
  echo "  [FBLD]  $@"
  $FBC -x $TARGET $BLFLAGS $@ || _die
}

clean() {
  echo "  [RM]   *.o"
  rm -rf *.o $TARGET
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
