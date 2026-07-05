class Sshfling < Formula
  desc "Temporary SSH certificate issuer and access CLI"
  homepage "https://grwlx.github.io/sshfling"
  url "https://grwlx.github.io/sshfling/downloads/sshfling-0.1.11.tar.gz"
  sha256 "324db74ac9f35977c89fe2922ace7609251915fc2e9b67e468d8f56e6f4ecef8"
  license :cannot_represent

  depends_on "python@3"

  def install
    bin.install "bin/sshfling"
    (pkgshare/"templates").install ".env.example", "LICENSE", "README.md", "compose.server.yml", "compose.client.yml"
    (pkgshare/"templates").install "scripts", "secrets", "ssh-client", "ssh-server", "production", "systemd"
  end

  test do
    system "#{bin}/sshfling", "--version"
  end
end
