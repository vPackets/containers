FROM ubuntu:22.04

LABEL author="Nicolas Michel"
LABEL maintainer="nicmcl@cisco.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# =============================================================================
# 1. Install Full Networking Stack, Troubleshooting, & Automation Tools
# =============================================================================
# Combined and deduplicated list of APT packages from both environments
RUN apt-get update && apt-get install -y \
    ansible \
    bind9-host \
    ca-certificates \
    conntrack \
    curl \
    dnsutils \
    ethtool \
    fping \
    hping3 \
    htop \
    httpie \
    iftop \
    ipcalc \
    iperf3 \
    iproute2 \
    iputils-arping \
    iputils-ping \
    iputils-tracepath \
    jq \
    lldpd \
    man-db \
    mtr-tiny \
    ndisc6 \
    net-tools \
    netcat-openbsd \
    neovim \
    nmap \
    openssh-client \
    openssh-server \
    python3 \
    python3-pip \
    screen \
    siege \
    socat \
    sudo \
    tcpdump \
    tcptraceroute \
    telnet \
    tmux \
    traceroute \
    tree \
    tshark \
    unzip \
    wget \
    whois \
    wrk \
    zip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# =============================================================================
# 2. Python-based NetDevOps Tools
# =============================================================================
# Combined PIP libraries for Nornir, Netmiko, Scapy, and API interactions
RUN pip3 install --no-cache-dir \
    httpx \
    napalm \
    ncclient \
    netmiko \
    nornir \
    paramiko \
    pyntc \
    pyyaml \
    requests \
    scapy

# =============================================================================
# 3. SSH Runtime Directory
# =============================================================================
# Required for the SSH daemon to start properly in a container
RUN mkdir -p /run/sshd

# =============================================================================
# 4. Users (cisco, admin, neteng)
# =============================================================================
# Creating the default 'cisco' user with the 'cisco' password so your Mac's 
# sshpass alias works instantly, alongside other standard users.
RUN useradd -m -s /bin/bash cisco && echo "cisco:cisco" | chpasswd && usermod -aG sudo cisco \
 && useradd -m -s /bin/bash admin && echo "admin:cisco123" | chpasswd && usermod -aG sudo admin \
 && useradd -m -s /bin/bash neteng && echo "neteng:cisco123" | chpasswd && usermod -aG sudo neteng

# =============================================================================
# 5. Passwordless Sudo (Essential for lab speed)
# =============================================================================
RUN echo "cisco ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cisco \
 && echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin \
 && echo "neteng ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/neteng \
 && chmod 0440 /etc/sudoers.d/cisco \
 && chmod 0440 /etc/sudoers.d/admin \
 && chmod 0440 /etc/sudoers.d/neteng

# =============================================================================
# 6. SSH Hardening for Lab Environments
# =============================================================================
# Explicitly allow password auth so sshpass works, and disable root login
RUN sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config

# =============================================================================
# 7. Start SSH Daemon in the foreground
# =============================================================================
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
