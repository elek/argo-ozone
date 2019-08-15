#!/usr/bin/env bash
NAMESPACE=ozone-daily
kubectl -n ozone-daily exec scm-0 -- ozone freon rk --numOfVolumes=1 --numOfBuckets=10 --numOfKeys=1000 --replicationType=RATIS --factor=THREE
sleep 100000
