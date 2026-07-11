EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

inherit python-r1 systemd

DESCRIPTION="Temporary SSH access broker and CLI"
HOMEPAGE="https://grwlx.github.io/sshfling"
SRC_URI="https://grwlx.github.io/sshfling/downloads/sshfling-0.1.16.tar.gz"

LICENSE="LicenseRef-SSHFling-Commercial"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
	app-misc/jq
	app-shells/bash
	dev-libs/openssl
	virtual/ssh
	sys-apps/shadow
	sys-process/procps
	sys-apps/util-linux"

src_install() {
	python_fix_shebang bin/sshfling
	dobin bin/sshfling
	exeinto /usr/libexec/sshfling
	doexe native/sshfling-linux-account
	doexe native/sshfling-unix-identity
	exeinto /usr/share/sshfling/templates/production
	doexe production/sshfling-login-shell production/sshfling-session
	insinto /etc/sshfling
	doins packaging/policy.json
	systemd_dounit systemd/sshflingd.service systemd/sshfling-prune.service systemd/sshfling-prune.timer
	dodoc README.md
	newdoc LICENSE LICENSE
	insinto /usr/share/sshfling/templates
	doins .env.example LICENSE README.md compose.server.yml compose.client.yml
	doins -r native scripts secrets ssh-client ssh-server production systemd
	fperms 0755 		/usr/share/sshfling/templates/native/sshfling-linux-account 		/usr/share/sshfling/templates/native/sshfling-unix-identity 		/usr/share/sshfling/templates/scripts/install-local.sh 		/usr/share/sshfling/templates/scripts/uninstall-local.sh 		/usr/share/sshfling/templates/scripts/create-network.sh 		/usr/share/sshfling/templates/scripts/generate-ssh-key.sh 		/usr/share/sshfling/templates/ssh-client/entrypoint.sh 		/usr/share/sshfling/templates/ssh-server/entrypoint.sh 		/usr/share/sshfling/templates/ssh-server/limited-session.sh 		/usr/share/sshfling/templates/production/sshfling-login-shell 		/usr/share/sshfling/templates/production/sshfling-session
}
