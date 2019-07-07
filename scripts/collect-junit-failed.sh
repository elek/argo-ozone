#!/usr/bin/env bash

# This script collects the junit report files of the FAILED tests from a source maven tree to a report dir

set -x
SRCDIR="${1:-.}"
DESTDIR="${2:-$SRCDIR/surefire}"
mkdir -p $DESTDIR
for dir in $(find "$SRCDIR" -name surefire-reports); do
   for file in $(grep -l -r FAILURE --include="*.txt" $dir | grep -v output.txt ); do
      DIR=$(dirname $file)
      FILENAME=$(basename $file)
      FILENAME="${FILENAME%.*}"
      DESTDIRNAME=$(realpath --relative-to="$SRCDIR" $dir/../..)
      mkdir -p "$DESTDIR/$DESTDIRNAME"
      cp -r "$DIR/"*$FILENAME* "$DESTDIR/$DESTDIRNAME/"
   done 
done
