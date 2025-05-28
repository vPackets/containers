FROM ubuntu:22.04

LABEL maintainer="nicmcl@cisco.com"

RUN apt-get update && apt-get install -y \
    iproute2 iputils-ping curl net-tools \
    && rm -rf /var/lib/apt/lists/*

COPY network-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/network-config.sh

CMD ["sh"]


