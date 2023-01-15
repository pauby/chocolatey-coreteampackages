$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$toolsDir\helpers.ps1"

$destinationFolder = GetInstallDirectory -toolsPath $toolsDir

$packageArgs = @{
  packageName  = 'tor-browser'
  fileType     = 'exe'
  url          = ''
  url64        = ''
  checksum     = ''
  checksum64   = ''
  checksumType = 'sha256'
  silentArgs   = "/S", "/D=$destinationFolder"
}

Install-ChocolateyPackage @packageArgs

# Create .ignore files for exe
Get-ChildItem -Path $destinationFolder -Recurse | Where-Object {
  $_.Extension -eq '.exe' } | ForEach-Object {
  New-Item $($_.FullName + '.ignore') -Force -ItemType file
  # Suppress output of New-Item
} | Out-Null

$desktop = [System.Environment]::GetFolderPath('Desktop')

Install-ChocolateyShortcut `
  -ShortcutFilePath (Join-Path -Path $desktop -ChildPath 'Tor Browser.lnk') `
  -TargetPath (Join-Path -Path $destinationFolder -ChildPath 'Browser\firefox.exe') `
  -WorkingDirectory (Join-Path -Path $destinationFolder -ChildPath 'Browser')

# set NTFS modify file permissions to $toolsDir\tor-browser\ for user account that installed the package
$WhoAmI = whoami
$Acl = Get-Acl "$toolsDir\tor-browser"
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($WhoAmI, "Modify", 'ContainerInherit,ObjectInherit', 'None', "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl "$toolsDir\tor-browser" $Acl
