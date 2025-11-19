#!/bin/bash
set -euo pipefail

REMOTE_BASE="https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/refs/heads/master/cachyos-keyring"
LOCAL_DIR="/usr/share/pacman/keyrings"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# 1) Fetch latest cachyos-trusted from upstream
curl -fsSL "$REMOTE_BASE/cachyos-trusted" > "$TMPDIR/cachyos-trusted.new"

# 2) If we do not have a local file yet, or if it changed, update both files
if ! cmp -s "$TMPDIR/cachyos-trusted.new" "$LOCAL_DIR/cachyos-trusted" 2>/dev/null; then
    echo "cachyos-keyring-sync: detected change in cachyos-trusted, updating keyring"

    # Fetch matching cachyos.gpg from upstream
    curl -fsSL "$REMOTE_BASE/cachyos.gpg" > "$TMPDIR/cachyos.gpg.new"

    # Basic sanity: gpg file should not be empty
    if [ ! -s "$TMPDIR/cachyos.gpg.new" ]; then
        echo "cachyos-keyring-sync: downloaded cachyos.gpg is empty, aborting" >&2
        exit 1
    fi

    # 3) Install new keyring files
    install -m 0644 "$TMPDIR/cachyos.gpg.new" "$LOCAL_DIR/cachyos.gpg"
    install -m 0644 "$TMPDIR/cachyos-trusted.new" "$LOCAL_DIR/cachyos-trusted"

    # 4) Re-populate pacman keyring from updated keyring files
    pacman-key --populate cachyos
else
    # Optional: stay quiet if nothing changed
    # echo "cachyos-keyring-sync: no changes"
    :
fi
