# Release Evidence Packet

Use this template for every production package release. The completed packet should live in the release ticket or controlled evidence repository and should link back to immutable workflow runs, artifacts, and approvals.

This packet supports SOC 2, ISO 27001:2022, and NIST SP 800-53 Rev. 5 evidence
collection. It is not legal advice and does not assert certification or
attestation by itself.

Release version:

Release date:

Release owner:

Change ticket:

Source tag:

Source commit SHA:

Pages deployment URL:

Pages deployment ID:

Package-site artifact name:

Previous known-good version:

Compliance mapping reference: [compliance-mapping.md](compliance-mapping.md)

Threat model reference: [threat-model.md](threat-model.md)

OpenSSH dependency policy reference: [openssh-dependencies.md](openssh-dependencies.md)

NIST control selection or baseline, if applicable:

SOC 2 system boundary and trust service categories, if applicable:

ISO/IEC 27001 statement of applicability reference, if applicable:

CIS Benchmark or equivalent hardening profile, if applicable:

Non-certification caveat acknowledged by release approver: Yes / No

## v0.1.12/vNext Working Snapshot

Use this snapshot to seed the release ticket. Replace it with final, immutable
evidence before publication.

- `v0.1.12` is tagged at source commit
  `58b23b5fa9b90491c41b41fc206d8e907b00e8df` on 2026-07-06.
- Remote `refs/tags/v0.1.12` is annotated tag object
  `8630c5aeacd8bc33021e4c6f51e7a0feb9dd2e08`; the peeled commit is
  `58b23b5fa9b90491c41b41fc206d8e907b00e8df`. Local signature verification
  reported `error: no signature found`, so treat tag signature evidence as
  absent unless a separate protected-tag control is attached.
- GitHub release `v0.1.12` is published, not draft, and not prerelease:
  https://github.com/GRWLX/sshfling/releases/tag/v0.1.12. GitHub reports it
  was created at 2026-07-06T21:23:39Z and published at 2026-07-06T21:24:55Z.
  The release has eight assets: `RELEASE-EVIDENCE.md`, `SHA256SUMS`,
  `sshfling_0.1.12_all.deb`, `sshfling-0.1.12-1.noarch.rpm`,
  `sshfling-0.1.12.tar.gz`, `sshfling-0.1.12.pkg`,
  `sshfling-0.1.12.msi`, and `sshfling-0.1.12-windows.zip`.
- `v0.1.12` shipped enterprise package publishing preparation: package builders,
  public package-site verification, release checklist/evidence templates,
  repository registration docs, community manifests, release matrix tooling,
  cross-OS/package install validation, container image tests, and enterprise
  operations documentation.
- `HEAD` after the tag is
  `0226f12f9761d1b88fcf5a9fe3ee1108d3b6821c` and adds GitHub Packages
  container publishing workflow coverage.
- The current working tree includes uncommitted vNext release-hardening changes
  in workflows, package metadata, release security evidence tooling, uninstall
  behavior documentation, package validation, and cross-OS tests. Do not use the
  current tree for a production release until those changes are committed and
  validated.

GitHub Actions state verified on 2026-07-06:

- Tag/source commit `58b23b5fa9b90491c41b41fc206d8e907b00e8df` has successful
  `Container image tests` run
  https://github.com/GRWLX/sshfling/actions/runs/28824243992.
- Tag/source commit `58b23b5fa9b90491c41b41fc206d8e907b00e8df` has successful
  `Release packages without web` run
  https://github.com/GRWLX/sshfling/actions/runs/28824244828.
- Tag/source commit `58b23b5fa9b90491c41b41fc206d8e907b00e8df` has failed
  `Release packages with public web` run
  https://github.com/GRWLX/sshfling/actions/runs/28824244749. Do not cite this
  as passing package-site evidence without a rerun or approved exception.
