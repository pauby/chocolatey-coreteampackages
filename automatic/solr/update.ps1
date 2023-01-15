Import-Module au

# This is found on the Solr downloads page and is different for versions earlier than 9.
# Assuming when they move to v10, this URL may change
$releases = 'https://archive.apache.org/dist/solr/solr/'

function global:au_SearchReplace {
  @{
    "$($Latest.PackageName).nuspec" = @{
      "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotesURL)`$2"
    }
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)(^\s*url\s*=\s*)'.*'"            = "`${1}'$($Latest.URL32)'"
      "(?i)(^\s*checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum32)'"
      "(?i)(^\s*checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
    }
  }
}

function global:au_BeforeUpdate {
  $Latest.Checksum32 = Get-Checksum -version $Latest.SoftwareVersion
}

function global:au_GetLatest {
  $downloadPage = Invoke-WebRequest -Uri $releases -UseBasicParsing

  $regex = '[\d\.]+'
  $version = $downloadPage.links | Where-Object href -Match $regex | Select-Object -Last 1 -Expand href
  # If the last character in the version string is '/', remove it
  if ($version.substring($version.length - 1, 1) -eq '/') {
    $version = $version.substring(0, $version.length - 1)
  }

  @{
    URL32           = "https://archive.apache.org/dist/solr/solr/$version/solr-$version.tgz"
    ChecksumType32  = "sha512"
    Version         = $version
    SoftwareVersion = $version
    ReleaseNotesURL = "https://solr.apache.org/docs/{0}/changes/Changes.html" -f $version.replace('.', '_')
  }
}

function Get-Checksum() {
  param([string]$version)
  Write-Warning "URL: https://archive.apache.org/dist/solr/solr/$version/solr-$version.tgz.sha512"

  $checksumFile = Invoke-WebRequest -Uri "https://archive.apache.org/dist/solr/solr/$version/solr-$version.tgz.sha512" -UseBasicParsing

  $regex = "\*solr-$version\.tgz$"
  $checksum = $checksumFile.RawContent -split "\n" -match $regex -split " " | Select-Object -First 1

  return $checksum
}

update -ChecksumFor none
