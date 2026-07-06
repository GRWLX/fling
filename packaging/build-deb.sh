#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=packaging/version.sh
source "$repo_root/packaging/version.sh"
version="$(assert_sshfling_version_matches_source "${SSHFLING_VERSION:-}" "$repo_root")"
dist_dir="$repo_root/dist"
stage="$repo_root/build/deb/sshfling_${version}_all"

rm -rf "$stage"
install -d "$stage/DEBIAN" "$stage/usr/bin" "$stage/usr/share/sshfling/templates" "$stage/usr/share/doc/sshfling" "$stage/lib/systemd/system"
install -d -m 0750 "$stage/etc/sshfling"

install -m 0755 "$repo_root/bin/sshfling" "$stage/usr/bin/sshfling"
install -m 0644 "$repo_root/packaging/policy.json" "$stage/etc/sshfling/policy.json"
install -m 0640 "$repo_root/systemd/sshflingd.env.example" "$stage/etc/sshfling/sshflingd.env"

# shellcheck source=packaging/copy-templates.sh
source "$repo_root/packaging/copy-templates.sh"
copy_sshfling_templates "$repo_root" "$stage/usr/share/sshfling/templates"

install -m 0644 "$repo_root/README.md" "$stage/usr/share/doc/sshfling/README.md"
install -m 0644 "$repo_root/LICENSE" "$stage/usr/share/doc/sshfling/LICENSE"
install -m 0644 "$repo_root/systemd/sshflingd.env.example" "$stage/usr/share/doc/sshfling/sshflingd.env.example"
install -m 0644 "$repo_root/systemd/sshflingd.service" "$stage/lib/systemd/system/sshflingd.service"

cat >"$stage/DEBIAN/control" <<CONTROL
Package: sshfling
Version: $version
Section: utils
Priority: optional
Architecture: all
Depends: python3, openssh-client, passwd, procps, util-linux
Suggests: openssh-server, docker.io | docker-ce | podman-docker
Maintainer: SSHFling Maintainers <root@localhost>
Description: Temporary SSH access broker and CLI
 SSHFling grants short-lived SSH access with default password grants, optional
 OpenSSH user certificates, and a forced session wrapper so temporary SSH
 sessions are capped by a server-side wall-clock timeout. Docker Compose files
 are included as a test harness.
CONTROL

cat >"$stage/DEBIAN/conffiles" <<'CONFFILES'
/etc/sshfling/policy.json
/etc/sshfling/sshflingd.env
CONFFILES

cat >"$stage/DEBIAN/postinst" <<'POSTINST'
#!/bin/sh
set -e

state_root=/var/lib/sshfling
state_dir=$state_root/package-state
state_file=$state_dir/install-state

group_exists() {
  if command -v getent >/dev/null 2>&1; then
    getent group sshflingd >/dev/null 2>&1
  else
    grep -q '^sshflingd:' /etc/group
  fi
}

user_exists() {
  if command -v getent >/dev/null 2>&1; then
    getent passwd sshflingd >/dev/null 2>&1
  else
    grep -q '^sshflingd:' /etc/passwd
  fi
}

record_install_state() {
  if [ -f "$state_file" ]; then
    return 0
  fi

  group_preexisting=no
  user_preexisting=no
  var_dir_preexisting=no
  if group_exists; then
    group_preexisting=yes
  fi
  if user_exists; then
    user_preexisting=yes
  fi
  if [ -e /var/lib/sshflingd ]; then
    var_dir_preexisting=yes
  fi

  install -d -m 0750 -o root -g root "$state_root"
  install -d -m 0700 -o root -g root "$state_dir"
  {
    echo "group_preexisting=$group_preexisting"
    echo "user_preexisting=$user_preexisting"
    echo "var_dir_preexisting=$var_dir_preexisting"
  } >"$state_file"
  chmod 0600 "$state_file"
}

ensure_account() {
  if ! group_exists; then
    if command -v groupadd >/dev/null 2>&1; then
      groupadd --system sshflingd 2>/dev/null || groupadd -r sshflingd
    elif command -v addgroup >/dev/null 2>&1; then
      addgroup --system sshflingd
    else
      echo "sshfling: cannot create sshflingd group; groupadd or addgroup is required" >&2
      exit 1
    fi
  fi

  if ! user_exists; then
    nologin=/usr/sbin/nologin
    if [ ! -x "$nologin" ] && [ -x /sbin/nologin ]; then
      nologin=/sbin/nologin
    fi

    if command -v useradd >/dev/null 2>&1; then
      useradd --system --gid sshflingd --home-dir /var/lib/sshflingd --shell "$nologin" --no-create-home sshflingd 2>/dev/null \
        || useradd -r -g sshflingd -d /var/lib/sshflingd -s "$nologin" -M sshflingd
    elif command -v adduser >/dev/null 2>&1; then
      adduser --system --ingroup sshflingd --home /var/lib/sshflingd --no-create-home --shell "$nologin" sshflingd
    else
      echo "sshfling: cannot create sshflingd user; useradd or adduser is required" >&2
      exit 1
    fi
  fi
}

reload_systemd() {
  if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null 2>&1 || true
  fi
}

