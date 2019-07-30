#!/usr/bin/env bash
argo submit -p notify=true -p branch=ozone-0.4.1 ozone-build.yaml --generate-name byscane-nightly-
