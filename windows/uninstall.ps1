$ErrorActionPreference = "Stop"

$uninstallRoots = @(
  "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$products = Get-ItemProperty -Path $uninstallRoots -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -eq "SSHFling" }

if (-not $products) {
  Write-Output "SSHFling is not installed."
  exit 0
}

foreach ($product in $products) {
  $productCode = $product.PSChildName
  if ($productCode -notmatch '^\{[0-9A-Fa-f-]{36}\}$') {
    throw "Could not determine MSI product code for SSHFling."
  }
  Start-Process msiexec.exe -Wait -ArgumentList "/x", $productCode, "/qn", "/norestart"
}

Write-Output "Removed SSHFling."
