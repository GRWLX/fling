# $NetBSD$

DISTNAME=	sshfling-0.1.11
CATEGORIES=	security sysutils
MASTER_SITES=	https://grwlx.github.io/sshfling/downloads/

MAINTAINER=	44076838+GRWLX@users.noreply.github.com
HOMEPAGE=	https://grwlx.github.io/sshfling
COMMENT=	Temporary SSH certificate issuer and access CLI
LICENSE=	sshfling-commercial-license

USE_LANGUAGES=	# none
NO_BUILD=	yes
REPLACE_PYTHON=	bin/sshfling
INSTALLATION_DIRS=	bin libexec share/doc/sshfling etc/sshfling share/sshfling/templates share/sshfling/templates/scripts share/sshfling/templates/secrets share/sshfling/templates/ssh-client share/sshfling/templates/ssh-server share/sshfling/templates/production share/sshfling/templates/systemd

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/bin/sshfling ${DESTDIR}${PREFIX}/bin/sshfling
	${INSTALL_SCRIPT} ${WRKSRC}/production/sshfling-session ${DESTDIR}${PREFIX}/libexec/sshfling-session
	${INSTALL_DATA} ${WRKSRC}/README.md ${DESTDIR}${PREFIX}/share/doc/sshfling/README.md
	${INSTALL_DATA} ${WRKSRC}/LICENSE ${DESTDIR}${PREFIX}/share/doc/sshfling/LICENSE
	${INSTALL_DATA} ${WRKSRC}/packaging/policy.json ${DESTDIR}${PREFIX}/etc/sshfling/policy.json
	${INSTALL_DATA} ${WRKSRC}/.env.example ${DESTDIR}${PREFIX}/share/sshfling/templates/.env.example
	${INSTALL_DATA} ${WRKSRC}/LICENSE ${DESTDIR}${PREFIX}/share/sshfling/templates/LICENSE
	${INSTALL_DATA} ${WRKSRC}/README.md ${DESTDIR}${PREFIX}/share/sshfling/templates/README.md
	${INSTALL_DATA} ${WRKSRC}/compose.server.yml ${DESTDIR}${PREFIX}/share/sshfling/templates/compose.server.yml
	${INSTALL_DATA} ${WRKSRC}/compose.client.yml ${DESTDIR}${PREFIX}/share/sshfling/templates/compose.client.yml
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/install-local.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/scripts/install-local.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/uninstall-local.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/scripts/uninstall-local.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/create-network.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/scripts/create-network.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/generate-ssh-key.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/scripts/generate-ssh-key.sh
	${INSTALL_DATA} ${WRKSRC}/secrets/.gitkeep ${DESTDIR}${PREFIX}/share/sshfling/templates/secrets/.gitkeep
	${INSTALL_DATA} ${WRKSRC}/ssh-client/Dockerfile ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-client/Dockerfile
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-client/entrypoint.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-client/entrypoint.sh
	${INSTALL_DATA} ${WRKSRC}/ssh-server/Dockerfile ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-server/Dockerfile
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-server/entrypoint.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-server/entrypoint.sh
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-server/limited-session.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-server/limited-session.sh
	${INSTALL_DATA} ${WRKSRC}/ssh-server/sshd_config ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-server/sshd_config
	${INSTALL_SCRIPT} ${WRKSRC}/production/sshfling-session ${DESTDIR}${PREFIX}/share/sshfling/templates/production/sshfling-session
	${INSTALL_DATA} ${WRKSRC}/systemd/sshflingd.service ${DESTDIR}${PREFIX}/share/sshfling/templates/systemd/sshflingd.service
	${INSTALL_DATA} ${WRKSRC}/systemd/sshflingd.env.example ${DESTDIR}${PREFIX}/share/sshfling/templates/systemd/sshflingd.env.example

.include "../../lang/python/application.mk"
.include "../../mk/bsd.pkg.mk"
