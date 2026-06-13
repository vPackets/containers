# Custom Networking Containers — `vpackets/*`

Dockerfiles for the custom container images used across the networking labs (`networking-labs`) and Cisco Live demos. All images publish to [`vpackets/*`](https://hub.docker.com/u/vpackets) on Docker Hub and are built multi-platform (`linux/amd64,linux/arm64`).

GitHub: https://github.com/vPackets/containers

---

## Overview

The repo holds **eight** container families, from a lightweight Alpine probe to the flagship `net-tools` lab host. Pick by job:

| Need | Use |
|------|-----|
| Lab host: traffic gen, automation, telemetry, RDMA/SRv6 endpoint | **`net-tools/`** ⭐ |
| Routing dataplane node (OSPF/ISIS/BGP/LDP/SRv6) | `frr/` or `frr-deb/` |
| Throwaway lightweight probe | `alpine/` |
| Topology-pinned ISP fixtures (hardcoded IPs) for BGP labs | `alpine-containerlab/` |
| Cisco Live / CLEMEA event demo containers | `clus-containers/`, `clemea-containers/`, `ciscolive-containers/` |

---

## Repository Layout

```
alpine/                 vpackets/alpine-tools — minimal Alpine networking probe
alpine-containerlab/
  isp-01/               vpackets/alpine-tools-containerlab-isp-01 — BGP lab ISP-01 host
  isp-02/               vpackets/alpine-tools-containerlab-isp-02 — BGP lab ISP-02 host
net-tools/              vpackets/net-tools — flagship Ubuntu lab host (see net-tools/README.md)
  Dockerfile            default build
  Dockerfile.full       full toolset variant
  Dockerfile.lite       slim variant (see README-LITE.md)
frr/                    vpackets/ubuntu-22.04-frr — FRRouting on Ubuntu 22.04
frr-deb/                vpackets/ubuntu-22.04-frr-deb — FRRouting on Debian
clus-containers/        Cisco Live (US) demo containers
  amsterdam/  rome/
clemea-containers/      Cisco Live EMEA demo containers
  london/  rome/  remediation/   (remediation = Ansible + manual-paste scripts, no Dockerfile)
ciscolive-containers/   Generic Cisco Live demo container
```

## Image Inventory

| Dir | Image | Base | Pull size | Idle RAM | SSH | Default login | Purpose |
|-----|-------|------|-----------|----------|-----|---------------|---------|
| `alpine-containerlab/isp-01` | `vpackets/alpine-tools-containerlab-isp-01` | `alpine:latest` | ~13 MB | ~4 MB | ❌ No | — (`CMD sh`) | BGP-lab ISP-01 host (pinned IP) |
| `alpine-containerlab/isp-02` | `vpackets/alpine-tools-containerlab-isp-02` | `alpine:latest` | ~13 MB | ~4 MB | ❌ No | — (`CMD sh`) | BGP-lab ISP-02 host (pinned IP) |
| `clus-containers/amsterdam` | `vpackets/clus-amsterdam` | `ubuntu:22.04` | ~33 MB | ~6 MB | ❌ No | — (`CMD sh`) | Cisco Live demo container |
| `clus-containers/rome` | `vpackets/clus-rome` | `ubuntu:22.04` | ~33 MB | ~6 MB | ❌ No | — (`CMD sh`) | Cisco Live demo container |
| `alpine/` | `vpackets/alpine-tools` | `alpine:latest` | ~59 MB | ~5 MB | ❌ No | — (`CMD sh`) | Lightweight networking probe/host |
| `frr-deb/` | `vpackets/ubuntu-22.04-frr-deb` | `debian:latest` | ~207 MB | ~100 MB † | ❌ No | — (`CMD bash`) | FRRouting dataplane node (Debian) |
| `net-tools/` ⭐ `:lite` | `vpackets/net-tools:lite` | `ubuntu:24.04` | ~246 MB | ~8 MB | ✅ Yes | `cisco` / `admin` · `cisco123` | Slim lab-host variant (see `README-LITE.md`) |
| `ciscolive-containers/` | `vpackets/ciscolive-container` | `ubuntu:22.04` | ~310 MB | ~12 MB | ✅ Yes | `cisco` / `admin` · `cisco123` | Generic Cisco Live demo container |
| `clemea-containers/london`, `/rome` | `vpackets/cl-container-london`, `cl-container-rome` | `ubuntu:22.04` | ~406 MB | ~12 MB | ✅ Yes | `cisco` / `admin` · `cisco123` | Cisco Live EMEA demo containers |
| `net-tools/` ⭐ | `vpackets/net-tools` (`:latest`/`:full`) | `ubuntu:24.04` | ~601 MB ‡ | ~4 MB idle § | ✅ Yes | `cisco` / `admin` · `cisco123` | General-purpose lab host: full toolbox + Python automation stack in `/opt/venv` + AI-fabric tooling (RDMA/RoCE, SRv6, PTP, DCB/PFC) |
| `frr/` | `vpackets/ubuntu-22.04-frr` | `ubuntu:22.04` | ~669 MB | ~100 MB † | ❌ No | — (`frr` system user, `nologin`) | FRRouting dataplane node |
| `clemea-containers/remediation` | — | — | — | — | — | — | Ansible playbooks + `manual_paste_*.sh` (no image) |

_Rows sorted lightest → heaviest by pull size._

> - **Pull size** = compressed download size reported by Docker Hub (`latest` tag). On-disk uncompressed is larger.
> - **Idle RAM** = measured RSS of the running container at rest (`docker stats`, no load). Grows under load — iperf3/nmap/tshark add tens of MB; the net-tools Python/Ansible stack can reach hundreds of MB when running playbooks.
> - **† FRR** runs routing daemons (zebra + bgpd/ospfd/isisd…) at rest, so idle RAM is much higher than the shell/sshd images — estimate, scales with enabled daemons.
> - **‡ net-tools `:latest`/`:full`** is ~601 MB to pull but **~4.5 GB on disk** uncompressed (Python wheels + AI-fabric tooling). Not "lightweight" despite the modest pull size.
> - **§** net-tools idles low because the entrypoint is just `sshd`; real footprint depends entirely on what you run inside it.
> - **SSH column** = the image runs `sshd` as its entrypoint and ships the default lab login below. Images marked ❌ start a plain shell (or a routing daemon) with **no SSH server and no default user accounts**.
> - Event-container tags vary per show — check the `LABEL`/build comment in each Dockerfile.

💡 **Just need a traffic generator?** `vpackets/alpine-tools` (~59 MB, ~5 MB RAM) is the sweet spot — it bundles `iperf3`, `mtr`, `nmap`, `tcpdump`, `tshark`, `netcat`, `bind-tools`. The even-smaller `isp-0x` images (~13 MB) drop `tshark`/`tcpdump`/`python3`. Avoid `net-tools` for pure traffic gen — its weight is the Python/AI-fabric stack you won't use.

---

## Usage

```bash
# Generic multi-platform build & push (run from a container's directory)
docker buildx build --platform linux/amd64,linux/arm64 \
  -t vpackets/<image>:<tag> -t vpackets/<image>:latest --push .

# Flagship lab host
docker buildx build --platform linux/amd64,linux/arm64 -t vpackets/net-tools:latest --push .

# Cisco Live demo containers
docker buildx build --platform linux/amd64,linux/arm64 -t vpackets/clus-amsterdam:latest --push .
docker buildx build --platform linux/amd64,linux/arm64 -t vpackets/clus-rome:latest --push .

# Pull
docker pull vpackets/net-tools
docker pull vpackets/alpine-tools
docker pull vpackets/alpine-tools-containerlab-isp-01
docker pull vpackets/ubuntu-22.04-frr
```

## Default credentials

> ⚠️ **Lab-only credentials — never expose these images to an untrusted network.**

The **SSH-enabled** images (✅ in the inventory above) ship an OpenSSH server started as the container's entrypoint, with two interchangeable accounts:

| Account | Password | Sudo | Root SSH login |
|---------|----------|------|----------------|
| `cisco` | `cisco123` | passwordless (`NOPASSWD:ALL`) | disabled (`PermitRootLogin no`) |
| `admin` | `cisco123` | passwordless (`NOPASSWD:ALL`) | disabled (`PermitRootLogin no`) |

Password authentication is enabled (`PasswordAuthentication yes`). Images that ship SSH + these credentials:

- `net-tools/` (`:latest`, `:full`, `:lite`)
- `clemea-containers/london`, `clemea-containers/rome`
- `ciscolive-containers/`

All other images (`alpine*`, `frr*`, `clus-*`) have **no SSH server and no default users** — they drop straight into a shell or a routing daemon. See each image's own README for specifics — `net-tools/README.md` and `net-tools/README-LITE.md` are the most detailed.

---

## Caveats & Notes

- These images back the `networking-labs` topologies — keep tags in sync with that repo's image inventory.
- `clemea-containers/remediation/` is **not** a buildable image (Ansible + paste scripts only).
- Event demo containers (`clus-*`, `clemea-*`, `ciscolive-*`) are pinned, single-purpose fixtures — not general-purpose hosts.

## Contributing

PRs welcome; keep new containers consistent with the existing structure and the `vpackets/*` naming convention.
