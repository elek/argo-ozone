#!/usr/bin/env bash
set -x

#Directory to store the output artifacts
export LOG_DIR=${LOG_DIR:-/tmp/log}

git clone https://github.com/elek/ozone-ci.git "$LOG_DIR"


#The working directory
BASE_DIR=${BASE_DIR:-/tmp/workdir}
mkdir -p "$BASE_DIR"

if [ -z "$WORKFLOW_NAME" ]; then
  echo '$WORKFLOW_NAME should be set'
  exit 1
fi

mkdir -p $BASE_DIR
if [[ "$BASE_DIR" ]]; then
  cd $BASE_DIR
fi

JOB_NAME=$(cut -d '-' -f 1 <<<"$WORKFLOW_NAME")
# WORKFLOW_NAME=
# TEST_TYPE=

export OUTPUT_DIR=$LOG_DIR/${JOB_NAME:-results}/$WORKFLOW_NAME/$TEST_TYPE
mkdir -p $OUTPUT_DIR

cd $BASE_DIR

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/test-executor-lib.sh"

if [ "$UPDATE_GITHUB_STATUS" == "true" ]; then
  send_status $LOG_DIR "${JOB_NAME:-results}/$WORKFLOW_NAME/$TEST_TYPE"
fi

set -o pipefail

# Apply optional patch if defined
if [ "$APPLY_PATCH" ]; then
    echo "Applying tempporary fix patch: $APPLY_PATCH"
    curl -s "$APPLY_PATCH" | git apply - | tee -a "$OUTPUT_DIR/output.log"
fi

#workaround to seamlessly upgrade to newer acceptance.sh
if [ "$TEST_TYPE" == "acceptance" ]; then
   if [ ! -d "$BASE_DIR/hadoop-ozone/dist/target" ]; then
       "$BASE_DIR/hadoop-ozone/dev-support/checks/build.sh" | tee -a "$OUTPUT_DIR/output.log"
   fi
fi

"$@" 2>&1 | tee $OUTPUT_DIR/output.log

RESULT=$?

if [[ "$RESULT" == "0" ]]; then
  echo "success" >"$OUTPUT_DIR/result"
else
  echo "failure" >"$OUTPUT_DIR/result"
fi

git_commit_result

if [ "$UPDATE_GITHUB_STATUS" == "true" ]; then
  send_status $LOG_DIR "${JOB_NAME:-results}/$WORKFLOW_NAME/$TEST_TYPE"
fi
exit $RESULT
