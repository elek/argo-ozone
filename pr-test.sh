#!/usr/bin/env bash
set -x
PR_INFO=$(curl "https://api.github.com/repos/apache/hadoop-ozone/pulls/$1" | jq -r ' .head.ref + " " + .head.repo.full_name')

BRANCH=$(echo $PR_INFO | awk -F "[ /]" '{print $1}')
ORG=$(echo $PR_INFO | awk -F "[ /]" '{print $2}')
REPO=$(echo $PR_INFO | awk -F "[ /]" '{print $3}')
PR_ID=$(curl "https://api.github.com/repos/apache/hadoop-ozone/pulls/$1" | jq -r '.title' | egrep -o '^[A-Z]{4,5}-[0-9]+' | tr '[[:upper:]]' '[[:lower:]]' | sed 's/-//')
argo submit -n argo -p org=$ORG -p repo=$REPO -p branch=$BRANCH -p update-github-status=true --generate-name=pr-$PR_ID- ozone-build.yaml
