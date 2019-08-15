#!/usr/bin/env bash
NAMESPACE=ozone-daily
kubectl -n ozone-daily exec scm-0 -- ozone freon rk --numOfVolumes=1 --numOfBuckets=10 --numOfKeys=1000 --replicationType=RATIS --factor=THREE

#output dir if $OUTPUT_DIR is not set
mkdir -p /tmp/results

TO=$(date +%s)
FROM=$(date -d "-10minutes" +%s)
curl -v "http://prometheus.${NAMESPACE}.svc.cluster.local:9090/api/v1/query_range?query=rate(om_metrics_num_key_allocate\[1m\])&start=${FROM}&end=${TO}&step=15s" | jq '.' > ${OUTPUT_DIR:-/tmp/results}/om_metrics_num_key_allocate.json

