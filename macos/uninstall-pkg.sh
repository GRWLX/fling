#!/usr/bin/env bash
set -euo pipefail

sudo rm -f /usr/local/bin/sshfling
sudo rm -rf /usr/local/share/sshfling
sudo pkgutil --forget io.sshfling.cli >/dev/null 2>&1 || true

echo "Removed SSHFling package files."
echo "Left /etc/sshfling in place for local policy or CA material."
