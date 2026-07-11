# $NetBSD$

DISTNAME=	sshfling-0.1.16
CATEGORIES=	security sysutils
MASTER_SITES=	https://grwlx.github.io/sshfling/downloads/

MAINTAINER=	44076838+GRWLX@users.noreply.github.com
HOMEPAGE=	https://grwlx.github.io/sshfling
COMMENT=	Temporary SSH access broker and CLI
LICENSE=	sshfling-commercial-license

USE_LANGUAGES=	# none
NO_BUILD=	yes
DEPENDS+=	jq-[0-9]*:../../devel/jq
DEPENDS+=	bash-[0-9]*:../../shells/bash
REPLACE_PYTHON=	bin/sshfling
PKG_SYSCONFSUBDIR=	sshfling
EGDIR=		${PREFIX}/share/examples/sshfling
CONF_FILES=	${EGDIR}/policy.json ${PKG_SYSCONFDIR}/policy.json
SUBST_CLASSES+=	sshfling-paths
SUBST_STAGE.sshfling-paths=	pre-configure
SUBST_FILES.sshfling-paths=	bin/sshfling production/sshfling-session
SUBST_SED.sshfling-paths=	-e 's|/etc/sshfling/policy.json|${PKG_SYSCONFDIR}/policy.json|g'
INSTALLATION_DIRS=	bin libexec libexec/sshfling share/doc/sshfling share/examples/sshfling share/sshfling/templates share/sshfling/templates/native share/sshfling/templates/scripts share/sshfling/templates/secrets share/sshfling/templates/ssh-client share/sshfling/templates/ssh-server share/sshfling/templates/production share/sshfling/templates/systemd

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/bin/sshfling ${DESTDIR}${PREFIX}/bin/sshfling
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-unix-identity ${DESTDIR}${PREFIX}/libexec/sshfling/sshfling-unix-identity
	${INSTALL_DATA} ${WRKSRC}/README.md ${DESTDIR}${PREFIX}/share/doc/sshfling/README.md
	${INSTALL_DATA} ${WRKSRC}/LICENSE ${DESTDIR}${PREFIX}/share/doc/sshfling/LICENSE
	${INSTALL_DATA} ${WRKSRC}/packaging/policy.json ${DESTDIR}${EGDIR}/policy.json
	${INSTALL_DATA} ${WRKSRC}/.env.example ${DESTDIR}${PREFIX}/share/sshfling/templates/.env.example
	${INSTALL_DATA} ${WRKSRC}/LICENSE ${DESTDIR}${PREFIX}/share/sshfling/templates/LICENSE
	${INSTALL_DATA} ${WRKSRC}/README.md ${DESTDIR}${PREFIX}/share/sshfling/templates/README.md
	${INSTALL_DATA} ${WRKSRC}/compose.server.yml ${DESTDIR}${PREFIX}/share/sshfling/templates/compose.server.yml
	${INSTALL_DATA} ${WRKSRC}/compose.client.yml ${DESTDIR}${PREFIX}/share/sshfling/templates/compose.client.yml
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/install-local.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/scripts/install-local.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/uninstall-local.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/scripts/uninstall-local.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/create-network.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/scripts/create-network.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/generate-ssh-key.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/scripts/generate-ssh-key.sh
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-linux-account ${DESTDIR}${PREFIX}/share/sshfling/templates/native/sshfling-linux-account
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-unix-identity ${DESTDIR}${PREFIX}/share/sshfling/templates/native/sshfling-unix-identity
	${INSTALL_DATA} ${WRKSRC}/secrets/.gitkeep ${DESTDIR}${PREFIX}/share/sshfling/templates/secrets/.gitkeep
	${INSTALL_DATA} ${WRKSRC}/ssh-client/Dockerfile ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-client/Dockerfile
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-client/entrypoint.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-client/entrypoint.sh
	${INSTALL_DATA} ${WRKSRC}/ssh-server/Dockerfile ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-server/Dockerfile
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-server/entrypoint.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-server/entrypoint.sh
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-server/limited-session.sh ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-server/limited-session.sh
	${INSTALL_DATA} ${WRKSRC}/ssh-server/sshd_config ${DESTDIR}${PREFIX}/share/sshfling/templates/ssh-server/sshd_config
	${INSTALL_SCRIPT} ${WRKSRC}/production/sshfling-login-shell ${DESTDIR}${PREFIX}/share/sshfling/templates/production/sshfling-login-shell
	${INSTALL_SCRIPT} ${WRKSRC}/production/sshfling-session ${DESTDIR}${PREFIX}/share/sshfling/templates/production/sshfling-session
	${INSTALL_DATA} ${WRKSRC}/systemd/sshflingd.service ${DESTDIR}${PREFIX}/share/sshfling/templates/systemd/sshflingd.service
	${INSTALL_DATA} ${WRKSRC}/systemd/sshfling-prune.service ${DESTDIR}${PREFIX}/share/sshfling/templates/systemd/sshfling-prune.service
	${INSTALL_DATA} ${WRKSRC}/systemd/sshfling-prune.timer ${DESTDIR}${PREFIX}/share/sshfling/templates/systemd/sshfling-prune.timer
	${INSTALL_DATA} ${WRKSRC}/systemd/sshflingd.env.example ${DESTDIR}${PREFIX}/share/sshfling/templates/systemd/sshflingd.env.example

.include "../../lang/python/application.mk"
.include "../../mk/bsd.pkg.mk"
