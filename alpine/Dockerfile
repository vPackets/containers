# version : vpackets/alpine-tools:0.0.1 => https://hub.docker.com/repository/docker/vpackets/alpine-tools/general

# docker push vpackets/alpine-tools

# Use Alpine Linux as the base image
FROM alpine:latest

# Label the image
LABEL maintainer="nicolas@vpackets.net"

# Update package list and install network tools
RUN apk add --no-cache bash \
    iputils \
    iperf3 \
    mtr \
    bind-tools \
    netcat-openbsd \
    curl \
    python3 \
    nmap \
    tcpdump \
    tshark
# Set the default command to launch when starting the container
CMD ["sh"]


