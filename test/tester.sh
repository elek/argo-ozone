#!/usr/bin/env sh
set -x
TMP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/tmp"

rm -rf $TMP_DIR

export BASE_DIR="$TMP_DIR/workdir"
export LOG_DIR="$TMP_DIR/log"
export REPO_DIR="$TMP_DIR/repo"
export TEST_TYPE="demo"
mkdir -p $BASE_DIR
mkdir -p $LOG_DIR
mkdir -p $REPO_DIR
cat << EOF > $BASE_DIR/integration.sh
#!/usr/bin/env bash
echo "abrakadabra"
echo "$@"
EOF
chmod +x $BASE_DIR/integration.sh

cd $REPO_DIR && git init --bare

cd $LOG_DIR && git init && \
    git remote add origin file://$TMP_DIR/repo && \
    touch init && \
    git add init && \
    git commit -m "initial commmit" && \
    git push origin master && \
    git branch --set-upstream-to=origin/master master \
    && cd -

export WORKFLOW_NAME=test-workflow

"$TMP_DIR/../../scripts/test-executor.sh" $@
