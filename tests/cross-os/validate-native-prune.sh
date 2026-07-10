#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
helper="$repo_root/native/sshfling-native-prune"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "native prune validation failed: $*" >&2
  exit 1
}

new_session_root() {
  local name="$1"
  local state_root="$tmp/$name"
  local session_root="$state_root/sessions"

  mkdir -p "$session_root"
  chmod 0700 "$state_root" "$session_root"
  printf '%s\n' "$session_root"
}

write_session() {
  local session_root="$1"
  local username="$2"
  local expires_at="$3"
  local managed_by="${4:-sshfling}"
  local material_dir="$session_root/${username}-20260710T000000Z-deadbeef"
  local private_key="$material_dir/id_ed25519"
  local public_key="$material_dir/id_ed25519.pub"
  local certificate="$material_dir/id_ed25519-cert.pub"
  local metadata="$material_dir/sshfling-cert.json"

  mkdir -p "$material_dir"
  chmod 0700 "$material_dir"
  printf 'private\n' >"$private_key"
  printf 'public\n' >"$public_key"
  printf 'certificate\n' >"$certificate"
  chmod 0600 "$private_key"
  chmod 0644 "$public_key" "$certificate"
  jq -n \
    --arg managed_by "$managed_by" \
    --arg username "$username" \
    --arg private_key "$private_key" \
    --arg public_key "$public_key" \
    --arg certificate "$certificate" \
    --argjson expires_at "$expires_at" \
    '{version:1,managed_by:$managed_by,auth:"certificate",username:$username,principal:$username,expires_at:$expires_at,private_key:$private_key,public_key:$public_key,certificate:$certificate}' \
    >"$metadata"
  chmod 0600 "$metadata"
  printf '%s\n' "$material_dir"
}

set +e
"$helper" certificate --session-dir "$tmp/missing-selector" >"$tmp/missing-selector.out" 2>"$tmp/missing-selector.err"
missing_selector_status="$?"
"$helper" certificate --all --username duplicate --session-dir "$tmp/duplicate-selector" \
  >"$tmp/duplicate-selector.out" 2>"$tmp/duplicate-selector.err"
duplicate_selector_status="$?"
set -e
[[ "$missing_selector_status" -eq 2 ]] || fail "missing selector returned $missing_selector_status instead of 2"
[[ "$duplicate_selector_status" -eq 2 ]] || fail "duplicate selector returned $duplicate_selector_status instead of 2"
grep -Fq 'exactly one' "$tmp/missing-selector.err"
grep -Fq 'exactly one' "$tmp/duplicate-selector.err"

ancestry_target="$tmp/ancestry-target"
ancestry_link="$tmp/ancestry-link"
mkdir -p "$ancestry_target"
chmod 0700 "$ancestry_target"
ln -s "$ancestry_target" "$ancestry_link"
set +e
SSHFLING_PRUNE_NOW=1000 \
  "$helper" certificate --all --session-dir "$ancestry_link/new-parent/sessions" \
  >"$tmp/ancestry.out" 2>"$tmp/ancestry.err"
ancestry_status="$?"
set -e
[[ "$ancestry_status" -eq 77 ]] || fail "symlinked session ancestry returned $ancestry_status instead of 77"
test ! -e "$ancestry_target/new-parent"

cat >"$tmp/bash-env" <<EOF
printf '%s\n' injected >"$tmp/bash-env-ran"
EOF
missing_root_parent="$tmp/missing-root-state"
mkdir -p "$missing_root_parent"
chmod 0700 "$missing_root_parent"
BASH_ENV="$tmp/bash-env" SSHFLING_PRUNE_NOW=1000 \
  "$helper" certificate --all --session-dir "$missing_root_parent/sessions" >"$tmp/missing-root.out"
[[ ! -e "$tmp/bash-env-ran" ]] || fail "BASH_ENV executed before native prune hardening"
[[ ! -s "$tmp/missing-root.out" ]] || fail "missing session root emitted unexpected results"

active_root="$(new_session_root active-state)"
active_dir="$(write_session "$active_root" Deploy.User 1100)"
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --all --session-dir "$active_root" >"$tmp/active.out"
jq -e 'select(.username == "Deploy.User" and .status == "active" and .expires_at == 1100)' \
  "$tmp/active.out" >/dev/null
test -f "$active_dir/sshfling-cert.json"

dry_root="$(new_session_root dry-state)"
dry_dir="$(write_session "$dry_root" dryrun 1000)"
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --username dryrun --dry-run --session-dir "$dry_root" \
  >"$tmp/dry.out"
jq -e 'select(.status == "pruned" and .private_key.would_remove == true and .metadata.would_remove == true and .directory.would_remove_if_empty == true)' \
  "$tmp/dry.out" >/dev/null
test -f "$dry_dir/id_ed25519"
test -f "$dry_dir/sshfling-cert.json"

expired_root="$(new_session_root expired-state)"
expired_dir="$(write_session "$expired_root" expired 1000)"
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --username expired --session-dir "$expired_root" \
  >"$tmp/expired.out"
