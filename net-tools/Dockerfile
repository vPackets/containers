# Use a smaller base image like Ubuntu Minimal
FROM ubuntu:22.04

# Author and Maintainer information
LABEL author="Nicolas Michel" \
      maintainer="nicolas@vpackets.net"

# Set noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install all required packages in a single layer to reduce size
RUN apt-get update && apt-get install -y \
    ansible \
    curl \
    dnsutils \
    hping3 \
    htop \
    httpie \
    iftop \
    iperf3 \
    iproute2 \
    iputils-ping \
    mtr \
    netcat \
    nmap \
    openssh-client \
    python3 \
    python3-pip \
    screen \
    sudo \
    tcpdump \
    tcptraceroute \
    telnet \
    tmux \
    tree \
    tshark \
    wget \
    neovim \
    man-db \
    traceroute \
    net-tools \
    bind9-host \
    jq \
    siege \
    wrk \
    unzip \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install additional Python packages
RUN pip3 install \
    netmiko \
    napalm \
    nornir \
    paramiko \
    pyntc \
    ncclient \
    scapy \
    pyyaml \
    requests \
    httpx

# Create a non-root user
RUN useradd -ms /bin/bash neteng && \
    echo "neteng ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/neteng

# Switch to the non-root user
USER neteng

# Set the working directory
WORKDIR /app
