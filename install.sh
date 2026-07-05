#!/usr/bin/env bash
set -euo pipefail

base_url="${SSHFLING_BASE_URL:-https://grwlx.github.io/sshfling}"
base_host="${base_url#http://}"
base_host="${base_host#https://}"
base_host="${base_host%%/*}"
action="${1:-install}"
mode="${2:-auto}"

case "$action" in
  install|uninstall) ;;
  auto|apt|rpm|dnf|yum|brew|homebrew)
    mode="$action"
    action="install"
    ;;
  *)
    echo "Usage: install.sh [install|uninstall] [auto|apt|rpm|dnf|yum|brew]" >&2
    echo "       install.sh [auto|apt|rpm|dnf|yum|brew]" >&2
    exit 2
    ;;
esac

install_apt() {
  sudo rm -f /etc/apt/sources.list.d/fling.list /etc/apt/preferences.d/fling
  echo "deb [trusted=yes] ${base_url}/apt ./" | sudo tee /etc/apt/sources.list.d/sshfling.list >/dev/null
  sudo tee /etc/apt/preferences.d/sshfling >/dev/null <<EOF
Package: sshfling
Pin: origin ${base_host}
Pin-Priority: 1001
EOF
  sudo apt-get update
  sudo apt-get install -y sshfling
}

uninstall_apt() {
  if dpkg -s sshfling >/dev/null 2>&1; then
    sudo apt-get remove -y sshfling
  fi
  sudo rm -f \
    /etc/apt/sources.list.d/sshfling.list \
    /etc/apt/sources.list.d/fling.list \
    /etc/apt/preferences.d/sshfling \
    /etc/apt/preferences.d/fling
  sudo apt-get update || true
}

install_rpm() {
  sudo rm -f /etc/yum.repos.d/fling.repo
  sudo tee /etc/yum.repos.d/sshfling.repo >/dev/null <<EOF
[sshfling]
name=SSHFling
baseurl=${base_url}/rpm
enabled=1
gpgcheck=0
EOF
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y sshfling
  else
    sudo yum install -y sshfling
  fi
}

uninstall_rpm() {
  if command -v rpm >/dev/null 2>&1 && rpm -q sshfling >/dev/null 2>&1; then
    if command -v dnf >/dev/null 2>&1; then
      sudo dnf remove -y sshfling
    else
      sudo yum remove -y sshfling
    fi
  fi
  sudo rm -f /etc/yum.repos.d/sshfling.repo /etc/yum.repos.d/fling.repo
}

install_brew() {
  brew install "${base_url}/homebrew/sshfling.rb"
}

uninstall_brew() {
  if brew list --formula sshfling >/dev/null 2>&1; then
    brew uninstall sshfling
  fi
}

run_for_mode() {
  local selected="$1"
  case "$selected" in
    apt) "${action}_apt" ;;
    rpm|dnf|yum) "${action}_rpm" ;;
    brew|homebrew) "${action}_brew" ;;
    *)
      echo "Usage: install.sh [install|uninstall] [auto|apt|rpm|dnf|yum|brew]" >&2
      echo "       install.sh [auto|apt|rpm|dnf|yum|brew]" >&2
      exit 2
      ;;
  esac
}

case "$mode" in
  auto)
    if command -v apt-get >/dev/null 2>&1; then
      run_for_mode apt
    elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
      run_for_mode rpm
    elif command -v brew >/dev/null 2>&1; then
      run_for_mode brew
    else
      echo "No supported package manager found. Use ${base_url}/downloads/ directly." >&2
      exit 2
    fi
    ;;
  apt|rpm|dnf|yum|brew|homebrew) run_for_mode "$mode" ;;
  *) run_for_mode "$mode" ;;
esac