- No tag-scoped `Package install tests` or `Cross OS validation` runs for
  `58b23b5fa9b90491c41b41fc206d8e907b00e8df` were found in the filtered GitHub
  Actions run lists checked by `gh`. The latest matching successes found were
  workflow-dispatch runs from 2026-07-05 at commit
  `80b8b412a2f65dd7d263c3bae95a0f2090f30427`; treat them as pre-release
  rehearsal evidence unless the release ticket explicitly accepts the commit
  mismatch.
- Post-tag commit `0226f12f9761d1b88fcf5a9fe3ee1108d3b6821c` has successful
  `GitHub Packages` run
  https://github.com/GRWLX/sshfling/actions/runs/28825062989 and successful
  `Container image tests` run
  https://github.com/GRWLX/sshfling/actions/runs/28825062950. Treat these as
  vNext/GitHub Packages workflow evidence, not as evidence that the `v0.1.12`
  source release passed all package validation.

Evidence currently present in the repository:

- Source tag and commit history for `v0.1.12`.
- Published GitHub release URL and asset list for `v0.1.12`.
- Release checklist and evidence templates.
- Release asset evidence generator and matrix validator.
- Release security evidence generator for baseline secret scanning, SBOM,
  dependency inventory, license scan, Dockerfile hygiene, systemd hardening, and
  optional external scanner records.
- Compliance mapping, threat model, and OpenSSH dependency policy documents.
- README and release checklist language for password default, explicit
  certificate mode, access-level classification, prune limits, and uninstall
  limits.

Evidence still required before enterprise publication:

- Clean final commit, protected release approval, and matching tag or workflow
  version input.
- Passing immutable workflow URLs for release packages, public package site,
  package install tests, cross-OS validation, and container image tests. The
  current tag-scoped public-web run is failed, and tag-scoped package-install
  and cross-OS runs were not found.
- Artifact inventory with SHA-256 values, sizes, signing status, release asset
  URLs, `SHA256SUMS`, and provenance or attestation output.
- APT/RPM production signing fingerprint and proof that generated test keys were
  not used.
- macOS notarization and Windows Authenticode verification output, or approved
  exception records.
- Pages deployment URL, deployment ID, package-site artifact name, rollback
  owner, and previous known-good restore source.
- Access-level policy evidence for any operator, sudo-limited, admin, or
  root-equivalent grant paths, including host-control evidence for actual
  privileges.

Generated evidence handling:

- Store generated release matrices, manifests, and artifact evidence under the
  ignored `docs/release/enterprise-release-evidence/` tree.
- Attach or link the reviewed generated files from the release ticket or
  controlled evidence repository instead of committing generated evidence.
- Treat any generated matrix or manifest outside the ignored evidence tree as a
  release hygiene exception that must be moved or explicitly approved.

## Compliance Mapping Status

Use this section to confirm that the release evidence is mapped without
overstating compliance. A mapped control is not an attestation unless the
organization's audit or certification process accepts the evidence.

| Control objective | Mapping source | Evidence owner | Result or exception |
| --- | --- | --- | --- |
| Release authorization and change traceability | [compliance-mapping.md](compliance-mapping.md) |  |  |
| Build and package integrity | [compliance-mapping.md](compliance-mapping.md) |  |  |
| Repository and artifact signing | [compliance-mapping.md](compliance-mapping.md) |  |  |
| Secrets and privileged release access | [compliance-mapping.md](compliance-mapping.md) |  |  |
| Security testing and vulnerability management | [compliance-mapping.md](compliance-mapping.md) |  |  |
| Logging, audit trail, and retention | [compliance-mapping.md](compliance-mapping.md) |  |  |
| Host access and account lifecycle | [compliance-mapping.md](compliance-mapping.md) |  |  |
| CIS-style host and service hardening | [compliance-mapping.md](compliance-mapping.md) |  |  |
| Rollback, incident handling, and recovery | [compliance-mapping.md](compliance-mapping.md) |  |  |
| Customer assurance and residual-risk acceptance | [compliance-mapping.md](compliance-mapping.md) |  |  |

