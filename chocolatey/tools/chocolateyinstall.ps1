$ErrorActionPreference = 'Stop'

$packageArgs = @{
  packageName    = 'sshfling'
  fileType       = 'msi'
  url64bit       = 'https://grwlx.github.io/sshfling/downloads/sshfling-0.1.11.msi'
  checksum64     = '2d8d9d1da3d49826d80c1c99b9d12ac0dd4280ff0280ce6a6d8bd9f5c0bde03e'
  checksumType64 = 'sha256'
  silentArgs     = '/qn /norestart'
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
