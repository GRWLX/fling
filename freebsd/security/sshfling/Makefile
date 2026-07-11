PORTNAME=	sshfling
DISTVERSION=	0.1.16
CATEGORIES=	security sysutils
MASTER_SITES=	https://grwlx.github.io/sshfling/downloads/

MAINTAINER=	44076838+GRWLX@users.noreply.github.com
COMMENT=	Temporary SSH access broker and CLI
WWW=		https://grwlx.github.io/sshfling

LICENSE=	SSHFLING_COMMERCIAL
LICENSE_NAME=	SSHFling Commercial License
LICENSE_FILE=	${WRKSRC}/LICENSE
LICENSE_PERMS=	no-dist-mirror no-dist-sell no-pkg-mirror no-pkg-sell no-auto-accept

RUN_DEPENDS=	python3:lang/python3 bash:shells/bash jq:textproc/jq

USES=		python shebangfix
SHEBANG_FILES=	bin/sshfling
NO_BUILD=	yes

post-patch:
	${REINPLACE_CMD} -e 's|/etc/sshfling/policy.json|${PREFIX}/etc/sshfling/policy.json|g' 		${WRKSRC}/bin/sshfling ${WRKSRC}/production/sshfling-session

do-install:
	${INSTALL_SCRIPT} ${WRKSRC}/bin/sshfling ${STAGEDIR}${PREFIX}/bin/sshfling
	${MKDIR} ${STAGEDIR}${PREFIX}/libexec/sshfling
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-unix-identity ${STAGEDIR}${PREFIX}/libexec/sshfling/sshfling-unix-identity
	${MKDIR} ${STAGEDIR}${PREFIX}/etc/sshfling
	${INSTALL_DATA} ${WRKSRC}/packaging/policy.json ${STAGEDIR}${PREFIX}/etc/sshfling/policy.json.sample
	${MKDIR} ${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${WRKSRC}/README.md ${WRKSRC}/LICENSE ${STAGEDIR}${DOCSDIR}/
	${MKDIR} ${STAGEDIR}${PREFIX}/share/sshfling/templates/scripts
	${MKDIR} ${STAGEDIR}${PREFIX}/share/sshfling/templates/native
	${MKDIR} ${STAGEDIR}${PREFIX}/share/sshfling/templates/secrets
	${MKDIR} ${STAGEDIR}${PREFIX}/share/sshfling/templates/ssh-client
	${MKDIR} ${STAGEDIR}${PREFIX}/share/sshfling/templates/ssh-server
	${MKDIR} ${STAGEDIR}${PREFIX}/share/sshfling/templates/production
	${MKDIR} ${STAGEDIR}${PREFIX}/share/sshfling/templates/systemd
	${INSTALL_DATA} ${WRKSRC}/.env.example ${STAGEDIR}${PREFIX}/share/sshfling/templates/.env.example
	${INSTALL_DATA} ${WRKSRC}/LICENSE ${STAGEDIR}${PREFIX}/share/sshfling/templates/LICENSE
	${INSTALL_DATA} ${WRKSRC}/README.md ${STAGEDIR}${PREFIX}/share/sshfling/templates/README.md
	${INSTALL_DATA} ${WRKSRC}/compose.server.yml ${STAGEDIR}${PREFIX}/share/sshfling/templates/compose.server.yml
	${INSTALL_DATA} ${WRKSRC}/compose.client.yml ${STAGEDIR}${PREFIX}/share/sshfling/templates/compose.client.yml
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/install-local.sh ${STAGEDIR}${PREFIX}/share/sshfling/templates/scripts/install-local.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/uninstall-local.sh ${STAGEDIR}${PREFIX}/share/sshfling/templates/scripts/uninstall-local.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/create-network.sh ${STAGEDIR}${PREFIX}/share/sshfling/templates/scripts/create-network.sh
	${INSTALL_SCRIPT} ${WRKSRC}/scripts/generate-ssh-key.sh ${STAGEDIR}${PREFIX}/share/sshfling/templates/scripts/generate-ssh-key.sh
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-linux-account ${STAGEDIR}${PREFIX}/share/sshfling/templates/native/sshfling-linux-account
	${INSTALL_SCRIPT} ${WRKSRC}/native/sshfling-unix-identity ${STAGEDIR}${PREFIX}/share/sshfling/templates/native/sshfling-unix-identity
	${INSTALL_DATA} ${WRKSRC}/secrets/.gitkeep ${STAGEDIR}${PREFIX}/share/sshfling/templates/secrets/.gitkeep
	${INSTALL_DATA} ${WRKSRC}/ssh-client/Dockerfile ${STAGEDIR}${PREFIX}/share/sshfling/templates/ssh-client/Dockerfile
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-client/entrypoint.sh ${STAGEDIR}${PREFIX}/share/sshfling/templates/ssh-client/entrypoint.sh
	${INSTALL_DATA} ${WRKSRC}/ssh-server/Dockerfile ${STAGEDIR}${PREFIX}/share/sshfling/templates/ssh-server/Dockerfile
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-server/entrypoint.sh ${STAGEDIR}${PREFIX}/share/sshfling/templates/ssh-server/entrypoint.sh
	${INSTALL_SCRIPT} ${WRKSRC}/ssh-server/limited-session.sh ${STAGEDIR}${PREFIX}/share/sshfling/templates/ssh-server/limited-session.sh
	${INSTALL_DATA} ${WRKSRC}/ssh-server/sshd_config ${STAGEDIR}${PREFIX}/share/sshfling/templates/ssh-server/sshd_config
	${INSTALL_SCRIPT} ${WRKSRC}/production/sshfling-login-shell ${STAGEDIR}${PREFIX}/share/sshfling/templates/production/sshfling-login-shell
	${INSTALL_SCRIPT} ${WRKSRC}/production/sshfling-session ${STAGEDIR}${PREFIX}/share/sshfling/templates/production/sshfling-session
	${INSTALL_DATA} ${WRKSRC}/systemd/sshflingd.service ${STAGEDIR}${PREFIX}/share/sshfling/templates/systemd/sshflingd.service
	${INSTALL_DATA} ${WRKSRC}/systemd/sshfling-prune.service ${STAGEDIR}${PREFIX}/share/sshfling/templates/systemd/sshfling-prune.service
	${INSTALL_DATA} ${WRKSRC}/systemd/sshfling-prune.timer ${STAGEDIR}${PREFIX}/share/sshfling/templates/systemd/sshfling-prune.timer
	${INSTALL_DATA} ${WRKSRC}/systemd/sshflingd.env.example ${STAGEDIR}${PREFIX}/share/sshfling/templates/systemd/sshflingd.env.example

.include <bsd.port.mk>
