#!/usr/bin/env bash
set -x

SOURCE_TREE_REPO=${SOURCE_TREE_REPO:-https://github.com/apache/hadoop}
BUILD_ARTIFACT_REPO=${BUILD_ARTIFACT_REPO:-https://github.com/elek/ozone-ci-q4}
#Directory to store the output artifacts
export LOG_DIR=${LOG_DIR:-/tmp/log}

git clone --depth=1 $BUILD_ARTIFACT_REPO.git "$LOG_DIR"


#The working directory
BASE_DIR=${BASE_DIR:-/workdir}
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
  send_status $LOG_DIR "${JOB_NAME:-results}/$WORKFLOW_NAME/$TEST_TYPE" $BUILD_ARTIFACT_REPO $SOURCE_TREE_REPO
fi

set -o pipefail

# Apply optional patch if defined
if [ "$APPLY_PATCH" ]; then
    echo "Applying temporary fix patch: $APPLY_PATCH"
    curl -s "$APPLY_PATCH" | git apply - | tee -a "$OUTPUT_DIR/output.log"
fi

#workaround to seamlessly upgrade to newer acceptance.sh
if [ "$TEST_TYPE" == "acceptance" ]; then
   if [ ! -d "$BASE_DIR/hadoop-ozone/dist/target" ]; then
       "$BASE_DIR/hadoop-ozone/dev-support/checks/build.sh" | tee -a "$OUTPUT_DIR/output.log"
   fi
fi

#Remove empty elements of the $@ (argo workaround)
COMMAND=()
for PART in "$@"; do
   if [ "$PART" ]; then
       COMMAND+=("$PART")
   fi
done

"${COMMAND[@]}" 2>&1 | tee $OUTPUT_DIR/output.log

RESULT=$?

if [[ "$RESULT" == "0" ]]; then
  echo "success" >"$OUTPUT_DIR/result"
else
  echo "failure" >"$OUTPUT_DIR/result"
fi

git_commit_result

if [ "$UPDATE_GITHUB_STATUS" == "true" ]; then
  send_status $LOG_DIR "${JOB_NAME:-results}/$WORKFLOW_NAME/$TEST_TYPE" $BUILD_ARTIFACT_REPO $SOURCE_TREE_REPO
fi
exit $RESULT
