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
    tmux \
    nmap

COPY network-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/network-config.sh
# Set the default command to launch when starting the container
# CMD ["/usr/local/bin/network-config.sh"]
CMD ["sh"]


