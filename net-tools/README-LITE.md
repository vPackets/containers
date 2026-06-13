# net-tools — LITE build plan

A plan to cut `vpackets/net-tools` pull size from **672 MB** down to **238 MB**
(**measured** — both images built and compared) while keeping everything
**absolutely needed** for Containerlab CCIE/SP + AI-networking (MRC) study.
**The current `Dockerfile` is unchanged** — the trim lives in `Dockerfile.lite`.

> Sizes below are **compressed pull size** (`docker save | gzip`), i.e. what
> `docker pull` actually transfers and what you saw as "700M+". Local
> `docker images` shows a much larger *uncompressed* number (BuildKit also adds
> attestation layers) — ignore it; pull size is the meaningful figure.

Guiding principle: ship a lean, always-on base; treat heavyweight *test frameworks*
and *data-science* libs as **install-on-demand** (the venv is on `PATH`, so
`pip install pyats genie` inside a running lab node works whenever you actually
need them).

---

## Where the weight is (measured, uncompressed)

Python `site-packages` totals **1,104 MB across 171 packages**. Two clusters
account for the bulk:

| Cluster | Size | Needed for the goals? |
|---|---:|---|
| **pyATS / Genie** (genie.libs.parser 130, genie 82, genie.libs.sdk 44, unicon 40, pyats.* ~200, transitive `ciscoisesdk` 68) | **~600 MB** | ❌ Nice-to-have. A full Cisco test framework; parsing is covered by lighter libs below. |
| **Data / plotting** (pandas 71, numpy 67, matplotlib 35, fonttools 27, pillow 24 — pulled by `scapy[all]` — + ipython/jedi 25) | **~250 MB** | ❌ Only for offline analysis/plots; not needed on a lab node. |
| **Lean automation core** (netmiko, napalm, nornir, ncclient, paramiko, pygnmi+grpcio, scapy base, parsing libs, exabgp, netaddr, requests/httpx) | **~250 MB** | ✅ Keep. |

Apt big-ticket items: `ansible` 42 MB, `rdma-core` 34 MB (keep — core to RoCE/MRC),
`neovim` 17 MB, `infiniband-diags` 8.5 MB.

---

## Pip: KEEP vs DROP

### ✅ Keep — absolutely needed
| Package(s) | Why (goal) |
|---|---|
| `netmiko`, `napalm`, `ncclient`, `paramiko` | Device CLI/NETCONF access — CCIE/SP automation |
| `nornir` (+ `nornir-netmiko`, `nornir-utils`) | Inventory-driven automation runner |
| `pygnmi`, `grpcio`, `protobuf` | gNMI streaming telemetry — SP **and** AI-fabric counters |
| `scapy` *(base, not `[all]`)* | Craft/dissect SRv6 (seg6) & RoCEv2 — MRC packet-spraying study |
| `textfsm` + `ntc-templates`, `ttp` + `ttp-templates`, `ciscoconfparse2` | Lightweight output/config parsing — **replaces Genie parsers** |
| `exabgp` | BGP / SR / flowspec route injection — SP labs |
| `netaddr`, `jmespath`, `xmltodict`, `pyyaml`, `requests`, `httpx`, `tabulate` | Small, high-use utilities |
| `rich` | Readable terminal output (small) |

### ❌ Drop from the image — install on demand
| Package(s) | Saved | Get it back with |
|---|---:|---|
| `pyats`, `genie` (+ all `genie.libs.*`, `unicon`, `ciscoisesdk`) | **~600 MB** | `pip install pyats genie` |
| `pandas` (+ `numpy`) | ~140 MB | `pip install pandas` |
| `scapy[all]` extras: `matplotlib`, `pillow`, `fonttools` (use base `scapy`) | ~86 MB | `pip install "scapy[all]"` |
| `ipython` (+ `jedi`) | ~25 MB | `pip install ipython` |

> Rationale: pyATS/Genie is a *test* framework and the single biggest cost.
> Day-to-day parsing on a lab node is served by `textfsm`/`ntc-templates`/`ttp`/
> `ciscoconfparse2`, which you keep. `pandas`/`matplotlib` belong on your analysis
> host, not on every Containerlab node.

