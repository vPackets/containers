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
    nmap
# Set the default command to launch when starting the container
CMD ["sh"]


