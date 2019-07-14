#!/usr/bin/env bash
DIR=${1:-$PWD}
INSTANCE=$(basename "$DIR")
JOB=$(basename $(dirname "$DIR"))

cd $DIR

show_results() {
   echo "-------------------------------"
   echo "The following tests are $2:"
   echo "-------------------------------"
   echo ""
   for test in $(grep -l -r --include="result" $1 $DIR); do

      TEST="$(basename $(dirname "$test"))"
      printf "[$TEST] $TEST check is $2\n\n"
      printf "   output: https://raw.githubusercontent.com/elek/ozone-ci/master/$JOB/$INSTANCE/$TEST/output.log\n\n\n"

      if [ "$TEST" == "acceptance" ]; then

         printf "   robot results: https://elek.github.io/ozone-ci/$JOB/$INSTANCE/acceptance/smokeresult/log.html\n\n\n"

      elif [ "$TEST" == "unit" ] || [ "$TEST" == "integration" ]; then

         printf "   Failing tests: \n\n"

         for TEST_RESULT_FILE in $(find $DIR/$TEST -name "*.txt" | grep -v output); do

            FAILURES=$(cat $TEST_RESULT_FILE | grep FAILURE | grep "Tests run" | awk '{print $18}' | sort | uniq)
      
            for FAILURE in $FAILURES; do
               printf "      $FAILURE\n"
               TEST_RESULT_LOCATION=$(realpath --relative-to=$DIR $TEST_RESULT_FILE)
               printf "            https://github.com/elek/ozone-ci/tree/master/$JOB/$INSTANCE/$TEST_RESULT_LOCATION\n\n"
            done

         done
         printf "\n\n"
      fi
   done
   echo ""
}

show_results failure FAILED

show_results success PASSED

echo ""
echo "NOTE: this is an experimental build by Marton Elek, after the stabilization it can be moved to the builds.apache.org. Ping me with any questions/comments."
