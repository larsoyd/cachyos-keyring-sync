#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root, for example:" >&2
    echo "  sudo ./setup.sh" >&2
    exit 1
fi

REPO_DIR="$(cd -- "$(dirname "$0")" && pwd)"
SCRIPT_SRC="$REPO_DIR/cachyos-keyring-sync/cachyos-keyring-sync.sh"
SYSTEM_SRC="$REPO_DIR/system"

if [ ! -f "$SCRIPT_SRC" ]; then
    echo "setup: could not find $SCRIPT_SRC" >&2
    exit 1
fi

install -Dm755 "$SCRIPT_SRC" /usr/local/sbin/cachyos-keyring-sync

install -Dm644 "$SYSTEM_SRC/cachyos-keyring-sync.service" \
    /etc/systemd/system/cachyos-keyring-sync.service

install -Dm644 "$SYSTEM_SRC/cachyos-keyring-sync.timer" \
    /etc/systemd/system/cachyos-keyring-sync.timer
    
systemctl daemon-reload

/usr/local/sbin/cachyos-keyring-sync || {
    echo
    echo "setup: initial cachyos-keyring-sync run failed."
    echo "Check the error above, fix it, then re-run:"
    echo "  sudo /usr/local/sbin/cachyos-keyring-sync"
    exit 1
}

echo
echo "CachyOS keyring has been synced once."
echo
echo "If you want weekly automatic refreshes, enable the timer with:"
echo "  sudo systemctl enable --now cachyos-keyring-sync.timer"
echo
echo "Otherwise you can run manually when needed:"
echo "  sudo cachyos-keyring-sync"
