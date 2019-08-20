#!/usr/bin/env bash
set -e
docker build --no-cache -f docker-ozone-klepif/Dockerfile . -t elek/ozone-klepif
docker push elek/ozone-klepif
