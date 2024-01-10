# Custom Docker Containers for Networking

This repository contains Dockerfiles for three custom Docker containers designed for networking purposes: Alpine, Ubuntu, and Ubuntu FRR. Each container is tailored with networking packages and tools to suit different requirements in network-related tasks.

## Containers Overview

### 1. Alpine Networking Container

- **Base Image**: Alpine Linux
- **Packages**: Includes networking tools and utilities commonly used in Alpine environments.
- **Use Case**: Ideal for lightweight, security-focused tasks requiring a minimal footprint.

### 2. Building the Alpine Containerlabs

These containers are used for my containerlabs topology so that I can have the same IP for my ISP-01 and ISP-02 test machines.

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

## Building the Containers

To build these containers, navigate to the respective container directory and run the Docker build command.

### Building the Alpine Container

```bash
cd alpine-networking
docker build -t alpine-networking .
```

### Building the Ubuntu Container

```bash
cd ubuntu-networking
docker build -t ubuntu-networking .
```

### Building the Ubuntu FRR Container

```bash
cd ubuntu-frr
docker build -t ubuntu-frr .
```

## Running the Containers

After building the containers, you can run them using Docker.


## Running the Alpine Container

```bash
docker run -it --rm alpine-networking
```


## Running the Ubuntu Container

```bash
docker run -it --rm ubuntu-networking
```

## Running the Ubuntu FRR Container

```bash
docker run -it --rm ubuntu-frr
```

Contributions

Contributions to this repository are welcome. Please ensure that any pull requests or issues adhere to the existing structure and standards of the project.