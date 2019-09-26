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
  BUILD_ARTIFACT_REPO="$3"
  SOURCE_TREE_REPO="$4"
  TEST_REPORT_DIR="$LOG_DIR/$TEST_LOCATION"
  GIT_REF=$(head -n1 $TEST_REPORT_DIR/../HEAD.txt | awk '{print $2}')
  TEST_NAME=$(basename $TEST_REPORT_DIR)

  GITHUB_SOURCE_URL="$BUILD_ARTIFACT_REPO/tree/master/$TEST_LOCATION"
  BUILD_ARTIFACT_REPO_PAGE=$(echo $BUILD_ARTIFACT_REPO | sed 's/\/\/github.com//g' | sed -E 's/https:\/([^\/]+)/https:\/\/\1.github.io/g')
  GITHUB_PAGE_URL="$BUILD_ARTIFACT_REPO_PAGE/$TEST_LOCATION"

  TARGET_URL="$GITHUB_SOURCE_URL"

  if [ -s "$TEST_REPORT_DIR/summary.html" ]; then
     TARGET_URL="$GITHUB_PAGE_URL/summary.html"
  elif [ -s "$TEST_REPORT_DIR/summary.md" ]; then
     TARGET_URL="$GITHUB_SOURCE_URL/summary.md"
  elif [ -s "$TEST_REPORT_DIR/summary.txt" ]; then
     TARGET_URL="$GITHUB_SOURCE_URL/summary.txt"
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
  "target_url": "$TARGET_URL",
  "description": "$MESSAGE",
  "context": "ci/$TEST_NAME"
}
EOF
  cat /tmp/data.json
  curl --data @/tmp/data.json -v -u $GITHUB_SUSER:$GITHUB_TOKEN -H "Accept: application/vnd.github.antiope-preview+json" -L $(echo $SOURCE_TREE_REPO | sed 's/github.com/api.github.com/repos/g')/statuses/$GIT_REF

}

