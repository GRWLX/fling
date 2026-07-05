Name:           sshfling
Version:        0.1.11
Release:        1%{?dist}
Summary:        Temporary SSH certificate issuer and access CLI
License:        LicenseRef-SSHFling-Commercial
URL:            https://grwlx.github.io/sshfling
Source0:        https://grwlx.github.io/sshfling/downloads/sshfling-0.1.11.tar.gz
BuildArch:      noarch
Requires:       python3
Requires:       openssh
Requires:       shadow
Requires:       procps
Requires:       util-linux

%description
SSHFling issues short-lived OpenSSH user certificates and installs a forced
session wrapper so temporary SSH sessions are capped by a server-side
wall-clock timeout.

%prep
%autosetup

%build

%install
install -Dm755 bin/sshfling %{buildroot}%{_bindir}/sshfling
install -Dm755 production/sshfling-session %{buildroot}%{_datadir}/sshfling/templates/production/sshfling-session
install -Dm644 packaging/policy.json %{buildroot}%{_sysconfdir}/sshfling/policy.json
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE
install -Dm644 README.md %{buildroot}%{_docdir}/%{name}/README.md
mkdir -p %{buildroot}%{_datadir}/sshfling/templates
cp -a .env.example LICENSE README.md compose.server.yml compose.client.yml scripts secrets ssh-client ssh-server production systemd %{buildroot}%{_datadir}/sshfling/templates/

%files
%{_bindir}/sshfling
%config(noreplace) %{_sysconfdir}/sshfling/policy.json
%{_datadir}/sshfling/templates
%license %{_licensedir}/%{name}/LICENSE
%doc %{_docdir}/%{name}/README.md

%changelog
* Sat Jul 04 2026 GRWLX <44076838+GRWLX@users.noreply.github.com> - 0.1.11-1
- Package sshfling for openSUSE Build Service
