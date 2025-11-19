#!/bin/bash
set -euo pipefail

# Config

REMOTE_BASE="https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/refs/heads/master/cachyos-keyring"
LOCAL_DIR="/usr/share/pacman/keyrings"
LOCAL_TRUSTED="$LOCAL_DIR/cachyos-trusted"
LOCAL_GPG="$LOCAL_DIR/cachyos.gpg"

# Check

if [ "$EUID" -ne 0 ]; then
  echo "cachyos-keyring-sync: Please run as root" >&2
  exit 1
fi

if ! command -v pacman-key >/dev/null 2>&1; then
    echo "cachyos-keyring-sync: pacman-key not found in PATH" >&2
    exit 1
fi

if ! pacman-key -l >/dev/null 2>&1; then
    echo "cachyos-keyring-sync: pacman keyring is not initialised."
    echo "Initialize it first: sudo pacman-key --init" >&2
    exit 1
fi

# Execution

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

install -d -m 0755 "$LOCAL_DIR"

curl -fsSL "$REMOTE_BASE/cachyos-trusted" > "$TMPDIR/cachyos-trusted.new"

curl -fsSL "$REMOTE_BASE/cachyos.gpg" > "$TMPDIR/cachyos.gpg.new"

if [ ! -s "$TMPDIR/cachyos-trusted.new" ] || [ ! -s "$TMPDIR/cachyos.gpg.new" ]; then
    echo "cachyos-keyring-sync: Downloaded files are empty. Aborting." >&2
    exit 1
fi

UPDATE_NEEDED=false

if [ ! -f "$LOCAL_TRUSTED" ] || ! cmp -s "$TMPDIR/cachyos-trusted.new" "$LOCAL_TRUSTED"; then
    UPDATE_NEEDED=true
fi

if [ ! -f "$LOCAL_GPG" ] || ! cmp -s "$TMPDIR/cachyos.gpg.new" "$LOCAL_GPG"; then
    UPDATE_NEEDED=true
fi

if [ "$UPDATE_NEEDED" = true ]; then
    echo "cachyos-keyring-sync: Updates detected. Installing..."

    install -m 0644 "$TMPDIR/cachyos.gpg.new" "$LOCAL_GPG"
    install -m 0644 "$TMPDIR/cachyos-trusted.new" "$LOCAL_TRUSTED"

    # Refresh the keyring
    pacman-key --populate cachyos
    echo "cachyos-keyring-sync: Keyring updated successfully."
else
    echo "cachyos-keyring-sync: Keyring is up to date."
fi
