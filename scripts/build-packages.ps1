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
    if (Test-Path -LiteralPath $archive) {
        Remove-Item -LiteralPath $archive -Force
    }
    Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $archive -CompressionLevel Optimal
}

$amoArchive = Join-Path $amoDist "google-search-tabs-keeper-firefox-v$version-amo.zip"
if (Test-Path -LiteralPath $amoArchive) {
    Remove-Item -LiteralPath $amoArchive -Force
}
Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $amoArchive -CompressionLevel Optimal

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
if (Test-Path -LiteralPath $sourceArchive) {
    Remove-Item -LiteralPath $sourceArchive -Force
}
Compress-Archive -Path (Join-Path $sourceStage "*") -DestinationPath $sourceArchive -CompressionLevel Optimal

Remove-Item -LiteralPath $stage -Recurse -Force
Remove-Item -LiteralPath $sourceStage -Recurse -Force
Get-ChildItem -LiteralPath $dist -Filter "*.zip" -Recurse
