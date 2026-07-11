Name:           sshfling
Version:        0.1.16
Release:        1%{?dist}
Summary:        Temporary SSH access broker and CLI
License:        LicenseRef-SSHFling-Commercial
URL:            https://grwlx.github.io/sshfling
Source0:        https://grwlx.github.io/sshfling/downloads/sshfling-0.1.16.tar.gz
BuildArch:      noarch
Requires:       python3
Requires:       bash
Requires:       openssh
Requires:       openssl
Requires:       shadow
Requires:       procps
Requires:       util-linux
Requires:       jq

%description
SSHFling grants short-lived SSH access with default password grants, optional
OpenSSH user certificates, and a forced session wrapper so temporary SSH
sessions are capped by a server-side wall-clock timeout.

%prep
%autosetup

%build

%install
install -Dm755 bin/sshfling %{buildroot}%{_bindir}/sshfling
install -Dm755 native/sshfling-linux-account %{buildroot}%{_libexecdir}/sshfling/sshfling-linux-account
install -Dm755 native/sshfling-unix-identity %{buildroot}%{_libexecdir}/sshfling/sshfling-unix-identity
install -Dm755 production/sshfling-login-shell %{buildroot}%{_datadir}/sshfling/templates/production/sshfling-login-shell
install -Dm755 production/sshfling-session %{buildroot}%{_datadir}/sshfling/templates/production/sshfling-session
install -Dm644 packaging/policy.json %{buildroot}%{_sysconfdir}/sshfling/policy.json
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE
install -Dm644 README.md %{buildroot}%{_docdir}/%{name}/README.md
mkdir -p %{buildroot}%{_datadir}/sshfling/templates
cp -a .env.example LICENSE README.md compose.server.yml compose.client.yml native scripts secrets ssh-client ssh-server production systemd %{buildroot}%{_datadir}/sshfling/templates/

%files
%{_bindir}/sshfling
%{_libexecdir}/sshfling/sshfling-linux-account
%{_libexecdir}/sshfling/sshfling-unix-identity
%config(missingok,noreplace) %{_sysconfdir}/sshfling/policy.json
%{_datadir}/sshfling/templates
%license %{_licensedir}/%{name}/LICENSE
%doc %{_docdir}/%{name}/README.md

%changelog
* Sat Jul 04 2026 GRWLX <44076838+GRWLX@users.noreply.github.com> - 0.1.16-1
- Package sshfling for openSUSE Build Service
