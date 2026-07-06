#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=packaging/version.sh
source "$repo_root/packaging/version.sh"
version="$(assert_sshfling_version_matches_source "${SSHFLING_VERSION:-}" "$repo_root")"
dist_dir="$repo_root/dist"
topdir="$repo_root/build/rpm"
payload="$topdir/payload"

if ! command -v rpmbuild >/dev/null 2>&1; then
  echo "rpmbuild is required to build an RPM package." >&2
  exit 127
fi

rm -rf "$topdir"
install -d "$topdir/BUILD" "$topdir/RPMS" "$topdir/SOURCES" "$topdir/SPECS" "$topdir/SRPMS"
install -d -m 0750 "$payload/etc/sshfling"
install -d "$payload/usr/bin" "$payload/usr/share/sshfling/templates" "$payload/usr/share/doc/sshfling" "$payload/usr/lib/systemd/system"

install -m 0755 "$repo_root/bin/sshfling" "$payload/usr/bin/sshfling"
install -m 0644 "$repo_root/packaging/policy.json" "$payload/etc/sshfling/policy.json"
install -m 0640 "$repo_root/systemd/sshflingd.env.example" "$payload/etc/sshfling/sshflingd.env"

# shellcheck source=packaging/copy-templates.sh
source "$repo_root/packaging/copy-templates.sh"
copy_sshfling_templates "$repo_root" "$payload/usr/share/sshfling/templates"
install -m 0644 "$repo_root/README.md" "$payload/usr/share/doc/sshfling/README.md"
install -m 0644 "$repo_root/LICENSE" "$payload/usr/share/doc/sshfling/LICENSE"
install -m 0644 "$repo_root/systemd/sshflingd.env.example" "$payload/usr/share/doc/sshfling/sshflingd.env.example"
install -m 0644 "$repo_root/systemd/sshflingd.service" "$payload/usr/lib/systemd/system/sshflingd.service"

tar -C "$payload" -czf "$topdir/SOURCES/sshfling-files-${version}.tar.gz" .

cat >"$topdir/SPECS/sshfling.spec" <<SPEC
Name: sshfling
Version: $version
Release: 1%{?dist}
Summary: Temporary SSH access broker and CLI
License: LicenseRef-SSHFling-Commercial
BuildArch: noarch
Requires: python3
Requires: openssh-clients
Requires: shadow-utils
Requires(pre): shadow-utils
Requires: procps-ng
Requires: util-linux
Source0: sshfling-files-${version}.tar.gz

%description
SSHFling grants short-lived SSH access with default password grants, optional
OpenSSH user certificates, and a forced session wrapper so temporary SSH
sessions are capped by a server-side wall-clock timeout. Docker Compose files
are included as a test harness.

%prep

%build

%install
mkdir -p %{buildroot}
tar -C %{buildroot} -xzf %{SOURCE0}

%pre
set -e

state_root=/var/lib/sshfling
state_dir=\$state_root/package-state
state_file=\$state_dir/install-state

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
  if [ -f "\$state_file" ]; then
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

  install -d -m 0750 -o root -g root "\$state_root"
  install -d -m 0700 -o root -g root "\$state_dir"
  {
    echo "group_preexisting=\$group_preexisting"
    echo "user_preexisting=\$user_preexisting"
    echo "var_dir_preexisting=\$var_dir_preexisting"
  } > "\$state_file"
  chmod 0600 "\$state_file"
}

record_install_state

if ! group_exists; then
  groupadd --system sshflingd 2>/dev/null || groupadd -r sshflingd
fi

if ! user_exists; then
  nologin=/usr/sbin/nologin
  if [ ! -x "\$nologin" ] && [ -x /sbin/nologin ]; then
    nologin=/sbin/nologin
  fi
  useradd --system --gid sshflingd --home-dir /var/lib/sshflingd --shell "\$nologin" --no-create-home sshflingd 2>/dev/null \
    || useradd -r -g sshflingd -d /var/lib/sshflingd -s "\$nologin" -M sshflingd
fi

exit 0

%post
set -e

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
if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
  systemctl daemon-reload >/dev/null 2>&1 || true
fi

exit 0

%preun
set -e

state_root=/var/lib/sshfling
preserve_dir=\$state_root/rpm-preserve-config

if [ "\$1" -eq 0 ]; then
  install -d -m 0750 -o root -g root "\$state_root"
  rm -rf "\$preserve_dir"
  install -d -m 0700 -o root -g root "\$preserve_dir"
  for path in /etc/sshfling/policy.json /etc/sshfling/sshflingd.env; do
    if [ -f "\$path" ] && [ ! -L "\$path" ]; then
      cp -p "\$path" "\$preserve_dir/\$(basename "\$path")"
    fi
  done
fi

if [ "\$1" -eq 0 ] && command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
  systemctl disable --now sshflingd.service >/dev/null 2>&1 || true
fi

exit 0

%postun
set -e

