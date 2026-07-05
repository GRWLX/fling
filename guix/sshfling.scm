(define-module (sshfling)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ssh))

(define-public sshfling
  (package
    (name "sshfling")
    (version "0.1.11")
    (source
     (origin
       (method url-fetch)
       (uri "https://grwlx.github.io/sshfling/downloads/sshfling-0.1.11.tar.gz")
       (sha256 (base32 "0cjdnx5ckwsrfz49zqlj5b77c29534azqblvczj6in7mdrplxkpq"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("bin/sshfling" "bin/sshfling")
         ("README.md" "share/doc/sshfling/README.md")
         ("LICENSE" "share/doc/sshfling/LICENSE")
         ("packaging/policy.json" "etc/sshfling/policy.json")
         (".env.example" "share/sshfling/templates/.env.example")
         ("LICENSE" "share/sshfling/templates/LICENSE")
         ("README.md" "share/sshfling/templates/README.md")
         ("compose.server.yml" "share/sshfling/templates/compose.server.yml")
         ("compose.client.yml" "share/sshfling/templates/compose.client.yml")
         ("scripts" "share/sshfling/templates/scripts")
         ("secrets" "share/sshfling/templates/secrets")
         ("ssh-client" "share/sshfling/templates/ssh-client")
         ("ssh-server" "share/sshfling/templates/ssh-server")
         ("production" "share/sshfling/templates/production")
         ("systemd" "share/sshfling/templates/systemd"))))
    (inputs (list python openssh shadow procps util-linux))
    (home-page "https://grwlx.github.io/sshfling")
    (synopsis "Temporary SSH certificate issuer and access CLI")
    (description
     "SSHFling issues short-lived OpenSSH user certificates and installs a forced session wrapper so temporary SSH sessions are capped by a server-side wall-clock timeout.")
    (license #f)))