## Approval Gates

| Gate | Required evidence | Result |
| --- | --- | --- |
| Release request approved | Ticket URL, approver, approval timestamp | Pending |
| Compliance mapping reviewed | Control scope, caveats, evidence owner, and exceptions recorded above | Pending |
| Source ready | Protected branch status, PR review, commit SHA | Pending |
| Tag approved | Tag name, tag creator, protected-tag rule, signature status if used | Pending |
| Build validation passed | `Release packages without web` or equivalent run URL | Pending |
| Package-site validation passed | `Release packages with public web` run URL and `verify-public-web` output | Pending |
| Post-publish install validation passed | `Package install tests` run URL | Pending |
| Cross-OS validation passed | `Cross OS validation` run URL, matrix result summary | Pending |
| Runtime behavior docs verified | README, repo docs, wiki, and release notes match implemented password, certificate, access-level, prune, and uninstall behavior | Pending |
| Security gates passed | Secret scan, SBOM, license scan, dependency inventory, SAST, shell lint, Dockerfile lint, vulnerability scan, systemd review | Pending |
| Rollback ready | Previous version, restore source, authorized rollback owner | Pending |

## Artifact Inventory

Record every published artifact, including package-site outputs and release assets.

| Artifact | Source workflow | SHA-256 | Size | Signed | Verification evidence |
| --- | --- | --- | --- | --- | --- |
| `sshfling_VERSION_all.deb` |  |  |  |  |  |
| `sshfling-VERSION-1.noarch.rpm` |  |  |  |  |  |
| `sshfling-VERSION.tar.gz` |  |  |  |  |  |
| `sshfling-VERSION.pkg` |  |  |  |  |  |
| `sshfling-VERSION.msi` |  |  |  |  |  |
| `sshfling-VERSION-windows.zip` |  |  |  |  |  |
| `security-scans/sbom.spdx.json` | `make release-security-scan` or equivalent |  |  | N/A | Generated SPDX SBOM and `security-scan-manifest.json` |
| `apt/InRelease` |  |  |  |  |  |
| `apt/Release.gpg` |  |  |  |  |  |
| `rpm/repodata/repomd.xml.asc` |  |  |  |  |  |

## Runtime Behavior Evidence

Record the behavior contract that users and support teams rely on.

| Behavior | Expected release statement | Evidence |
| --- | --- | --- |
| Password default | Bare `sudo sshfling` creates temporary password access. | README/release-notes link: |
| Explicit certificate mode | Certificate access requires `--certificate`; certificate-only setup options fail without it. | README/release-notes link: |
| Access-level classification | `--access-level` and `--role` classify least-privilege policy intent and do not grant sudo, administrator, group, IAM, or root-equivalent privileges. Host controls enforce actual privileges. | README/wiki/test link: |
| Prune semantics | `password prune` removes expired tracked grants only; active grants and unmanaged records are preserved; existing users explicitly allowed with `--allow-existing-user` are locked/expired but not deleted. | Test or docs link: |
| Host uninstall scope | `host uninstall` removes managed certificate host config by default; shared CA, wrapper, policy-user, and Unix-account removal are opt-in. | Docs link: |
| Package uninstall scope | Package uninstall removes package files and managed repo entries, but not host SSH state, password grant state, CA material, `/etc/sshfling` config, dependency package state, or original host configuration. Dependency autoremove/autopurge is a separate fleet action. macOS package notes and Windows MSI metadata state this scope. | Docs or metadata link: |

## Threat Model And Dependency Review

Use this section to record that release-specific security assumptions still
match the implementation and deployment plan. Do not treat this as a penetration
test or external security assessment.

