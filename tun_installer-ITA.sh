#!/bin/bash
# Script automatico per abilitare TUN e configurare Tailscale in un container LXC su Proxmox

echo "=== Configurazione automatica Tailscale per container LXC ==="
read -p "Inserisci l'ID del container LXC: " CTID

CONF_FILE="/etc/pve/lxc/${CTID}.conf"

if [ ! -f "$CONF_FILE" ]; then
  echo "Errore: container $CTID non trovato."
  exit 1
fi

echo "Fermando il container $CTID..."
pct stop $CTID

echo "Abilitando il dispositivo TUN..."
if ! grep -q "10:200" "$CONF_FILE"; then
  echo "lxc.cgroup2.devices.allow: c 10:200 rwm" >> "$CONF_FILE"
fi

if ! grep -q "/dev/net/tun" "$CONF_FILE"; then
  echo "lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >> "$CONF_FILE"
fi

echo "TUN abilitato nel file $CONF_FILE"

echo "Avvio del container..."
pct start $CTID

echo "Attendo 5 secondi che il container si avvii..."
sleep 5

echo "Installazione di Tailscale nel container..."
pct exec $CTID -- bash -c "apt update -y && apt install -y curl"
pct exec $CTID -- bash -c "curl -fsSL https://tailscale.com/install.sh | sh"

echo "Avvio del servizio tailscaled..."
pct exec $CTID -- systemctl enable tailscaled
pct exec $CTID -- systemctl start tailscaled

echo "Tailscaled avviato."

echo "Ora eseguo 'tailscale up' per avviare il collegamento..."
echo "Segui il link che apparirà per autenticare il nodo nel tuo account Tailscale."
pct exec $CTID -- tailscale up

echo "Configurazione completata per il container $CTID!"
