#!/usr/bin/env bash
set -euo pipefail

base_url="${SSHFLING_BASE_URL:-https://grwlx.github.io/sshfling}"
expected_repo_fingerprint="B4E094A1E54ABF674E3A5A055E3D7A952679C7E1"
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

normalize_fingerprint() {
  printf '%s' "${1:-}" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]'
}

fingerprint_key_file() {
  local key_file="$1"
  if ! command -v gpg >/dev/null 2>&1; then
    echo "gpg is required to verify the SSHFling repository signing key fingerprint." >&2
    return 127
  fi
  gpg --batch --show-keys --with-colons "$key_file" | awk -F: '/^fpr:/ {print toupper($10); exit}'
}

verify_repo_key() {
  local key_file="$1"
  local expected actual
  expected="$(normalize_fingerprint "$expected_repo_fingerprint")"
  actual="$(fingerprint_key_file "$key_file")"
  if [[ -z "$actual" || "$actual" != "$expected" ]]; then
    echo "Repository signing key fingerprint mismatch." >&2
    echo "Expected: $expected" >&2
    echo "Actual:   ${actual:-UNKNOWN}" >&2
    return 2
  fi
}

install_apt() {
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  curl -fsSL "${base_url}/sshfling-repo.gpg" -o "$tmp/sshfling-repo.gpg"
  curl -fsSL "${base_url}/apt/InRelease" -o "$tmp/InRelease"
  verify_repo_key "$tmp/sshfling-repo.gpg"
  sudo rm -f /etc/apt/sources.list.d/fling.list /etc/apt/preferences.d/fling /etc/apt/preferences.d/sshfling
  sudo install -d -m 0755 /usr/share/keyrings
  sudo install -m 0644 "$tmp/sshfling-repo.gpg" /usr/share/keyrings/sshfling-repo.gpg
  printf 'deb [signed-by=/usr/share/keyrings/sshfling-repo.gpg] %s/apt ./\n' "$base_url" >"$tmp/sshfling.list"
  sudo install -m 0644 "$tmp/sshfling.list" /etc/apt/sources.list.d/sshfling.list
  sudo apt-get update
  sudo apt-get install -y sshfling
}

uninstall_apt() {
  if dpkg -s sshfling >/dev/null 2>&1; then
    sudo apt-get remove -y sshfling
  fi
  sudo rm -f     /etc/apt/sources.list.d/sshfling.list     /etc/apt/sources.list.d/fling.list     /etc/apt/preferences.d/sshfling     /etc/apt/preferences.d/fling     /usr/share/keyrings/sshfling-repo.gpg
  sudo apt-get update || true
}

install_rpm() {
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  curl -fsSL "${base_url}/sshfling-repo.asc" -o "$tmp/sshfling-repo.asc"
  curl -fsSL "${base_url}/rpm/repodata/repomd.xml.asc" -o "$tmp/repomd.xml.asc"
  verify_repo_key "$tmp/sshfling-repo.asc"
  sudo install -d -m 0755 /etc/pki/rpm-gpg
  sudo install -m 0644 "$tmp/sshfling-repo.asc" /etc/pki/rpm-gpg/RPM-GPG-KEY-sshfling
  cat >"$tmp/sshfling.repo" <<EOF
[sshfling]
name=SSHFling
baseurl=${base_url}/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-sshfling
EOF
  sudo install -m 0644 "$tmp/sshfling.repo" /etc/yum.repos.d/sshfling.repo
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y sshfling
  else
    sudo yum install -y sshfling
  fi
}

uninstall_rpm() {
  if command -v rpm >/dev/null 2>&1 && rpm -q sshfling >/dev/null 2>&1; then
    if command -v dnf >/dev/null 2>&1; then
      sudo dnf --setopt=clean_requirements_on_remove=False remove -y sshfling
    else
      sudo yum remove -y sshfling
    fi
  fi
  sudo rm -f /etc/yum.repos.d/sshfling.repo /etc/pki/rpm-gpg/RPM-GPG-KEY-sshfling
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
