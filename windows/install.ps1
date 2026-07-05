$ErrorActionPreference = "Stop"
$installer = Join-Path $env:TEMP "sshfling-0.1.11.msi"
Invoke-WebRequest -Uri "https://grwlx.github.io/sshfling/downloads/sshfling-0.1.11.msi" -OutFile $installer
Start-Process msiexec.exe -Wait -ArgumentList "/i", $installer, "/qn"
