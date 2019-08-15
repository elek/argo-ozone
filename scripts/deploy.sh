#!/usr/bin/env bash
set -x

NAMESPACE=ozone-daily

echo "Delete existing resources"
kubectl delete statefulset --all --namespace $NAMESPACE
kubectl delete daemonset --all --namespace $NAMESPACE
kubectl delete deployment --all --namespace $NAMESPACE
kubectl delete service --all --namespace $NAMESPACE
kubectl delete configmap --all --namespace $NAMESPACE
kubectl delete secret --all --namespace $NAMESPACE
kubectl delete pod --all --namespace $NAMESPACE

sleep 60

#install flekszible
sudo wget https://os.anzix.net/flekszible -O /usr/local/bin/flekszible
sudo chmod +x /usr/local/bin/flekszible

cd /workdir/examples/ozone-dev/
flekszible generate --namespace $NAMESPACE
kubectl apply -f .
sleep 300 #wait for the startup
