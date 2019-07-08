#!/usr/bin/env bash
set -x
date
RUNNING=$(argo list | grep -e Pedning -e Running | grep ${ARGO_NAME:-""} | wc -l)
echo "$RUNNING argo workflows are running"
if [ "$RUNNING" -lt "2" ]; then
   argo submit "$@"
fi
