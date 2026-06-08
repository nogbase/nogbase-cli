[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$Version = $env:NOGBASE_CLI_VERSION,
  [string]$InstallDir = $env:NOGBASE_CLI_INSTALL_DIR,
  [string]$Repo = $env:NOGBASE_CLI_REPO
)

$ErrorActionPreference = "Stop"

if (-not [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
  throw "The PowerShell installer supports Windows only. Use install.sh on Linux or macOS."
}

if ([string]::IsNullOrWhiteSpace($Repo)) {
  $Repo = "nogbase/nogbase-cli"
}
if ([string]::IsNullOrWhiteSpace($Version)) {
  $Version = "latest"
}
if ([string]::IsNullOrWhiteSpace($InstallDir)) {
  $InstallDir = Join-Path $HOME "AppData\Local\Nogbase\bin"
}

if ($Version -eq "latest") {
  $Release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
  if ($Release.tag_name -notmatch '^nogbase-cli-v(.+)$') {
    throw "Could not resolve latest nogbase-cli release from tag '$($Release.tag_name)'"
  }
  $Version = $Matches[1]
}

switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()) {
  "X64" { $Arch = "amd64" }
  "Arm64" { $Arch = "arm64" }
  default { throw "Unsupported architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)" }
}

$Name = "nogbase_${Version}_windows_${Arch}"
$Archive = "$Name.zip"
$BaseUrl = "https://github.com/$Repo/releases/download/nogbase-cli-v$Version"
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("nogbase-cli-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
  $ArchivePath = Join-Path $TempDir $Archive
  $ChecksumPath = Join-Path $TempDir "$Archive.sha256"

  Invoke-WebRequest -Uri "$BaseUrl/$Archive" -OutFile $ArchivePath
  Invoke-WebRequest -Uri "$BaseUrl/$Archive.sha256" -OutFile $ChecksumPath

  $ExpectedHash = ((Get-Content $ChecksumPath -Raw).Trim() -split '\s+')[0].ToLowerInvariant()
  $ActualHash = (Get-FileHash -Algorithm SHA256 $ArchivePath).Hash.ToLowerInvariant()
  if ([string]::IsNullOrWhiteSpace($ExpectedHash) -or $ExpectedHash -ne $ActualHash) {
    throw "Checksum verification failed for $Archive"
  }

  Expand-Archive -Path $ArchivePath -DestinationPath $TempDir -Force
  New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
  Copy-Item -Path (Join-Path $TempDir "$Name\nogbase.exe") -Destination (Join-Path $InstallDir "nogbase.exe") -Force
  Copy-Item -Path (Join-Path $TempDir "$Name\ngb.exe") -Destination (Join-Path $InstallDir "ngb.exe") -Force

  Write-Host "Installed nogbase $Version to $InstallDir"
  Write-Host "Make sure $InstallDir is on your PATH."
} finally {
  Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}