| Review item | Evidence source | Result or exception |
| --- | --- | --- |
| Threat-model assumptions reviewed | [threat-model.md](threat-model.md), release notes, deployment plan |  |
| Package supply-chain abuse paths accepted or mitigated | Release workflows, protected tag/environment evidence, signing evidence |  |
| Privileged temporary-access risks accepted or mitigated | Policy file, access-level evidence, customer host-control evidence |  |
| Issuer and CA custody risks accepted or mitigated | CA key permissions, issuer token storage, service exposure review |  |
| OpenSSH dependency ownership confirmed | [openssh-dependencies.md](openssh-dependencies.md), package metadata, fleet dependency policy |  |
| Original-state evidence retained where full revert is promised | MDM, Intune, Group Policy, configuration-management, backup, or package inventory records |  |

## CIS-Style Hardening Evidence

This section supports CIS Controls and benchmark-style reviews. It does not
claim conformance to a specific CIS Benchmark unless scan results and exceptions
are attached.

| Area | Evidence source | Result or exception |
| --- | --- | --- |
| Package manager trust is strict | `packaging/verify-public-web.sh`, repo config samples, package-site output |  |
| APT/RPM production signing key is stable and approved | GPG fingerprint, key owner, access review |  |
| Direct artifact checksums are retained | `downloads/SHA256SUMS`, release asset list |  |
| `/etc/sshfling` and `policy.json` ownership is enforced | Package manifest or configuration-management record |  |
| Access-level policy classification is least-privilege | Policy file, grant metadata, host IAM/sudo/PAM/AD/MDM/service-control evidence |  |
| CA key and issuer token access is restricted | File permissions, service account membership, secret-store review |  |
| Issuer service exposure is approved | systemd unit, environment file, network review, `SSHFLING_ALLOW_REMOTE` exception if used |  |
| SSHFling logs are centralized and retained | SIEM query, retention policy, sample `sshfling` and `sshfling-session` log records |  |
| Time synchronization is platform-managed | NTP/chrony or enterprise time-service evidence |  |
| OS-specific CIS Benchmark or equivalent scan completed | Customer scan report, profile name, deviations, remediation owners |  |

## Signing And Key Management Evidence

Control references: SOC 2 CC6.1, CC6.6, CC8.1; ISO 27001 A.8.24, A.8.32; NIST SP 800-53 Rev. 5 IA-5, SC-12, CM-3

APT/RPM repository signing:

- Production signing key fingerprint:
- Key owner role:
- Key storage location:
- Key created:
- Key expires:
- Last key access review:
- Signing workflow run:
- Evidence that `SSHFLING_GENERATE_REPO_SIGNING_KEY` was not used for production:

macOS signing and notarization:

- Developer ID certificate subject:
- Certificate fingerprint:
- Certificate expiration:
- Notarization submission ID:
- Stapling or notarization verification output:

Windows signing:

- Authenticode certificate subject:
- Certificate fingerprint:
- Certificate expiration:
- `signtool verify` or equivalent output:

Exception handling:

- Any unsigned artifact must have an exception owner, reason, compensating control, customer impact statement, expiration date, and re-test date.

## Secrets Handling Evidence

Control references: SOC 2 CC6.1, CC6.2, CC6.3; ISO 27001 A.5.15, A.5.18, A.8.2; NIST SP 800-53 Rev. 5 AC-6, IA-5, PM-12

| Secret or credential | Purpose | Storage location | Access scope | Last reviewed | Rotation trigger |
| --- | --- | --- | --- | --- | --- |
| `GITHUB_TOKEN` | Release and Pages publishing | GitHub Actions runtime | Workflow scoped |  | Per GitHub runtime |
| `SSHFLING_REPO_GPG_PRIVATE_KEY` | APT/RPM signing | GitHub secret or managed store | Protected release environment |  | Key rotation or exposure |
| `SSHFLING_REPO_GPG_FINGERPRINT` | APT/RPM trust anchor | GitHub secret or release record | Protected release environment |  | Key rotation, mismatch, or compromised trust anchor |
| `SSHFLING_REPO_GPG_PASSPHRASE` | GPG signing passphrase | GitHub secret or managed store | Protected release environment |  | Key rotation or exposure |
| Apple signing credentials | macOS package signing/notarization | Managed secret store | Protected release environment |  | Certificate rotation or exposure |
| Windows signing certificate | MSI signing | Managed secret store | Protected release environment |  | Certificate rotation or exposure |

