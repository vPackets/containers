# Use Debian as the base image
FROM debian:latest
LABEL maintainer="Nicolas@vpackets"

# Set noninteractive mode to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Add FRR GPG key
RUN apt-get update && apt-get install -y curl gnupg lsb-release \
    && curl -s https://deb.frrouting.org/frr/keys.gpg | gpg --dearmor -o /usr/share/keyrings/frrouting.gpg

# Add FRR repository # possible values for FRRVER: frr-6 frr-7 frr-8 frr-9.0 frr-9.1 frr-stable
RUN FRRVER="frr-stable" \
    && echo "deb [signed-by=/usr/share/keyrings/frrouting.gpg] https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER" | tee -a /etc/apt/sources.list.d/frr.list

# Update and install useful networking tools:
RUN apt-get update && apt-get install -y  tcpdump \
    iproute2 \
    iputils-ping \
    traceroute \
    mtr \
    curl \
    wget \
    nmap \
    tcptraceroute \
    dnsutils \
    iperf3 \
    tshark \
    iptables \
    net-tools \
    bridge-utils \
    iftop \
    htop \
    ethtool \
    socat \
    ngrep

# Update and install FRR
RUN apt-get install -y frr frr-pythontools



# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Define a default command (if necessary)
CMD ["/bin/bash"]
