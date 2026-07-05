TERMUX_PKG_HOMEPAGE=https://grwlx.github.io/sshfling
TERMUX_PKG_DESCRIPTION="Temporary SSH certificate issuer and access CLI"
TERMUX_PKG_LICENSE="LicenseRef-SSHFling-Commercial"
TERMUX_PKG_MAINTAINER="GRWLX <44076838+GRWLX@users.noreply.github.com>"
TERMUX_PKG_VERSION=0.1.11
TERMUX_PKG_SRCURL=https://grwlx.github.io/sshfling/downloads/sshfling-0.1.11.tar.gz
TERMUX_PKG_SHA256=324db74ac9f35977c89fe2922ace7609251915fc2e9b67e468d8f56e6f4ecef8
TERMUX_PKG_DEPENDS="python, openssh, procps, util-linux"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	install -Dm755 bin/sshfling "$TERMUX_PREFIX/bin/sshfling"
	install -Dm755 production/sshfling-session "$TERMUX_PREFIX/share/sshfling/templates/production/sshfling-session"
	install -Dm644 LICENSE "$TERMUX_PREFIX/share/doc/sshfling/LICENSE"
	install -Dm644 README.md "$TERMUX_PREFIX/share/doc/sshfling/README.md"
	install -Dm644 packaging/policy.json "$TERMUX_PREFIX/etc/sshfling/policy.json"
	mkdir -p "$TERMUX_PREFIX/share/sshfling/templates"
	cp -a .env.example LICENSE README.md compose.server.yml compose.client.yml scripts secrets ssh-client ssh-server production systemd "$TERMUX_PREFIX/share/sshfling/templates/"
}
