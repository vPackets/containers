# Custom Docker Containers for Networking

This repository contains Dockerfiles for three custom Docker containers designed for networking purposes: Alpine, Ubuntu, and Ubuntu FRR. Each container is tailored with networking packages and tools to suit different requirements in network-related tasks.

Github repository: https://github.com/vPackets/containers

## Containers Overview

### 1. Alpine Networking Container

- **Base Image**: Alpine Linux
- **Packages**: Includes networking tools and utilities commonly used in Alpine environments.
- **Use Case**: Ideal for lightweight, security-focused tasks requiring a minimal footprint.


### 3. Ubuntu Networking Container

- **Base Image**: Ubuntu
- **Packages**: Comes with essential networking packages installed on top of the Ubuntu base image.
- **Use Case**: Suited for tasks requiring Ubuntu's extensive package repositories and compatibility.

### 4. Ubuntu FRR (Free Range Routing) Container

- **Base Image**: Ubuntu
- **Packages**: Includes FRR and its dependencies.
- **Use Case**: Designed for advanced network routing and engineering tasks, leveraging FRR's capabilities.


### Alpine Container:

```
docker pull vpackets/alpine-tools
```


### Alpine Containerlab:

```
docker pullvpackets/alpine-tools-containerlab-isp-01
docker pullvpackets/alpine-tools-containerlab-isp-02
```

### FRR Containers:

```
docker pull vpackets/ubuntu-22.04-frr
docker pull vpackets/ubuntu-22.04-frr-deb
```


### Net Tools Container:

```
docker buildx build --platform linux/amd64,linux/arm64 -t vpackets/net-tools:1.0  -t vpackets/net-tools:latest --push .
docker pull vpackets/net-tools
```

### Cisco Live

```
docker buildx build --platform linux/amd64,linux/arm64 -t vpackets/clus-amsterdam:1.0 -t vpackets/clus-amsterdam:latest --push .
docker pull vpackets/clus-amsterdam:latest
```

and 

```
docker buildx build --platform linux/amd64,linux/arm64 -t vpackets/clus-rome:1.0 -t vpackets/clus-rome:latest --push .
docker pull vpackets/clus-rome:latest
```



Contributions

Contributions to this repository are welcome. Please ensure that any pull requests or issues adhere to the existing structure and standards of the project.