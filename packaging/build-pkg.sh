#!/usr/bin/env bash
set -euo pipefail

identifier="${SSHFLING_PKG_IDENTIFIER:-io.sshfling.cli}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=packaging/version.sh
source "$repo_root/packaging/version.sh"
version="$(assert_sshfling_version_matches_source "${SSHFLING_VERSION:-}" "$repo_root")"
dist_dir="$repo_root/dist"
build_root="$repo_root/build/pkg"
payload="$build_root/payload"
resources="$build_root/resources"
distribution="$build_root/Distribution.xml"
component_pkg="$build_root/sshfling-component.pkg"
product_pkg="$dist_dir/sshfling-${version}.pkg"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macOS package builds must run on macOS." >&2
  exit 127
fi

for tool in pkgbuild productbuild; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$tool is required to build a macOS pkg." >&2
    exit 127
  fi
done

rm -rf "$build_root"
install -d "$payload/etc/sshfling" "$payload/usr/local/bin" "$payload/usr/local/share/sshfling" "$payload/usr/local/share/sshfling/templates" "$resources" "$dist_dir"

install -m 0755 "$repo_root/bin/sshfling" "$payload/usr/local/bin/sshfling"
install -m 0644 "$repo_root/packaging/policy.json" "$payload/etc/sshfling/policy.json"
install -m 0644 "$repo_root/LICENSE" "$payload/usr/local/share/sshfling/LICENSE"
install -m 0644 "$repo_root/LICENSE" "$resources/LICENSE"

# shellcheck source=packaging/copy-templates.sh
source "$repo_root/packaging/copy-templates.sh"
copy_sshfling_templates "$repo_root" "$payload/usr/local/share/sshfling/templates"

cat >"$resources/README.pkg.txt" <<README
SSHFling ${version} package notes

Installed files:
- /usr/local/bin/sshfling
- /usr/local/share/sshfling
- /etc/sshfling/policy.json

Runtime dependencies:
- The macOS pkg does not bundle Python or OpenSSH.
- Client commands require python3 and OpenSSH client tools on PATH.
- Server-side host setup requires the target host's OpenSSH server tooling.

Uninstall and revert scope:
- The published uninstall helper removes the SSHFling command and packaged
  templates, then forgets the pkg receipt.
- It intentionally preserves /etc/sshfling because that directory can contain
  local policy, CA material, or operator-managed configuration.
- Package uninstall does not remove host SSH configuration, temporary password
  grant state, local CA keys, Python, OpenSSH, or other dependency state.
- Exact preinstall state restoration must come from MDM, fleet configuration,
  backups, or another source of recorded original state.
README

cat >"$distribution" <<XML
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
  <title>SSHFling</title>
  <readme file="README.pkg.txt" mime-type="text/plain"/>
  <license file="LICENSE"/>
  <options customize="never" require-scripts="false"/>
  <domains enable_anywhere="false" enable_currentUserHome="false" enable_localSystem="true"/>
  <choices-outline>
    <line choice="default"/>
  </choices-outline>
  <choice id="default" title="SSHFling">
    <pkg-ref id="$identifier"/>
  </choice>
  <pkg-ref id="$identifier" version="$version" onConclusion="none">sshfling-component.pkg</pkg-ref>
</installer-gui-script>
XML

pkgbuild \
  --root "$payload" \
  --identifier "$identifier" \
  --version "$version" \
  --install-location / \
  "$component_pkg"

productbuild \
  --distribution "$distribution" \
  --package-path "$build_root" \
  --resources "$resources" \
  "$product_pkg"

echo "$product_pkg"
