class Sshfling < Formula
  desc "Temporary SSH access broker and CLI"
  homepage "https://grwlx.github.io/sshfling"
  url "https://grwlx.github.io/sshfling/downloads/sshfling-0.1.16.tar.gz"
  sha256 "78feb8fcc0344c9da3dfd1ef5305e9637dbd359749df1fcd6c51ed7ee961d4c4"
  license :cannot_represent

  depends_on "python@3"
  depends_on "jq"
  depends_on "flock"

  def install
    bin.install "bin/sshfling"
    (libexec/"sshfling").install "native/sshfling-unix-identity"
    (pkgshare/"templates").install ".env.example", "LICENSE", "README.md", "compose.server.yml", "compose.client.yml"
    (pkgshare/"templates").install "native", "scripts", "secrets", "ssh-client", "ssh-server", "production", "systemd"
  end

  test do
    system "#{bin}/sshfling", "--version"
  end
end
