Import-Module au
Import-Module $env:chocolateyInstall\helpers\chocolateyInstaller.psm1

$releases = "https://www.torproject.org/download/languages/"
$domain = $releases -split '(?<=//.+)/' | Select-Object -First 1

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)^(\s*url\s*=\s*)('.*')"        = "`${1}'$($Latest.URL32)'"
      "(?i)^(\s*url64\s*=\s*)('.*')"      = "`${1}'$($Latest.URL64)'"
      "(?i)^(\s*checksum\s*=\s*)('.*')"   = "`${1}'$($Latest.Checksum32)'"
      "(?i)^(\s*checksum64\s*=\s*)('.*')" = "`${1}'$($Latest.Checksum64)'"
    }
  }
}

function global:au_BeforeUpdate {
}

function global:au_GetLatest {
  $downloadPage = Invoke-WebRequest -Uri $releases -UseBasicParsing
  $allExes = $downloadPage.Links | Where-Object href -Match "\.exe$" | Select-Object -Expand href
  if ($allExes.count -ne 2) {
    throw 'Missing urls was found for either 32 bit or 64 bit'
  }

  if ($allExes[0] -match '(?<version>[\d\.]+)_ALL.exe$') {
    $version = $matches.version
  }
  else {
    throw "Cannot find a version number."
  }

  $url32 = "{0}{1}" -f $domain, ($allExes | Where-Object { $_ -notmatch 'win64' })
  $url64 = "{0}{1}" -f $domain, ($allExes | Where-Object { $_ -match 'win64' })

  @{
    URL32   = $url32
    URL64   = $url64
    Version = $version
  }
}

update -ChecksumFor all