jq -e 'select(.status == "pruned" and .private_key.removed == true and .public_key.removed == true and .certificate.removed == true and .metadata.removed == true and .directory.removed == true)' \
  "$tmp/expired.out" >/dev/null
test ! -e "$expired_dir"

unmanaged_root="$(new_session_root unmanaged-state)"
unmanaged_dir="$(write_session "$unmanaged_root" unmanaged 900 operator)"
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --all --session-dir "$unmanaged_root" >"$tmp/unmanaged.out"
jq -e 'select(.username == "unmanaged" and .status == "skipped-unmanaged")' "$tmp/unmanaged.out" >/dev/null
test -f "$unmanaged_dir/sshfling-cert.json"

invalid_root="$(new_session_root invalid-state)"
invalid_dir="$invalid_root/invalid-20260710T000000Z-deadbeef"
mkdir -p "$invalid_dir"
chmod 0700 "$invalid_dir"
printf '{invalid\n' >"$invalid_dir/sshfling-cert.json"
chmod 0600 "$invalid_dir/sshfling-cert.json"
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --all --session-dir "$invalid_root" >"$tmp/invalid.out"
jq -e 'select(.status == "skipped-invalid-metadata")' "$tmp/invalid.out" >/dev/null
test -f "$invalid_dir/sshfling-cert.json"

unsafe_root="$(new_session_root unsafe-state)"
unsafe_dir="$(write_session "$unsafe_root" unsafe 900)"
outside_file="$tmp/operator-certificate.pub"
printf 'operator material\n' >"$outside_file"
chmod 0600 "$outside_file"
jq --arg certificate "$outside_file" '.certificate = $certificate' \
  "$unsafe_dir/sshfling-cert.json" >"$unsafe_dir/metadata.tmp"
mv "$unsafe_dir/metadata.tmp" "$unsafe_dir/sshfling-cert.json"
chmod 0600 "$unsafe_dir/sshfling-cert.json"
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --all --session-dir "$unsafe_root" >"$tmp/unsafe.out"
jq -e 'select(.username == "unsafe" and .status == "skipped-unsafe-path")' "$tmp/unsafe.out" >/dev/null
test -f "$unsafe_dir/id_ed25519"
test -f "$unsafe_dir/id_ed25519.pub"
test -f "$unsafe_dir/sshfling-cert.json"
test -f "$outside_file"

symlink_root="$(new_session_root symlink-state)"
symlink_dir="$(write_session "$symlink_root" symlinked 900)"
rm -f "$symlink_dir/id_ed25519-cert.pub"
ln -s "$outside_file" "$symlink_dir/id_ed25519-cert.pub"
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --all --session-dir "$symlink_root" >"$tmp/symlink.out"
jq -e 'select(.username == "symlinked" and .status == "skipped-unsafe-path")' "$tmp/symlink.out" >/dev/null
test -f "$symlink_dir/id_ed25519"
test -L "$symlink_dir/id_ed25519-cert.pub"
test -f "$symlink_dir/sshfling-cert.json"

permissions_root="$(new_session_root permissions-state)"
permissions_dir="$(write_session "$permissions_root" permissions 900)"
chmod 0666 "$permissions_dir/sshfling-cert.json" # release-security: intentional-world-writable-fixture
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --all --session-dir "$permissions_root" \
  >"$tmp/permissions.out"
jq -e 'select(.status == "skipped-unsafe-path")' "$tmp/permissions.out" >/dev/null
test -f "$permissions_dir/sshfling-cert.json"

missing_target_root="$(new_session_root missing-target-state)"
SSHFLING_PRUNE_NOW=1000 "$helper" certificate --username absent --session-dir "$missing_target_root" \
  >"$tmp/missing-target.out"
jq -e 'select(.username == "absent" and .status == "missing")' "$tmp/missing-target.out" >/dev/null

override_lock_root="$tmp/override-lock-state"
override_lock_file="$override_lock_root/custom-grant.lock"
mkdir -p "$override_lock_root"
chmod 0700 "$override_lock_root"
SSHFLING_GRANT_LOCK_FILE="$override_lock_file" SSHFLING_PRUNE_NOW=1000 \
  "$helper" certificate --username absent --session-dir "$missing_target_root" \
  >"$tmp/override-lock.out"
test -f "$override_lock_file"
jq -e 'select(.username == "absent" and .status == "missing")' "$tmp/override-lock.out" >/dev/null

lock_ancestry_target="$tmp/lock-ancestry-target"
lock_ancestry_link="$tmp/lock-ancestry-link"
mkdir -p "$lock_ancestry_target"
chmod 0700 "$lock_ancestry_target"
ln -s "$lock_ancestry_target" "$lock_ancestry_link"
set +e
SSHFLING_GRANT_LOCK_FILE="$lock_ancestry_link/new-parent/grant.lock" SSHFLING_PRUNE_NOW=1000 \
  "$helper" certificate --username absent --session-dir "$missing_target_root" \
  >"$tmp/lock-ancestry.out" 2>"$tmp/lock-ancestry.err"
