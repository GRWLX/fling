(define-module (sshfling)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages web))

(define-public sshfling
  (package
    (name "sshfling")
    (version "0.1.16")
    (source
     (origin
       (method url-fetch)
       (uri "https://grwlx.github.io/sshfling/downloads/sshfling-0.1.16.tar.gz")
       (sha256 (base32 "1i6lc7lpxvaidk6izps9jwsvszb3x42m7vyivyirsk1lq3ybizkq"))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("bin/sshfling" "bin/sshfling")
         ("native/sshfling-linux-account" "libexec/sshfling/sshfling-linux-account")
         ("native/sshfling-unix-identity" "libexec/sshfling/sshfling-unix-identity")
         ("native" "share/sshfling/templates/native")
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
         ("systemd" "share/sshfling/templates/systemd"))
       #:modules ((guix build copy-build-system)
                  (guix build utils)
                  (srfi srfi-13))
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'wire-runtime-paths
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (templates (string-append out "/share/sshfling/templates"))
                    (bash (search-input-file inputs "/bin/bash"))
                    (native-programs
                     '("/bin/bash"
                       "/bin/id"
                       "/bin/awk"
                       "/bin/sed"
                       "/sbin/useradd"
                       "/bin/ps"
                       "/bin/flock"
                       "/bin/jq"
                       "/bin/openssl"))
                    (native-path-directories
                     (map (lambda (program)
                            (dirname (search-input-file inputs program)))
                          native-programs))
                    (native-path (string-join native-path-directories ":"))
                    (runtime-path-directories
                     (append native-path-directories
                             (map (lambda (program)
                                    (dirname (search-input-file inputs program)))
                                  '("/bin/python3" "/bin/ssh" "/sbin/sshd"))))
                    (runtime-path (string-join runtime-path-directories ":"))
                    (linux-account
                     (string-append out
                                    "/libexec/sshfling/sshfling-linux-account"))
                    (unix-identity
                     (string-append out
                                    "/libexec/sshfling/sshfling-unix-identity"))
                    (cli (string-append out "/bin/sshfling"))
                    (session
                     (string-append templates "/production/sshfling-session"))
                    (secure-wrap-program
                     (lambda (program assignments)
                       (let ((real-program (string-append program ".real")))
                         (rename-file program real-program)
                         (call-with-output-file program
                           (lambda (port)
                             (display (string-append "#!" bash " -p\n") port)
                             (display "set -eu\n" port)
                             (display "unset BASH_ENV ENV CDPATH GLOBIGNORE 2>/dev/null || :\n"
                                      port)
                             (for-each (lambda (assignment)
                                         (display assignment port)
                                         (newline port))
                                       assignments)
                             (display (string-append "exec '" real-program
                                                     "' \"$@\"\n")
                                      port)))
                         (chmod program #o555)))))
               (substitute* (string-append templates "/native/sshfling-linux-account")
                 (("^#!.*$") "#!/bin/bash -p"))
               (substitute* (string-append templates "/native/sshfling-unix-identity")
                 (("^#!.*$") "#!/bin/sh"))
               (substitute* (string-append templates "/production/sshfling-login-shell")
                 (("^#!.*$") "#!/bin/sh"))
               (substitute* session
                 (("^#!.*$") (string-append "#!" bash))
                 (("^session_user_path=.*$")
                  (string-append "session_user_path=\"" native-path
                                 ":${PATH:-}\""))
                 (("^PATH=\"/usr/sbin:/usr/bin:/sbin:/bin:")
                  (string-append "PATH=\"" native-path
                                 ":/usr/sbin:/usr/bin:/sbin:/bin:")))
               (secure-wrap-program
                linux-account
                (list (string-append
                       "export SSHFLING_NATIVE_TOOL_PATH='" native-path "'")))
               (secure-wrap-program
                unix-identity
                (list (string-append
                       "export SSHFLING_NATIVE_TOOL_PATH='" native-path "'")))
               (secure-wrap-program
                cli
                (list (string-append "export PATH='" runtime-path
                                     "':\"${PATH:-}\"")
                      (string-append
                       "export SSHFLING_NATIVE_TOOL_PATH='" native-path "'")
                      (string-append
                       "export SSHFLING_LINUX_ACCOUNT_HELPER='" linux-account "'")
                      (string-append
                       "export SSHFLING_UNIX_IDENTITY_HELPER='" unix-identity
                       "'")))))))))
    (propagated-inputs
     (list bash-minimal coreutils gawk sed jq shadow procps util-linux openssl
           python openssh))
    (home-page "https://grwlx.github.io/sshfling")
    (synopsis "Temporary SSH access broker and CLI")
    (description
     "SSHFling grants short-lived SSH access with default password grants, optional OpenSSH user certificates, and a forced session wrapper so temporary SSH sessions are capped by a server-side wall-clock timeout.")
    (license #f)))

sshfling
