#!/usr/bin/env sh
set -x
TMP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/tmp"

source "$TMP_DIR/../../scripts/test-executor-lib.sh"

send_status `pwd` $1