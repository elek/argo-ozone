#!/usr/bin/env bash
docker build -f docker-ozone-schedule/Dockerfile . -t elek/ozone-schedule
docker push elek/ozone-schedule