Required checks:

- No production secrets committed to the repo.
- Workflow logs reviewed for accidental secret disclosure.
- Access to protected release secrets reviewed before first enterprise release and quarterly afterward.
- Departed maintainers removed from repository, environment, and secret-store access.

## Validation Evidence

Control references: SOC 2 CC7.1, CC8.1; ISO 27001 A.8.8, A.8.25, A.8.29; NIST SP 800-53 Rev. 5 SI-2, SA-10, CM-6

| Validation | Evidence source | Expected result | Actual result |
| --- | --- | --- | --- |
| Local source validation | `make test` | Pass |  |
| Release security evidence | `make release-security-scan`; optional external scanners via `make release-security-scan-optional`; strict runner via `make release-security-scan-strict` | Baseline pass and generated `security-scan-matrix.csv` validates with `security-scan-manifest.json` |  |
| SBOM generation | `security-scans/sbom.spdx.json` | SPDX 2.3 SBOM generated from tracked release source dependency inputs |  |
| Dependency inventory | `security-scans/dependency-inventory.json` | Container base images, apt packages, package runtime requirements, and Nix package references inventoried |  |
| License scan | `security-scans/license-report.json` | Commercial license markers present in source and package metadata generators |  |
| Package site verification | `packaging/verify-public-web.sh` | Pass and no `trusted=yes`, `gpgcheck=0`, or `repo_gpgcheck=0` |  |
| Container image tests | `Container image tests` workflow | Pass |  |
| Package install tests | `Package install tests` workflow | Pass |  |
| Cross-OS validation | `Cross OS validation` workflow | Pass or approved exception per failed target |  |
| Runtime behavior docs | README, docs/wiki, docs/repos.md, release notes | Password default, explicit certificate mode, access-level classification, prune limits, and uninstall limits match implementation |  |
| Compliance mapping | [compliance-mapping.md](compliance-mapping.md) and this packet | Control scope, evidence owners, caveats, and exceptions recorded without certification claims |  |
| Threat-model review | [threat-model.md](threat-model.md) and release ticket | Assumptions, abuse paths, residual risks, and mitigations accepted or excepted for this release |  |
| OpenSSH dependency policy review | [openssh-dependencies.md](openssh-dependencies.md), package metadata, fleet policy | OpenSSH/Python dependency ownership, uninstall scope, and original-state evidence are recorded without rollback overclaims |  |
| Access-level policy validation | `sshfling policy show`, cross-OS validation, grant metadata, host-control evidence | Access levels classify privilege intent, root-equivalent paths require admin classification, and actual privileges are enforced by host controls |  |
| CIS-style package hardening | `packaging/verify-public-web.sh`, package manager config, signatures, checksums | No `trusted=yes`, `gpgcheck=0`, or `repo_gpgcheck=0`; stable production signing key or approved exception |  |
| Customer host hardening | Customer OS benchmark or equivalent scan | Scan result and deviations attached, or customer-owned exception recorded |  |
| Secret scanning | `security-scans/secret-scan-report.json` and selected optional scanner, if used | No unresolved high-confidence secret findings |  |
| SAST | Selected scanner | No unresolved critical/high findings |  |
| Shell linting | Selected lint command | No unresolved release-blocking findings |  |
| Dockerfile linting | Selected lint command | No unresolved release-blocking findings |  |
| Vulnerability scanning | Selected scanner | No unresolved critical/high package findings |  |
| systemd unit security review | Selected review command | Findings accepted or remediated |  |

## Rollback Evidence

Control references: SOC 2 CC7.4, CC7.5; ISO 27001 A.5.30, A.8.13; NIST SP 800-53 Rev. 5 CP-10, IR-4

