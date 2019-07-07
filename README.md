# Argo workflow to run Apache Hadoop Ozone 

This repository contains workflow definitions to run [Apache Hadoop Ozone](http://hadoop.apache.org/ozone/) with the help of [Argo workflow](https://github.com/argoproj/argo).

## Install

(1) Configure your github token:

```
kubectl create secret generic github-token --from-literal=secret=$GITHUB_TOKEN
```

(2) Deploy argo.


## Run

```
argo submit  -p job=HDDS-1735 -p branch=HDDS-1735 ozone-build.yaml --generate-name=ozone-hdds-1735-
```
