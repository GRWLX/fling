COMMENT =	temporary SSH access broker and CLI
DISTNAME =	sshfling-0.1.16
CATEGORIES =	security sysutils

HOMEPAGE =	https://grwlx.github.io/sshfling
MAINTAINER =	GRWLX <44076838+GRWLX@users.noreply.github.com>

# SSHFling Commercial License: redistribution requires prior written permission.
PERMIT_PACKAGE =	requires prior written permission from GRWLX
PERMIT_DISTFILES =	requires prior written permission from GRWLX

MASTER_SITES =	https://grwlx.github.io/sshfling/downloads/

MODULES =	lang/python
MODPY_ADJ_FILES = bin/sshfling
RUN_DEPENDS =	shells/bash textproc/jq sysutils/flock
NO_BUILD =	Yes

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/bin/sshfling ${PREFIX}/bin/sshfling
	${INSTALL_DATA_DIR} ${PREFIX}/libexec/sshfling
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-unix-identity ${PREFIX}/libexec/sshfling/sshfling-unix-identity
	${INSTALL_DATA_DIR} ${PREFIX}/share/doc/sshfling
	${INSTALL_DATA} ${WRKSRC}/README.md ${WRKSRC}/LICENSE ${PREFIX}/share/doc/sshfling/
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/sshfling
	${INSTALL_DATA} ${WRKSRC}/packaging/policy.json ${PREFIX}/share/examples/sshfling/policy.json
	${INSTALL_DATA_DIR} ${PREFIX}/share/sshfling/templates/scripts
	${INSTALL_DATA_DIR} ${PREFIX}/share/sshfling/templates/native
	${INSTALL_DATA_DIR} ${PREFIX}/share/sshfling/templates/secrets
	${INSTALL_DATA_DIR} ${PREFIX}/share/sshfling/templates/ssh-client
	${INSTALL_DATA_DIR} ${PREFIX}/share/sshfling/templates/ssh-server
	${INSTALL_DATA_DIR} ${PREFIX}/share/sshfling/templates/production
	${INSTALL_DATA_DIR} ${PREFIX}/share/sshfling/templates/systemd
	${INSTALL_DATA} ${WRKSRC}/.env.example ${PREFIX}/share/sshfling/templates/.env.example
	${INSTALL_DATA} ${WRKSRC}/LICENSE ${PREFIX}/share/sshfling/templates/LICENSE
	${INSTALL_DATA} ${WRKSRC}/README.md ${PREFIX}/share/sshfling/templates/README.md
	${INSTALL_DATA} ${WRKSRC}/compose.server.yml ${PREFIX}/share/sshfling/templates/compose.server.yml
	${INSTALL_DATA} ${WRKSRC}/compose.client.yml ${PREFIX}/share/sshfling/templates/compose.client.yml
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/install-local.sh ${PREFIX}/share/sshfling/templates/scripts/install-local.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/uninstall-local.sh ${PREFIX}/share/sshfling/templates/scripts/uninstall-local.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/create-network.sh ${PREFIX}/share/sshfling/templates/scripts/create-network.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/generate-ssh-key.sh ${PREFIX}/share/sshfling/templates/scripts/generate-ssh-key.sh
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-linux-account ${PREFIX}/share/sshfling/templates/native/sshfling-linux-account
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-unix-identity ${PREFIX}/share/sshfling/templates/native/sshfling-unix-identity
	${INSTALL_DATA} ${WRKSRC}/secrets/.gitkeep ${PREFIX}/share/sshfling/templates/secrets/.gitkeep
	${INSTALL_DATA} ${WRKSRC}/ssh-client/Dockerfile ${PREFIX}/share/sshfling/templates/ssh-client/Dockerfile
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-client/entrypoint.sh ${PREFIX}/share/sshfling/templates/ssh-client/entrypoint.sh
	${INSTALL_DATA} ${WRKSRC}/ssh-server/Dockerfile ${PREFIX}/share/sshfling/templates/ssh-server/Dockerfile
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-server/entrypoint.sh ${PREFIX}/share/sshfling/templates/ssh-server/entrypoint.sh
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-server/limited-session.sh ${PREFIX}/share/sshfling/templates/ssh-server/limited-session.sh
	${INSTALL_DATA} ${WRKSRC}/ssh-server/sshd_config ${PREFIX}/share/sshfling/templates/ssh-server/sshd_config
	${INSTALL_SCRIPT} ${WRKSRC}/production/sshfling-login-shell ${PREFIX}/share/sshfling/templates/production/sshfling-login-shell
	${INSTALL_SCRIPT} ${WRKSRC}/production/sshfling-session ${PREFIX}/share/sshfling/templates/production/sshfling-session
	${INSTALL_DATA} ${WRKSRC}/systemd/sshflingd.service ${PREFIX}/share/sshfling/templates/systemd/sshflingd.service
	${INSTALL_DATA} ${WRKSRC}/systemd/sshfling-prune.service ${PREFIX}/share/sshfling/templates/systemd/sshfling-prune.service
	${INSTALL_DATA} ${WRKSRC}/systemd/sshfling-prune.timer ${PREFIX}/share/sshfling/templates/systemd/sshfling-prune.timer
	${INSTALL_DATA} ${WRKSRC}/systemd/sshflingd.env.example ${PREFIX}/share/sshfling/templates/systemd/sshflingd.env.example

.include <bsd.port.mk>
