TERMUX_PKG_HOMEPAGE=https://grwlx.github.io/sshfling
TERMUX_PKG_DESCRIPTION="Temporary SSH access broker and CLI"
TERMUX_PKG_LICENSE="LicenseRef-SSHFling-Commercial"
TERMUX_PKG_MAINTAINER="GRWLX <44076838+GRWLX@users.noreply.github.com>"
TERMUX_PKG_VERSION=0.1.16
TERMUX_PKG_SRCURL=https://grwlx.github.io/sshfling/downloads/sshfling-0.1.16.tar.gz
TERMUX_PKG_SHA256=78feb8fcc0344c9da3dfd1ef5305e9637dbd359749df1fcd6c51ed7ee961d4c4
TERMUX_PKG_DEPENDS="python, openssh, jq, procps, util-linux"
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	install -Dm755 bin/sshfling "$TERMUX_PREFIX/bin/sshfling"
	install -Dm755 production/sshfling-login-shell "$TERMUX_PREFIX/share/sshfling/templates/production/sshfling-login-shell"
	install -Dm755 production/sshfling-session "$TERMUX_PREFIX/share/sshfling/templates/production/sshfling-session"
	install -Dm644 LICENSE "$TERMUX_PREFIX/share/doc/sshfling/LICENSE"
	install -Dm644 README.md "$TERMUX_PREFIX/share/doc/sshfling/README.md"
	install -Dm644 packaging/policy.json "$TERMUX_PREFIX/etc/sshfling/policy.json"
	mkdir -p "$TERMUX_PREFIX/share/sshfling/templates"
	cp -a .env.example LICENSE README.md compose.server.yml compose.client.yml native scripts secrets ssh-client ssh-server production systemd "$TERMUX_PREFIX/share/sshfling/templates/"
}
