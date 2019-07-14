#!/usr/bin/env bash
set -x

export LOG_DIR=${LOG_DIR:-/tmp/log}

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
REPORT_REPO=${REPORT_REPO:-https://github.com/elek/ozone-ci.git}
GITHUB_USER=${GITHUB_USER:-elek}

git-setup-identity() {
  git config --global user.email "ci@anzix.net"
  git config --global user.name "CI"
  git clone "$REPORT_REPO" "$LOG_DIR"
  git config --global credential.helper store
  echo https://$GITHUB_USER:${GITHUB_TOKEN}@github.com >~/.git-credentials
  chmod 700 ~/.git-credentials
}

git-commit-result() {
  cd $LOG_DIR
  git add .
  git commit -a -m "CI commit"
  for i in $(seq 1 10); do
    git pull --rebase
    git push
    if [[ "$?" == "0" ]]; then
      break
    fi
    sleep 1
  done
}

send_status() {
  if [ "$UPDATE_GITHUB_STATUS" == "true" ]; then
    GIT_REF=$(head -n1 $LOG_DIR/$JOB_NAME/$WORKFLOW_NAME/HEAD.txt | awk '{print $2}')
    cat <<EOF >/tmp/data.json
  {
    "state": "$1",
    "target_url": "https://github.com/elek/ozone-ci/tree/master/$JOB_NAME/$WORKFLOW_NAME/$TEST_TYPE",
    "description": "$TEST_TYPE result: $1!",
    "context": "ci/$TEST_TYPE"
  }
EOF
    cat /tmp/data.json
    curl --data @/tmp/data.json -v -u elek:$GITHUB_TOKEN -H "Accept: application/vnd.github.antiope-preview+json" -L https://api.github.com/repos/apache/hadoop/statuses/$GIT_REF
  fi
}

git-setup-identity

export OUTPUT_DIR=$LOG_DIR/${JOB_NAME:-results}/$WORKFLOW_NAME/$TEST_TYPE
mkdir -p $OUTPUT_DIR

cd $BASE_DIR
send_status pending
set -o pipefail

"$@" 2>&1 | tee $OUTPUT_DIR/output.log

RESULT=$?

if [[ "$RESULT" == "0" ]]; then
  send_status success
  echo "success" >"$OUTPUT_DIR/result"
else
  send_status failure
  echo "failure" >"$OUTPUT_DIR/result"
fi
git-commit-result

exit $RESULT
