$ErrorActionPreference = 'Stop'

$desktop = [System.Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path -Path $desktop -ChildPath 'Tor Browser.lnk'

if (Test-Path -Path $shortcutPath) {
  Write-Host "Removing Desktop shortcut..."
  Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue
}
