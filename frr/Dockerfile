# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04
LABEL maintainer="nicolas@vpackets.net"

# Set noninteractive mode to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    git autoconf automake libtool make libreadline-dev texinfo \
    pkg-config libpam0g-dev libjson-c-dev bison flex systemd \
    libc-ares-dev python3-dev python3-sphinx \
    install-info build-essential libsnmp-dev perl \
    libcap-dev libelf-dev libunwind-dev \
    libyang2 libyang2-dev protobuf-c-compiler libprotobuf-c-dev \
    libsqlite3-dev libzmq5 libzmq3-dev \
    curl python2

# Symlink for Python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install pip for Python 2
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && \
    python2 ./get-pip.py && \
    rm get-pip.py

# Add FRR user and groups
RUN groupadd -r -g 92 frr && \
    groupadd -r -g 85 frrvty && \
    adduser --system --ingroup frr --home /var/run/frr/ \
    --gecos "FRR suite" --shell /sbin/nologin frr && \
    usermod -a -G frrvty frr

# Install FRR configuration files
RUN install -m 775 -o frr -g frr -d /var/log/frr && \
    install -m 775 -o frr -g frrvty -d /etc/frr && \
    install -m 640 -o frr -g frrvty /dev/null /etc/frr/vtysh.conf && \
    install -m 640 -o frr -g frr /dev/null /etc/frr/frr.conf && \
    install -m 640 -o frr -g frr /dev/null /etc/frr/daemons.conf && \
    install -m 640 -o frr -g frr /dev/null /etc/frr/daemons

# Copy FRR service file
COPY frr.service /etc/systemd/system/frr.service



# Enable and start FRR service
RUN systemctl enable frr

# Expose ports (optional, adjust as needed)
EXPOSE 179 2601 2605

# Set the entrypoint
ENTRYPOINT ["/usr/sbin/frr"]