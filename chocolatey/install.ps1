$ErrorActionPreference = "Stop"
$tmp = Join-Path $env:TEMP "sshfling-chocolatey"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$pkg = Join-Path $tmp "sshfling.0.1.11.nupkg"
Invoke-WebRequest -Uri "https://grwlx.github.io/sshfling/chocolatey/sshfling.0.1.11.nupkg" -OutFile $pkg
choco install sshfling --source $tmp -y