lock_ancestry_status="$?"
set -e
[[ "$lock_ancestry_status" -eq 77 ]] \
  || fail "symlinked lock ancestry returned $lock_ancestry_status instead of 77"
test ! -e "$lock_ancestry_target/new-parent"

for discovery_tool in find sort; do
  discovery_root="$(new_session_root "${discovery_tool}-failure-state")"
  discovery_dir="$(write_session "$discovery_root" "${discovery_tool}failure" 900)"
  discovery_bin="$tmp/${discovery_tool}-failure-bin"
  mkdir -p "$discovery_bin"
  printf '#!/bin/sh\nexit 74\n' >"$discovery_bin/$discovery_tool"
  chmod 0755 "$discovery_bin" "$discovery_bin/$discovery_tool"
  set +e
  SSHFLING_NATIVE_TOOL_DIR="$discovery_bin" SSHFLING_PRUNE_NOW=1000 \
    "$helper" certificate --all --session-dir "$discovery_root" \
    >"$tmp/${discovery_tool}-failure.out" 2>"$tmp/${discovery_tool}-failure.err"
  discovery_status="$?"
  set -e
  [[ "$discovery_status" -eq 74 ]] \
    || fail "$discovery_tool failure returned $discovery_status instead of 74"
  grep -Fq 'could not enumerate certificate sessions' "$tmp/${discovery_tool}-failure.err"
  test -f "$discovery_dir/sshfling-cert.json"
done

failure_root="$(new_session_root failure-state)"
failure_dir="$(write_session "$failure_root" failure 900)"
failure_bin="$tmp/failure-bin"
mkdir -p "$failure_bin"
cat >"$failure_bin/rm" <<'SH'
#!/bin/sh
exit 74
SH
chmod 0755 "$failure_bin" "$failure_bin/rm"
set +e
SSHFLING_NATIVE_TOOL_DIR="$failure_bin" SSHFLING_PRUNE_NOW=1000 \
  "$helper" certificate --all --session-dir "$failure_root" >"$tmp/failure.out" 2>"$tmp/failure.err"
failure_status="$?"
set -e
[[ "$failure_status" -ne 0 ]] || fail "material removal failure returned success"
test -f "$failure_dir/sshfling-cert.json"

selective_failure_root="$(new_session_root selective-failure-state)"
selective_failure_dir="$(write_session "$selective_failure_root" selectivefailure 900)"
selective_failure_bin="$tmp/selective-failure-bin"
real_rm="$(command -v rm)"
mkdir -p "$selective_failure_bin"
cat >"$selective_failure_bin/rm" <<SH
#!/bin/sh
case "\$*" in
  *id_ed25519.pub*) exit 74 ;;
esac
exec "$real_rm" "\$@"
SH
chmod 0755 "$selective_failure_bin" "$selective_failure_bin/rm"
set +e
SSHFLING_NATIVE_TOOL_DIR="$selective_failure_bin" SSHFLING_PRUNE_NOW=1000 \
  "$helper" certificate --all --session-dir "$selective_failure_root" \
  >"$tmp/selective-failure.out" 2>"$tmp/selective-failure.err"
selective_failure_status="$?"
set -e
[[ "$selective_failure_status" -ne 0 ]] || fail "selective material removal failure returned success"
test -f "$selective_failure_dir/id_ed25519.pub"
test -f "$selective_failure_dir/sshfling-cert.json"

lock_root="$(new_session_root lock-state)"
write_session "$lock_root" locked 900 >/dev/null
lock_file="${lock_root%/*}/.sshfling-grant-state.lock"
(umask 077; : >"$lock_file")
chmod 0600 "$lock_file"
exec 8<>"$lock_file"
flock -n 8
set +e
SSHFLING_GRANT_LOCK_TIMEOUT_SECONDS=0 SSHFLING_PRUNE_NOW=1000 \
  "$helper" certificate --all --session-dir "$lock_root" >"$tmp/locked.out" 2>"$tmp/locked.err"
locked_status="$?"
set -e
exec 8>&-
[[ "$locked_status" -eq 75 ]] || fail "contended grant lock returned $locked_status instead of 75"
grep -Fq 'another SSHFling grant setup or prune operation is active' "$tmp/locked.err"

poison_bin="$tmp/poison-bin"
mkdir -p "$poison_bin"
cat >"$poison_bin/jq" <<EOF
#!/bin/sh
printf '%s\n' poisoned >"$tmp/poisoned-jq"
exit 70
EOF
chmod 0755 "$poison_bin/jq"
PATH="$poison_bin:/usr/bin:/bin" SSHFLING_PRUNE_NOW=1000 \
  "$helper" certificate --all --session-dir "$missing_target_root" >/dev/null
[[ ! -e "$tmp/poisoned-jq" ]] || fail "caller PATH selected an untrusted jq"

echo "native certificate prune validation ok"
