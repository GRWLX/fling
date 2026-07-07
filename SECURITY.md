# Security Policy

## Supported Versions

Security fixes are published for the latest tagged minor release line. Older
release lines are unsupported unless a written enterprise support agreement says
otherwise.

| Version | Supported |
| --- | --- |
| 0.1.x | Yes |
| < 0.1 | No |

## Reporting a Vulnerability

Report suspected vulnerabilities privately by opening a GitHub private
vulnerability report for this repository, or by contacting the repository owner
through the enterprise support channel listed in the customer agreement. Do not
open a public issue for vulnerabilities that could expose keys, credentials,
temporary access controls, package signing, install scripts, CI secrets, or
release infrastructure.

Include the affected version or commit, operating system, install channel,
steps to reproduce, impact, and any logs or proof of concept that can be shared
safely. Do not include live secrets, production private keys, real customer
credentials, or sensitive host data.

## Response Targets

- Acknowledgement target: 2 business days after receipt through a monitored
  private channel.
- Initial triage target: 5 business days after acknowledgement.
- Remediation target: based on severity, exploitability, supported-version
  impact, and available mitigations.

These are operational targets, not a legal or service-level guarantee unless a
separate agreement says so.

## Disclosure And Advisories

The maintainers coordinate disclosure with reporters when a supported release is
affected. Fixes may be published as GitHub security advisories, release notes,
patched tags, package updates, documented mitigations, or customer notices.
Public disclosure should wait until a fix or mitigation is available, unless
active exploitation or user safety requires a different response.

## Security Scope

Reports are in scope when they affect SSHFling source, package builders,
install/uninstall behavior, release artifacts, package repository metadata,
temporary access lifecycle, OpenSSH integration, generated credentials,
certificate issuance, issuer/web surfaces, CI workflows, or release evidence.

Host hardening, customer IAM, PAM, sudoers, MDM, SIEM, fleet package policy,
external signing-key custody, and GitHub repository settings remain
operator-owned controls unless explicitly covered by a support agreement.
