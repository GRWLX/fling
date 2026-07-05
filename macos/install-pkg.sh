#!/usr/bin/env bash
set -euo pipefail
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "https://grwlx.github.io/sshfling/downloads/sshfling-0.1.11.pkg" -o "$tmp/sshfling-0.1.11.pkg"
sudo installer -pkg "$tmp/sshfling-0.1.11.pkg" -target /
