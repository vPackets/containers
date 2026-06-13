# vpackets/net-tools

The recommended **general-purpose lab host** for Containerlab CCIE / Service Provider
and AI-networking studies. Attach it to any topology as a traffic source/sink,
automation controller, telemetry collector, or RDMA/SRv6 endpoint.

Base: `ubuntu:24.04` · SSH server (users `cisco` / `admin`, password `cisco123`,
passwordless sudo) · Python automation stack in `/opt/venv` (on global `PATH`).

```bash
# Multi-platform build & push
docker buildx build --platform linux/amd64,linux/arm64 \
  -t vpackets/net-tools:latest --push .
```

---

## Why this image (vs. the others in this repo)

| Need | Use |
|------|-----|
| Lab host, traffic gen, automation, telemetry, RDMA/SRv6 endpoint | **`net-tools`** (this image) |
| Routing dataplane node (OSPF/ISIS/BGP/LDP/SRv6) | `frr/` or `frr-deb/` |
| Throwaway lightweight probe | `alpine/` |
| Topology-pinned fixtures (hardcoded IPs) | `clus-*`, `clemea-*`, `alpine-containerlab/` |

---

## Tooling

### CCIE / SP — automation, parsing, telemetry
- **CLI/config automation**: `netmiko`, `napalm`, `nornir` (+ `nornir-netmiko`, `nornir-utils`), `ansible` (+ `ansible-pylibssh`), `pyntc`
- **Model-driven**: `ncclient` (NETCONF), `pygnmi` + `gnmic` (gNMI subscribe/get/set), `grpcio`/`protobuf`
- **Parsing**: `pyats`/`genie`, `textfsm` + `ntc-templates`, `ttp` + `ttp-templates`, `ciscoconfparse2`, `netaddr`, `jmespath`, `xmltodict`
- **Routing injection**: `exabgp` (BGP/SR/flowspec route injection for SP labs)
- **Analysis**: `pandas`, `tabulate`, `rich`, `ipython`
- **Classic toolbox**: `iproute2`, `tcpdump`/`tshark`/`ngrep`, `mtr`, `nmap`, `iperf3`, `scapy`, `lldpd`, `hping3`, `bmon`/`nload`/`iptraf-ng`, `bridge-utils`, …

### AI fabric — RDMA / RoCE / SRv6 / MRC building blocks
- **RDMA/RoCE**: `rdma-core`, `ibverbs-utils` (`ibv_devices`, `ibv_devinfo`), `perftest` (`ib_write_bw`, `ib_read_bw`, `ib_send_lat`), `infiniband-diags`
- **SRv6 source routing**: `iproute2` seg6 (`ip -6 route … encap seg6`)
- **Lossless Ethernet (PFC/ECN/DCB)**: `lldpad`, `ethtool`
- **Time sync (telemetry/fabric)**: `linuxptp` (`ptp4l`, `phc2sys`)
- **NIC / NUMA inspection**: `pciutils` (`lspci`), `numactl`, `ethtool`, `kmod`

---

## The MRC use case (OpenAI · NVIDIA · AMD · Broadcom · Intel · Microsoft)

**MRC = Multipath Reliable Connection** — an open Ethernet transport spec released
~May 2026 and published through the **Open Compute Project (OCP)**. It targets the
network bottleneck in large GPU training clusters (a single late transfer stalls
every GPU).

Key ideas, and how to study each with this image:

| MRC concept | What it does | Emulate / observe here |
|---|---|---|
| **Packet spraying** | One RDMA flow spread across hundreds of paths | ECMP multipath routes (`ip route … nexthop … nexthop …`), capture distribution with `tshark` |
| **SRv6 source routing** | Source picks the path via segment list | `ip -6 route add <dst> encap seg6 mode encap segs <sid1>,<sid2> dev <if>` |
| **RDMA / RoCEv2** | The transport carrying GPU traffic | `ib_write_bw`/`ib_send_lat` between two net-tools nodes; dissect RoCEv2 in `tshark` |
| **Multi-plane fabric** | Parallel disjoint Ethernet planes | Multi-link Containerlab topology + per-plane routes |
| **µs failure bypass** | Detect + reroute on link/switch loss | BFD on FRR neighbors, fast-reroute, link flaps |
| **Telemetry-driven LB** | Avoid congested paths in real time | `gnmic subscribe` to interface/queue counters, plot with `pandas` |

> MRC is deployed on OpenAI's GB200 clusters (OCI Abilene, TX) and Microsoft
> Fairwater. It is an Ethernet/RoCE alternative to single-path transport, not a
> replacement for SRv6 — it *builds on* segment routing you already study for CCIE-SP.

### Quick examples
```bash
# RDMA bandwidth between two net-tools nodes (server then client)
ib_write_bw -d <rdma_dev>                 # on node A
ib_write_bw -d <rdma_dev> <node-A-ip>     # on node B

# SRv6 encap source route
ip -6 route add fc00:0:dc::1/128 encap seg6 mode encap \
  segs fc00:0:107::1,fc00:0:101::1 dev eth1

# Stream interface counters from an XRd/SONiC node via gNMI
gnmic -a 198.18.128.10:57400 -u admin -p admin --insecure \
  subscribe --path /interfaces/interface/state/counters

# Inject BGP routes for an SP / SR lab
exabgp /etc/exabgp/peers.conf
```

> NCCL/`nccl-tests` and GPU collectives require CUDA + GPUs and are intentionally
> **not** baked in — run those on the GPU host, use this image for the fabric/
> transport/telemetry side.

## Sources
- [OpenAI — Supercomputer networking to accelerate large-scale AI training](https://openai.com/index/mrc-supercomputer-networking/)
- [NVIDIA — Spectrum-X, now with MRC](https://blogs.nvidia.com/blog/spectrum-x-ethernet-mrc/)
- [Converge Digest — MRC redesigns Ethernet for 100k-GPU clusters](https://convergedigest.com/multipath-reliable-connection-mrc-redesigns-ethernet-for-100000-gpu-ai-clusters/)
- [MarkTechPost — OpenAI introduces MRC](https://www.marktechpost.com/2026/05/07/openai-introduces-mrc-multipath-reliable-connection-a-new-open-networking-protocol-for-large-scale-ai-supercomputer-training-clusters/)