Rollback owner role:

Rollback approver role:

Previous Pages deployment URL:

Previous package-site artifact or release source:

Previous GitHub release URL:

Previous artifact checksums retained:

Rollback trigger criteria:

- Critical package install failure.
- Published artifact checksum mismatch.
- Signing-key compromise or suspected compromise.
- High-severity security regression.
- Incorrect version or package metadata published.

Rollback steps:

1. Open or update the incident/change ticket with rollback reason and approver.
2. Stop further publishing runs for the affected version.
3. Redeploy a known-good package-site artifact or regenerate the package site from the previous known-good release artifacts.
4. Verify checksums and signing metadata for the restored version.
5. Re-run targeted install validation for affected ecosystems.
6. Communicate customer impact, affected versions, mitigation, and fixed version.
7. Record final Pages deployment URL, package-site artifact reference, and validation run IDs.

Post-rollback evidence:

- Approval record:
- Restored version:
- Restored Pages deployment URL:
- Restored package-site artifact or release source:
- Validation run IDs:
- Customer communication link:
- Root-cause ticket:

## Audit Trail

Control references: SOC 2 CC7.2, CC7.3, CC8.1; ISO 27001 A.8.15, A.8.16, A.8.32; NIST SP 800-53 Rev. 5 AU-2, AU-6, AU-12, CM-3

Attach or link:

- Release ticket and approval comments.
- Pull request review history.
- Tag creation event and actor.
- GitHub Actions run URLs and retained logs.
- GitHub release URL and asset list.
- Pages deployment URL, deployment ID, and package-site artifact reference.
- Checksums and signing verification output.
- Completed compliance mapping status, including scope decisions and
  non-certification caveat.
- Threat-model review outcome and accepted residual risks.
- OpenSSH dependency/original-state review outcome and any customer-owned
  dependency cleanup decisions.
- Generated security evidence: `security-scan-report.json`, `security-scan-report.md`, `security-scan-matrix.csv`, `security-scan-manifest.json`, `sbom.spdx.json`, `dependency-inventory.json`, `license-report.json`, and optional scanner outputs.
- GitHub organization audit-log entries for tag creation, environment approval, release publication, secret changes, and Pages publication.
- Exception approvals and closure evidence.

## Enterprise Customer Acceptance

Provide this summary to enterprise customers when requested.

| Question | Evidence to provide |
| --- | --- |
| How do we know the package came from the intended source? | Source tag, commit SHA, release workflow run, artifact checksum. |
| How do we verify Linux repository integrity? | APT/RPM public signing key fingerprint, signed metadata, checksum files. |
| Are macOS and Windows packages signed? | Certificate metadata and verification output, or a documented exception. |
| What tests ran before publication? | Package install and cross-OS validation run URLs. |
| Who approved the release? | Change ticket approver and protected environment approval. |
| How are signing keys protected? | Key inventory, access review, and secret-store scope. |
| What privileged-access risks remain? | Threat-model review, access-level policy evidence, host-control evidence, and accepted residual risks. |
| Who owns OpenSSH and runtime dependency versions? | OpenSSH dependency policy, package metadata, fleet package policy, and original-state evidence if full revert is promised. |
| Does this evidence prove SOC 2, ISO 27001, NIST, or CIS certification? | No. Provide the non-certification caveat and the accepted audit or customer scope. |
| How does this align to CIS-style hardening? | Package-manager trust evidence, host hardening profile, log retention evidence, scan results, and customer-owned exceptions. |
| What happens if a bad package ships? | Rollback owner, previous known-good version, and rollback validation evidence. |
| What residual risks remain? | Open exceptions, expiration dates, and compensating controls. |

## Exception Record

Use one record per skipped or failed gate.

Control reference:

Release version:

Exception owner:

Approver:

Reason:

Affected artifacts or platforms:

Risk:

Compensating control:

Expiration date:

Re-test plan:

Closure evidence:
