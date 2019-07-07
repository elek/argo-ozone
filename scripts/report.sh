#!/usr/bin/env bash
DIR=${1:-$PWD}
INSTANCE=$(basename "$DIR")
JOB=$(basename $(dirname "$DIR"))

show_results(){
for test in $(grep -l -r --include="result" $1 $DIR); do

    TEST="$(basename $(dirname "$test"))"

   printf "[$TEST] $TEST check is $2\n\n"
   printf "   see: https://github.com/elek/ozone-ci/tree/master/$JOB/$INSTANCE/$(basename $TEST)/output.log\n\n\n"

done


}
echo "[OZONE] Ozone build is FAILED"

echo ""
echo "The following tests are FAILED:"
echo ""

show_results failure failed
show_results success
echo ""
echo "NOTE: this is an experimental build by Marton Elek, after the stabilization it can be moved to the builds.apache.org. Ping me with any questions/comments."