state_root=/var/lib/sshfling
preserve_dir=\$state_root/rpm-preserve-config
state_dir=\$state_root/package-state
state_file=\$state_dir/install-state

restore_config() {
  src="\$1"
  dst="\$2"
  mode="\$3"
  owner="\$4"
  group="\$5"

  if [ ! -f "\$src" ]; then
    return 0
  fi

  rpmsave="\$dst.rpmsave"
  if [ -f "\$rpmsave" ]; then
    rm -f "\$rpmsave"
  fi

  if getent group "\$group" >/dev/null 2>&1; then
    install -m "\$mode" -o "\$owner" -g "\$group" "\$src" "\$dst" 2>/dev/null \
      || cp -p "\$src" "\$dst"
  else
    install -m "\$mode" -o "\$owner" -g root "\$src" "\$dst" 2>/dev/null \
      || cp -p "\$src" "\$dst"
  fi
}

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
  if [ ! -f "\$state_file" ] || [ -L "\$state_file" ]; then
    return 0
  fi

  state_owner="\$(stat -c %u "\$state_file" 2>/dev/null || echo unknown)"
  if [ "\$state_owner" != "0" ]; then
    echo "sshfling: ignoring non-root-owned install state \$state_file" >&2
    return 0
  fi

  while IFS='=' read -r key value; do
    case "\$key" in
      group_preexisting)
        if [ "\$value" = "yes" ] || [ "\$value" = "no" ]; then
          group_preexisting="\$value"
        fi
        ;;
      user_preexisting)
        if [ "\$value" = "yes" ] || [ "\$value" = "no" ]; then
          user_preexisting="\$value"
        fi
        ;;
      var_dir_preexisting)
        if [ "\$value" = "yes" ] || [ "\$value" = "no" ]; then
          var_dir_preexisting="\$value"
        fi
        ;;
    esac
  done < "\$state_file"
}

remove_package_state() {
  rm -rf "\$state_dir" "\$preserve_dir"
  rmdir "\$state_root" 2>/dev/null || true
}

remove_created_account_if_safe() {
  group_preexisting=yes
  user_preexisting=yes
  var_dir_preexisting=yes

  read_install_state

  if [ "\${var_dir_preexisting:-yes}" = "no" ] && var_lib_is_empty; then
    rmdir /var/lib/sshflingd 2>/dev/null || true
  fi
  remove_package_state

  if [ -d /etc/sshfling ] || [ -d /var/lib/sshflingd ]; then
    return 0
  fi

  if [ "\${user_preexisting:-yes}" = "no" ] && user_exists; then
    userdel sshflingd >/dev/null 2>&1 || true
  fi

  if [ "\${group_preexisting:-yes}" = "no" ] && group_exists && ! user_exists; then
    groupdel sshflingd >/dev/null 2>&1 || true
  fi
}

if [ "\$1" -eq 0 ] && [ -d "\$preserve_dir" ]; then
  install -d -m 0750 /etc/sshfling
  if getent group sshflingd >/dev/null 2>&1; then
    chown root:sshflingd /etc/sshfling 2>/dev/null || true
  else
    chown root:root /etc/sshfling 2>/dev/null || true
  fi
  restore_config "\$preserve_dir/policy.json" /etc/sshfling/policy.json 0644 root root
  restore_config "\$preserve_dir/sshflingd.env" /etc/sshfling/sshflingd.env 0640 root sshflingd
  rm -rf "\$preserve_dir"
  rmdir "\$state_root" 2>/dev/null || true
fi

if [ "\$1" -eq 0 ]; then
  remove_created_account_if_safe
fi

if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
  systemctl daemon-reload >/dev/null 2>&1 || true
  if [ "\$1" -ge 1 ] && systemctl is-active --quiet sshflingd.service; then
    systemctl try-restart sshflingd.service >/dev/null 2>&1 || true
  fi
fi

exit 0

%files
%dir %attr(0750,root,sshflingd) /etc/sshfling
%config(noreplace) %attr(0644,root,root) /etc/sshfling/policy.json
%config(noreplace) %attr(0640,root,sshflingd) /etc/sshfling/sshflingd.env
%attr(0755,root,root) /usr/bin/sshfling
/usr/share/sshfling/templates
/usr/share/doc/sshfling/README.md
/usr/share/doc/sshfling/LICENSE
/usr/share/doc/sshfling/sshflingd.env.example
/usr/lib/systemd/system/sshflingd.service

%changelog
* Fri Jul 03 2026 SSHFling Maintainers <root@localhost> - ${version}-1
- Initial package
SPEC

rpmbuild --define "_topdir $topdir" -bb "$topdir/SPECS/sshfling.spec"

install -d "$dist_dir"
find "$topdir/RPMS" -type f -name "sshfling-${version}-*.rpm" -exec cp {} "$dist_dir/" \;
find "$dist_dir" -type f -name "sshfling-${version}-*.rpm" -print
