# Changelog

## v0.1.13 - 2026-07-07

Status: release candidate for the hardened enterprise package publishing pass.
Use the final GitHub release, tag, and workflow runs as the authoritative
evidence after `v0.1.13` is published.

### Prepared

- Added release security evidence hooks for baseline secret scanning, SPDX SBOM
  generation, dependency inventory, license reporting, Dockerfile hygiene,
  systemd hardening review, and matrix/manifest validation.
- Tightened uninstall scope documentation and validation. Package uninstall is
  documented as removing SSHFling-managed package files only, not host SSH
  state, password grant state, CA material, `/etc/sshfling`, original host
  configuration, or package-manager dependency state.
- Expanded package and cross-OS validation coverage around shared CLI checks,
  bounded workflow timeouts, Windows MSI metadata, macOS package metadata,
  public repository install paths, and community package manifests.
- Added GitHub Packages container publishing workflow coverage after the
  `v0.1.12` tag and prepared the follow-up `v0.1.13` release from the hardened
  source commit.

### Evidence Available

- Source version in `bin/sshfling` is `0.1.13`.
- Previous published release `v0.1.12` is tagged at commit
  `58b23b5fa9b90491c41b41fc206d8e907b00e8df`.
- GitHub release `v0.1.12` is published at
  https://github.com/GRWLX/sshfling/releases/tag/v0.1.12 with eight assets:
  `RELEASE-EVIDENCE.md`, `SHA256SUMS`, Linux DEB/RPM packages, source tarball,
  macOS pkg, Windows MSI, and Windows zip.
- Release checklist and evidence templates exist in
  `docs/release-checklist.md` and `docs/release-evidence.md`.
- Local release security evidence can be generated with
  `make release-security-scan` and validated with
  `make release-security-evidence-validate`.

### Evidence To Attach Or Except Before Enterprise Claims

- The release candidate must be built from a clean, final commit and matching
  `v0.1.13` tag.
- Attach `v0.1.13` workflow run URLs for release packages, public package web,
  package install tests, cross-OS validation, and container image tests.
- Attach `v0.1.13` package artifact checksums, generated evidence files,
  repository signing fingerprint, Pages deployment ID, release approval, and
  any accepted workflow exceptions.
- macOS notarization and Windows Authenticode evidence must be attached or
  formally excepted before enterprise publication claims.
- Optional external scanners are not required by the baseline generator unless
  strict mode is selected, but skipped scanner coverage should be called out in
  the release ticket.

## v0.1.12 - 2026-07-06

Status: tagged source release at
`58b23b5fa9b90491c41b41fc206d8e907b00e8df`.

### Shipped

- Prepared enterprise package publishing workflows, package-site generation,
  repository registration documentation, and release evidence templates.
- Added package builders and public package verification for Linux packages,
  macOS package outputs, Windows MSI/zip outputs, source archives, checksums,
  repository metadata, and community package manifests.
- Added release evidence generation and validation tooling for artifact
  inventories and release matrix checks.
- Expanded validation coverage across container tests, package install tests,
  cross-OS runtime checks, firewall OS compatibility checks, and packaged CLI
  validation.
- Added enterprise-facing documentation for operations, package publishing,
  security and compliance evidence collection, AI-assisted temporary access,
  and release readiness.
- Added detached job PID lifecycle handling, session PID reporting, 24-hour
  grant support, and validation fixes for Windows detached job behavior.

### Verified Release Evidence

- Immutable GitHub release URL and asset list:
  https://github.com/GRWLX/sshfling/releases/tag/v0.1.12.
- Passing tag-scoped `Release packages without web` run:
  https://github.com/GRWLX/sshfling/actions/runs/28824244828.
- Passing tag/source-commit `Container image tests` run:
  https://github.com/GRWLX/sshfling/actions/runs/28824243992.

### Evidence Still To Attach Or Except

- Failed tag-scoped `Release packages with public web` run:
  https://github.com/GRWLX/sshfling/actions/runs/28824244749. Rerun or approve
  an exception before using it as package-site validation evidence.
- Tag-scoped `Package install tests` and `Cross OS validation` run URLs, or a
  documented release-ticket approval for using older rehearsal runs from a
  different commit.
- `SHA256SUMS`, artifact provenance, repository signing fingerprint, Pages
  deployment ID, package-site artifact reference, and any signing or notarization
  outputs.

### Conservative Notes

- This changelog does not assert SOC 2, ISO 27001, FedRAMP, NIST, or similar
  certification.
- Published artifact integrity, signing status, and install validation remain
  release-ticket evidence items unless linked to immutable workflow runs and
  artifacts.
