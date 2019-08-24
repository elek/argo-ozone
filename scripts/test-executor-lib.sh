#!/usr/bin/env bash

git_commit_result() {
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
  LOG_DIR="$1"
  TEST_LOCATION="$2"

  TEST_REPORT_DIR="$LOG_DIR/$TEST_LOCATION"
  GIT_REF=$(head -n1 $TEST_REPORT_DIR/../HEAD.txt | awk '{print $2}')
  TEST_NAME=$(basename $TEST_REPORT_DIR)

  SUMMARY_FILE=""
  if [ -f "$TEST_REPORT_DIR/summary.html" ]; then
     SUMMARY_FILE="summary.html"
  elif [ -f "$TEST_REPORT_DIR/summary.md" ]; then
     SUMMARY_FILE="summary.md"
  elif [ -f "$TEST_REPORT_DIR/summary.txt" ]; then
     SUMMARY_FILE="summary.txt"
  fi

  if [ ! -f "$TEST_REPORT_DIR/output.log" ]; then
     STATUS="pending"
     MESSAGE="$TEST_NAME check is in progress..."
  else
     STATUS=$(cat "$TEST_REPORT_DIR/result")
     MESSAGE="$TEST_NAME is finished with $STATUS status"
     if [ -f "$TEST_REPORT_DIR/failures" ]; then
        FAILURES=$(cat "$TEST_REPORT_DIR/failures")
        if [ "$FAILURES" -gt "0" ]; then
           MESSAGE="$TEST_NAME check is finished with $FAILURES violation"
           if [ "$FAILURES" -gt "1" ]; then
              MESSAGE="${MESSAGE}s"
           fi
        fi
     fi
  fi

  cat <<EOF >/tmp/data.json
{
  "state": "$STATUS",
  "target_url": "https://github.com/elek/ozone-ci/tree/master/$TEST_LOCATION/$SUMMARY_FILE",
  "description": "$MESSAGE",
  "context": "ci/$TEST_NAME"
}
EOF
  cat /tmp/data.json
  curl --data @/tmp/data.json -v -u $GITHUB_SUSER:$GITHUB_TOKEN -H "Accept: application/vnd.github.antiope-preview+json" -L https://api.github.com/repos/${GIT_ORG:-apache}/hadoop/statuses/$GIT_REF

}

