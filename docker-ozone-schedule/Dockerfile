FROM ubuntu
RUN apt-get update && apt-get install -y wget
RUN wget https://github.com/argoproj/argo/releases/download/v2.3.0/argo-linux-amd64 -O /usr/local/bin/argo && chmod +x /usr/local/bin/argo
ADD *.yaml /tmp/
ADD docker-ozone-schedule/limit.sh /usr/local/bin/limit.sh
