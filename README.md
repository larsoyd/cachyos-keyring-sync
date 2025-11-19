# cachyos-keyring-sync
Simple script that checks upstream key for changes compared to local key and then updates if needed. Can be manually run.


Install:
```bash
$ chmod +x setup.sh

$ ./setup.sh
```

Uninstall:
```bash
# Stop and disable the timer (if you ever enabled it)
$ sudo systemctl disable --now cachyos-keyring-sync.timer

# Stop the service if it's somehow running
$ sudo systemctl stop cachyos-keyring-sync.service 2>/dev/null || true

# Remove the systemd unit files
$ sudo rm -f /etc/systemd/system/cachyos-keyring-sync.service
$ sudo rm -f /etc/systemd/system/cachyos-keyring-sync.timer

# Reload systemd units
$ sudo systemctl daemon-reload

# Remove the sync script
$ sudo rm -f /usr/local/sbin/cachyos-keyring-sync
```
