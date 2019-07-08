#!/usr/bin/env bash
DIR=${1:-$PWD}
INSTANCE=$(basename "$DIR")
JOB=$(basename $(dirname "$DIR"))

show_results() {
   echo "-------------------------------"
   echo "The following tests are $2:"
   echo "-------------------------------"
   echo ""
   for test in $(grep -l -r --include="result" $1 $DIR); do

      TEST="$(basename $(dirname "$test"))"

      printf "[$TEST] $TEST check is $2\n\n"
      printf "   see: https://raw.githubusercontent.com/elek/ozone-ci/master/$JOB/$INSTANCE/$(basename $TEST)/output.log\n\n\n"

      

   done
   echo ""
}

show_results failure FAILED

show_results success PASSED

echo ""
echo "NOTE: this is an experimental build by Marton Elek, after the stabilization it can be moved to the builds.apache.org. Ping me with any questions/comments."