case "$1" in
  configure)
    record_install_state
    ensure_account
    install -d -m 0750 -o root -g sshflingd /etc/sshfling
    install -d -m 0750 -o sshflingd -g sshflingd /var/lib/sshflingd
    if [ -f /etc/sshfling/policy.json ] && [ ! -L /etc/sshfling/policy.json ]; then
      chown root:root /etc/sshfling/policy.json
      chmod 0644 /etc/sshfling/policy.json
    fi
    if [ -f /etc/sshfling/sshflingd.env ] && [ ! -L /etc/sshfling/sshflingd.env ]; then
      chown root:sshflingd /etc/sshfling/sshflingd.env
      chmod 0640 /etc/sshfling/sshflingd.env
    fi
    reload_systemd
    if [ -n "${2:-}" ] && command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
      if systemctl is-active --quiet sshflingd.service; then
        systemctl try-restart sshflingd.service >/dev/null 2>&1 || true
      fi
    fi
    ;;
esac

exit 0
POSTINST

cat >"$stage/DEBIAN/prerm" <<'PRERM'
#!/bin/sh
set -e

case "$1" in
  remove|deconfigure)
    if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
      systemctl disable --now sshflingd.service >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
PRERM

cat >"$stage/DEBIAN/postrm" <<'POSTRM'
#!/bin/sh
set -e

state_root=/var/lib/sshfling
state_dir=$state_root/package-state
state_file=$state_dir/install-state

user_exists() {
  if command -v getent >/dev/null 2>&1; then
    getent passwd sshflingd >/dev/null 2>&1
  else
    grep -q '^sshflingd:' /etc/passwd
  fi
}

group_exists() {
  if command -v getent >/dev/null 2>&1; then
    getent group sshflingd >/dev/null 2>&1
  else
    grep -q '^sshflingd:' /etc/group
  fi
}

var_lib_is_empty() {
  if [ ! -d /var/lib/sshflingd ]; then
    return 0
  fi
  if find /var/lib/sshflingd -mindepth 1 -maxdepth 1 | grep -q .; then
    return 1
  fi
  return 0
}

read_install_state() {
  if [ ! -f "$state_file" ] || [ -L "$state_file" ]; then
    return 0
  fi

  state_owner="$(stat -c %u "$state_file" 2>/dev/null || echo unknown)"
  if [ "$state_owner" != "0" ]; then
    echo "sshfling: ignoring non-root-owned install state $state_file" >&2
    return 0
  fi

  while IFS='=' read -r key value; do
    case "$key" in
      group_preexisting)
        if [ "$value" = "yes" ] || [ "$value" = "no" ]; then
          group_preexisting="$value"
        fi
        ;;
      user_preexisting)
        if [ "$value" = "yes" ] || [ "$value" = "no" ]; then
          user_preexisting="$value"
        fi
        ;;
      var_dir_preexisting)
        if [ "$value" = "yes" ] || [ "$value" = "no" ]; then
          var_dir_preexisting="$value"
        fi
        ;;
    esac
  done < "$state_file"
}

remove_package_state() {
  rm -rf "$state_dir"
  rmdir "$state_root" 2>/dev/null || true
}

remove_created_account_if_safe() {
  group_preexisting=yes
  user_preexisting=yes
  var_dir_preexisting=yes

  read_install_state

  if [ "${var_dir_preexisting:-yes}" = "no" ] && var_lib_is_empty; then
    rmdir /var/lib/sshflingd 2>/dev/null || true
  fi
  remove_package_state

  if [ -d /etc/sshfling ] || [ -d /var/lib/sshflingd ]; then
    return 0
  fi

  if [ "${user_preexisting:-yes}" = "no" ] && user_exists; then
    if command -v userdel >/dev/null 2>&1; then
      userdel sshflingd >/dev/null 2>&1 || true
    elif command -v deluser >/dev/null 2>&1; then
      deluser --system sshflingd >/dev/null 2>&1 || deluser sshflingd >/dev/null 2>&1 || true
    fi
  fi

  if [ "${group_preexisting:-yes}" = "no" ] && group_exists && ! user_exists; then
    if command -v groupdel >/dev/null 2>&1; then
      groupdel sshflingd >/dev/null 2>&1 || true
    elif command -v delgroup >/dev/null 2>&1; then
      delgroup --system sshflingd >/dev/null 2>&1 || delgroup sshflingd >/dev/null 2>&1 || true
    fi
  fi
}

case "$1" in
  remove|purge|abort-install|abort-upgrade|disappear)
    if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
      systemctl daemon-reload >/dev/null 2>&1 || true
    fi
    ;;
esac

case "$1" in
  purge)
    rm -f /etc/sshfling/policy.json /etc/sshfling/sshflingd.env
    rmdir /etc/sshfling 2>/dev/null || true
    remove_created_account_if_safe
    ;;
esac

exit 0
POSTRM

chmod 0755 "$stage/DEBIAN/postinst" "$stage/DEBIAN/prerm" "$stage/DEBIAN/postrm"

install -d "$dist_dir"
dpkg-deb --build --root-owner-group "$stage" "$dist_dir/sshfling_${version}_all.deb"
echo "$dist_dir/sshfling_${version}_all.deb"
