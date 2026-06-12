$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $root "manifest.json"
$manifest = [System.IO.File]::ReadAllText(
    $manifestPath,
    [System.Text.Encoding]::UTF8
) | ConvertFrom-Json
$version = $manifest.version
$dist = Join-Path $root "dist"
$amoDist = Join-Path $dist "amo"
$stage = Join-Path ([System.IO.Path]::GetTempPath()) "google-search-tabs-keeper-$version"
$sourceStage = Join-Path ([System.IO.Path]::GetTempPath()) "google-search-tabs-keeper-source-$version"
$files = @(
    "manifest.json",
    "content.js",
    "styles.css",
    "README.md",
    "LICENSE"
)
$icons = @(
    "icon16.png",
    "icon32.png",
    "icon48.png",
    "icon128.png"
)

function New-PortableZip {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDirectory,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Force
    }

    $sourceRoot = [System.IO.Path]::GetFullPath($SourceDirectory)
    $fileStream = [System.IO.File]::Open(
        $DestinationPath,
        [System.IO.FileMode]::CreateNew
    )

    try {
        $archive = [System.IO.Compression.ZipArchive]::new(
            $fileStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $false
        )

        try {
            foreach ($file in Get-ChildItem -LiteralPath $sourceRoot -File -Recurse) {
                $relativePath = $file.FullName.Substring($sourceRoot.Length).TrimStart("\", "/")
                $entryName = $relativePath.Replace("\", "/")
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $archive,
                    $file.FullName,
                    $entryName,
                    [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
            }
        }
        finally {
            $archive.Dispose()
        }
    }
    finally {
        $fileStream.Dispose()
    }
}

$resolvedStage = [System.IO.Path]::GetFullPath($stage)
$resolvedTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
if (-not $resolvedStage.StartsWith($resolvedTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Staging path must be inside the temporary directory."
}

if (Test-Path -LiteralPath $stage) {
    Remove-Item -LiteralPath $stage -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $dist | Out-Null
New-Item -ItemType Directory -Force -Path $amoDist | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $stage "icons") | Out-Null

foreach ($file in $files) {
    Copy-Item -LiteralPath (Join-Path $root $file) -Destination $stage
}

foreach ($icon in $icons) {
    Copy-Item -LiteralPath (Join-Path $root "icons\$icon") -Destination (Join-Path $stage "icons")
}

foreach ($browser in @("chrome", "firefox")) {
    $archive = Join-Path $dist "google-search-tabs-keeper-$browser-v$version.zip"
    New-PortableZip -SourceDirectory $stage -DestinationPath $archive
}

$amoArchive = Join-Path $amoDist "google-search-tabs-keeper-firefox-v$version-amo.zip"
New-PortableZip -SourceDirectory $stage -DestinationPath $amoArchive

if (Test-Path -LiteralPath $sourceStage) {
    Remove-Item -LiteralPath $sourceStage -Recurse -Force
}
New-Item -ItemType Directory -Force -Path (Join-Path $sourceStage "icons") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $sourceStage "scripts") | Out-Null

foreach ($file in $files + @(".gitignore", "AMO_SUBMISSION.md", "PRIVACY.md")) {
    Copy-Item -LiteralPath (Join-Path $root $file) -Destination $sourceStage
}
foreach ($icon in $icons) {
    Copy-Item -LiteralPath (Join-Path $root "icons\$icon") -Destination (Join-Path $sourceStage "icons")
}
Copy-Item -LiteralPath (Join-Path $root "scripts\build-packages.ps1") -Destination (Join-Path $sourceStage "scripts")

$sourceArchive = Join-Path $amoDist "google-search-tabs-keeper-v$version-source.zip"
New-PortableZip -SourceDirectory $sourceStage -DestinationPath $sourceArchive

Remove-Item -LiteralPath $stage -Recurse -Force
Remove-Item -LiteralPath $sourceStage -Recurse -Force
Get-ChildItem -LiteralPath $dist -Filter "*.zip" -Recurse
