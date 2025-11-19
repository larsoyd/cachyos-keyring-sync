#!/bin/bash
set -euo pipefail

REMOTE_BASE="https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/refs/heads/master/cachyos-keyring"
LOCAL_DIR="/usr/share/pacman/keyrings"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

if ! command -v pacman-key >/dev/null 2>&1; then
    echo "cachyos-keyring-sync: pacman-key not found in PATH" >&2
    exit 1
fi

if ! pacman-key -l >/dev/null 2>&1; then
    echo "cachyos-keyring-sync: pacman keyring is not initialised."
    echo "Initialize it first, for example:"
    echo "  sudo pacman-key --init"
    echo "  sudo pacman-key --populate archlinux"
    exit 1
fi

install -d -m 0755 "$LOCAL_DIR"

curl -fsSL "$REMOTE_BASE/cachyos-trusted" > "$TMPDIR/cachyos-trusted.new"

LOCAL_TRUSTED="$LOCAL_DIR/cachyos-trusted"

if [ ! -f "$LOCAL_TRUSTED" ] || ! cmp -s "$TMPDIR/cachyos-trusted.new" "$LOCAL_TRUSTED"; then
    echo "cachyos-keyring-sync: updating CachyOS keyring files"

    curl -fsSL "$REMOTE_BASE/cachyos.gpg" > "$TMPDIR/cachyos.gpg.new"

    if [ ! -s "$TMPDIR/cachyos.gpg.new" ]; then
        echo "cachyos-keyring-sync: downloaded cachyos.gpg is empty, aborting" >&2
        exit 1
    fi

    install -m 0644 "$TMPDIR/cachyos.gpg.new" "$LOCAL_DIR/cachyos.gpg"
    install -m 0644 "$TMPDIR/cachyos-trusted.new" "$LOCAL_TRUSTED"

    pacman-key --populate cachyos
else
    :
fi
