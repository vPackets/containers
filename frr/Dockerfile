# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04
LABEL maintainer="nicolas@vpackets.net"

# Set noninteractive mode to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    git autoconf automake libtool make libreadline-dev texinfo \
    pkg-config libpam0g-dev libjson-c-dev bison flex \
    libc-ares-dev python3-dev python3-sphinx \
    install-info build-essential libsnmp-dev perl \
    libcap-dev libelf-dev libunwind-dev \
    protobuf-c-compiler libprotobuf-c-dev \
    libgrpc++-dev protobuf-compiler-grpc \
    libsqlite3-dev libzmq5 libzmq3-dev libpcre2-dev \
    cmake

# Clone and build libyang
RUN git clone https://github.com/CESNET/libyang.git && \
    cd libyang && \
    git checkout v2.1.128 && \
    mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX:PATH=/usr \
          -D CMAKE_BUILD_TYPE:String="Release" .. && \
    make && \
    make install

# Add FRR user and groups
RUN groupadd -r -g 92 frr && \
    groupadd -r -g 85 frrvty && \
    adduser --system --ingroup frr --home /var/run/frr/ \
    --gecos "FRR suite" --shell /sbin/nologin frr && \
    usermod -a -G frrvty frr

# Clone the FRR git repo
RUN git clone https://github.com/frrouting/frr.git frr

# Compile FRR
WORKDIR /frr
RUN ./bootstrap.sh && \
    ./configure \
    --prefix=/usr \
    --includedir=\${prefix}/include \
    --bindir=\${prefix}/bin \
    --sbindir=\${prefix}/lib/frr \
    --libdir=\${prefix}/lib/frr \
    --libexecdir=\${prefix}/lib/frr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --with-moduledir=\${prefix}/lib/frr/modules \
    --enable-configfile-mask=0640 \
    --enable-logfile-mask=0640 \
    --enable-snmp=agentx \
    --enable-multipath=64 \
    --enable-user=frr \
    --enable-group=frr \
    --enable-vty-group=frrvty \
    --with-pkg-git-version \
    --with-pkg-extra-version=-MyOwnFRRVersion && \
    make && \
    make install

# Install FRR configuration files
RUN install -m 775 -o frr -g frr -d /var/log/frr && \
    install -m 775 -o frr -g frrvty -d /etc/frr && \
    install -m 640 -o frr -g frrvty tools/etc/frr/vtysh.conf /etc/frr/vtysh.conf && \
    install -m 640 -o frr -g frr tools/etc/frr/frr.conf /etc/frr/frr.conf && \
    install -m 640 -o frr -g frr tools/etc/frr/daemons.conf /etc/frr/daemons.conf && \
    install -m 640 -o frr -g frr tools/etc/frr/daemons /etc/frr/daemons



# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY daemons /etc/frr/daemons

COPY start-frr.sh /start-frr.sh
RUN chmod +x /start-frr.sh
ENTRYPOINT ["/start-frr.sh"]

ENV PATH="/usr/lib/frr:${PATH}"

# Define a default command (replace this with the command to run FRR)
CMD ["/bin/bash"]
