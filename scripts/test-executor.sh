#!/usr/bin/env bash
set -x

export LOG_DIR=${LOG_DIR:-/tmp/log}

#The working directory
BASE_DIR=${BASE_DIR:-/opt/src}
mkdir -p "$BASE_DIR"

if [ -z "$WORKFLOW_NAME" ]; then
   echo '$WORKFLOW_NAME should be set'
   exit 1
fi

mkdir -p $BASE_DIR
if [[ "$BASE_DIR" ]]; then
    cd $BASE_DIR
fi

JOB_NAME=$(cut -d '-' -f 1 <<< "$WORKFLOW_NAME")
# WORKFLOW_NAME=
# TEST_TYPE=
REPORT_REPO=${REPORT_REPO:-https://github.com/elek/ozone-ci.git}
GITHUB_USER=${GITHUB_USER:-elek}

git-setup-identity(){
   git config --global user.email "ci@anzix.net"
   git config --global user.name "CI"
   git clone "$REPORT_REPO" "$LOG_DIR"
   git config --global credential.helper store
   echo https://$GITHUB_USER:${GITHUB_TOKEN}@github.com > ~/.git-credentials
   chmod 700 ~/.git-credentials
}

git-commit-result(){
  cd $LOG_DIR
  git add .
  git commit -a -m "CI commit"
  for i in `seq 1 10`; do
    git pull --rebase
    git push
    if [[ "$?" == "0" ]]; then
      break
    fi
    sleep 1
  done
}

send_status(){
  cat << EOF > /tmp/data.json
  {
    "state": "$1",
    "target_url": "https://s3.amazonaws.com/ozone-build/$WORKFLOW_NAME/$TEST_TYPE/main.log",
    "description": "The $TEST_TYPE run succeeded!",
    "context": "ci/$TEST_TYPE"
  }
EOF
  echo $1
  #cat /tmp/data.json
  #curl --data @/tmp/data.json -v  -u elek:$GITHUB_TOKEN -H "Accept: application/vnd.github.antiope-preview+json" -L https://api.github.com/repos/elek/hadoop/statuses/$GIT_REF
}



git-setup-identity

export OUTPUT_DIR=$LOG_DIR/${JOB_NAME:-results}/$WORKFLOW_NAME/$TEST_TYPE
mkdir -p $OUTPUT_DIR


cd $BASE_DIR
send_status pending
set -o pipefail

"$@" | tee $OUTPUT_DIR/output.log

RESULT=$?

if [[ "$RESULT" == "0" ]]; then
  send_status success
  echo "success" > "$OUTPUT_DIR/result"
else
  send_status failure
  echo "failure" > "$OUTPUT_DIR/result"
fi
git-commit-result

exit $RESULT
