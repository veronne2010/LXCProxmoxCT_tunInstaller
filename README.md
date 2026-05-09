# LXCProxmoxCT_tunInstaller

A Bash script that automates enabling the TUN device and installing [Tailscale](https://tailscale.com/) inside a Proxmox LXC container — all in a single command from the Proxmox host.

---

## What it does

Proxmox LXC containers are unprivileged by default and don't have access to the `/dev/net/tun` device, which is required by VPN tools like Tailscale. This script handles everything automatically:

1. Asks for the target container ID (CTID)
2. Stops the container
3. Adds the TUN device configuration to the container's `.conf` file
4. Restarts the container
5. Installs `curl` and Tailscale inside the container
6. Enables and starts the `tailscaled` service
7. Runs `tailscale up` and prompts you to authenticate via browser link

---

## Prerequisites

- Proxmox VE host with `pct` available
- A running Debian/Ubuntu-based LXC container
- Root access on the Proxmox host

---

## Usage

Run the script directly on the **Proxmox host** (not inside the container):

```bash
bash tun_installer-ITA.sh
```

When prompted, enter the numeric ID of your LXC container:

```
=== Configurazione automatica Tailscale per container LXC ===
Inserisci l'ID del container LXC: 101
```

The script will then stop the container, configure TUN, restart it, install Tailscale, and finally output a link to authenticate your new node with your Tailscale account.

---

## What gets added to the container config

The script appends the following lines to `/etc/pve/lxc/<CTID>.conf` (only if not already present):

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

These lines grant the container access to the TUN device and mount it at the correct path.

---

## Project Structure

```
LXCProxmoxCT_tunInstaller/
├── tun_installer-ITA.sh   # Main setup script (Italian comments)
├── LICENSE
└── README.md
```

---

## Notes

- The script stops and restarts the container during setup — make sure no critical workloads are running at the time.
- Tailscale installation requires internet access from inside the container.
- The script is designed for **Debian/Ubuntu** based containers. Other distros may require adjustments to the package manager commands.
- After `tailscale up`, follow the printed URL to authenticate the node in your Tailscale account.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
