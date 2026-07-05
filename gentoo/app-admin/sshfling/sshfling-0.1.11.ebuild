EAPI=8

inherit python-r1 systemd

DESCRIPTION="Temporary SSH certificate issuer and access CLI"
HOMEPAGE="https://grwlx.github.io/sshfling"
SRC_URI="https://grwlx.github.io/sshfling/downloads/sshfling-0.1.11.tar.gz"

LICENSE="LicenseRef-SSHFling-Commercial"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
	virtual/ssh
	sys-apps/shadow
	sys-process/procps
	sys-apps/util-linux"

src_install() {
	python_fix_shebang bin/sshfling
	dobin bin/sshfling
	exeinto /usr/share/sshfling/templates/production
	doexe production/sshfling-session
	insinto /etc/sshfling
	doins packaging/policy.json
	systemd_dounit systemd/sshflingd.service
	dodoc README.md
	newdoc LICENSE LICENSE
	insinto /usr/share/sshfling/templates
	doins .env.example LICENSE README.md compose.server.yml compose.client.yml
	doins -r scripts secrets ssh-client ssh-server production systemd
}
