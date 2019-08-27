#!/usr/bin/env bash
set -e
docker build --no-cache -f docker-ozone-schedule/Dockerfile . -t elek/ozone-schedule
docker push elek/ozone-schedule