---

## Apt: KEEP vs TRIM

### ✅ Keep
- **AI-fabric / MRC:** `rdma-core`, `ibverbs-utils`, `perftest`, `infiniband-diags`,
  `linuxptp`, `lldpad`, `ethtool`, `iproute2` (SRv6/seg6), `numactl`, `pciutils`
- **Core toolbox:** `iputils-ping`, `traceroute`, `mtr-tiny`, `tcpdump`, `tshark`,
  `nmap`, `iperf3`, `socat`, `netcat-openbsd`, `dnsutils`, `jq`, `curl`, `wget`,
  `lldpd`, `hping3`, `ndisc6`, `bridge-utils`, `conntrack`, `openssh-server`,
  `sudo`, `tmux`
- **gnmic** binary (curl install, tiny)

### ✂️ Trim
| Change | Saved | Note |
|---|---:|---|
| `ansible` → `ansible-core` | ~30 MB | Add only the collections you use (`ansible-galaxy collection install cisco.ios` …) |
| `neovim` → `vim-tiny` (or `nano`) | ~15 MB | Editor for quick edits only |
| Drop redundant monitors: `bmon`, `nload`, `iptraf-ng` (keep `iftop`, `htop`) | ~1 MB | Negligible size; minimalism only |
| Drop `man-db` + `siege`/`wrk`/`whois`/`telnet` if unused | ~3–5 MB | Optional cleanup |

### Build-level levers (apply to the lite Dockerfile)
- Add **`--no-install-recommends`** to every `apt-get install` — biggest apt saver
  (skips suggested extras the current image pulls in).
- Keep `--no-cache-dir` on pip (already done) and `apt-get clean && rm -rf
  /var/lib/apt/lists/*` (already done).
- Optional: drop `/usr/share/doc`, `/usr/share/man` in the same layer.

---

## Result (measured — both images built & compared)

| | Full | Lite |
|---|---:|---:|
| pip `site-packages` | 1,104 MB | **202 MB** |
| **Pull size (compressed)** | **672 MB** | **238 MB** |

≈ **65% smaller pull**, with zero loss for routine CCIE/SP automation, gNMI
telemetry, SRv6/RoCE packet work, and the MRC fabric tooling. The dropped
frameworks are one `pip install` away inside any running container.

> What still dominates lite: the apt toolbox (`tshark`/wireshark libs, `nmap`,
> `rdma-core`) — kept on purpose for packet dissection and RoCE work. Dropping
> `tshark` would save another ~100 MB if you only need `tcpdump`.

---

## The two Dockerfiles

| File | Tag | Size | Use |
|---|---|---:|---|
| `Dockerfile.full` | `:full` / `:latest` | ~660 MB | Everything: pyATS/Genie, pandas, `scapy[all]`, ipython |
| `Dockerfile.lite` | `:lite` | ~250–300 MB | Lean automation + telemetry + AI-fabric core |

`Dockerfile.full` is identical to the existing `Dockerfile`; `Dockerfile.lite`
implements the KEEP/TRIM lists above.

## Build commands

Multi-platform (amd64 + arm64), pushed to Docker Hub — the way the repo publishes:

```bash
cd net-tools

# FULL (also tagged latest)
docker buildx build --platform linux/amd64,linux/arm64 \
  -f Dockerfile.full -t vpackets/net-tools:full -t vpackets/net-tools:latest --push .

# LITE
docker buildx build --platform linux/amd64,linux/arm64 \
  -f Dockerfile.lite -t vpackets/net-tools:lite --push .
```

Local single-arch build for testing (no push):

```bash
docker build -f Dockerfile.lite -t vpackets/net-tools:lite .
docker images vpackets/net-tools          # compare sizes
```

## Adding a dropped library back, on demand

The venv is on `PATH`, so inside any running lite container:

```bash
pip install pyats genie        # full Cisco test framework
pip install pandas             # dataframe telemetry analysis
pip install ipython            # rich REPL
pip install "scapy[all]"       # scapy + matplotlib/pyx plotting
```
