#!/usr/bin/env bash
DIR=${1:-$PWD}
INSTANCE=$(basename "$DIR")
JOB=$(basename $(dirname "$DIR"))
BUILD_ARTIFACT_REPO=${BUILD_ARTIFACT_REPO:-https://github.com/elek/ozone-ci-q4}

cd $DIR
show_results() {
   echo "# Tests with $1 status"
   echo ""
   for test in $(grep -l -r --include="result" $1 $DIR); do
      TEST="$(basename $(dirname "$test"))"
      RELATIVE_PATH="$JOB/$INSTANCE/$TEST"

      echo "## $TEST check is finished with $1 status"
      echo ""
      echo "   * [output]($(echo $BUILD_ARTIFACT_REPO | sed 's/github.com/raw.githubusercontent.com/g')/master/$RELATIVE_PATH/output.log)"

      echo "   * [all collected results]($BUILD_ARTIFACT_REPO/tree/master/$RELATIVE_PATH)"

      GITHUB_SOURCE_URL="$BUILD_ARTIFACT_REPO/tree/master/$RELATIVE_PATH"
      GITHUB_PAGE_URL="$(echo $BUILD_ARTIFACT_REPO | sed 's/\/\/github.com//g' | sed -E 's/https:\/([^\/]+)/https:\/\/\1.github.io/g')/$RELATIVE_PATH"

      if [ -s "$(dirname "$test")/summary.html" ]; then
         echo "   * [summary.html]($GITHUB_PAGE_URL/summary.html)"
      fi

      if [ -s "$(dirname "$test")/summary.md" ]; then
         echo "   * [summary.md]($GITHUB_SOURCE_URL/summary.md)"
      fi

      if [ -s "$(dirname "$test")/summary.txt" ]; then
         echo "   * [summary.txt]($GITHUB_SOURCE_URL/summary.txt)"
      fi

      echo ""

      if [ -s "$(dirname "$test")/summary.md" ]; then
         cat "$(dirname "$test")/summary.md"
      elif [ -s "$(dirname "$test")/summary.txt" ]; then
         cat "$(dirname "$test")/summary.txt"
      fi

      echo ""

   done
   echo ""
}

show_results failure

show_results success

cat << EOF

# References

 * All the results are saved to [here]($BUILD_ARTIFACT_REPO/tree/master/$JOB/$INSTANCE/)
 * The definition is the build is committed to [here](https://github.com/elek/argo-ozone)
    * The build is defined in [this argo workflow XML](https://github.com/elek/argo-ozone/blob/master/ozone-build.yaml)
    * This report is assembled by the [report script](https://github.com/elek/argo-ozone/blob/master/scripts/report.sh)

This is an experimental build and eventually can be merged to the Apache Hadoop Ozone source tree (after some testing).

In case of any question please contact with elek dot apache dot org.
EOF
