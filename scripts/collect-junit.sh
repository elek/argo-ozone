#!/usr/bin/env bash
set -x
SRCDIR="${1:-.}"
DESTDIR="${2:-$SRCDIR/surefire}"
mkdir -p $DESTDIR
for dir in $(find "$SRCDIR" -name surefire-reports); do
   NAME=$(realpath --relative-to="$SRCDIR" $dir/../..)
   mkdir -p $(dirname "$DESTDIR/$NAME")
   cp -r $dir "$DESTDIR/$NAME"
done
