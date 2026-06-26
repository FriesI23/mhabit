# Copyright 2026 Fries_I23
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

<#
.SYNOPSIS
Stages per-locale "what's new" / release notes onto the current Microsoft
Store submission draft for the given product.

.DESCRIPTION
Reuses the same per-build changelog files Android's fastlane lane and the
iOS/macOS TestflightChangelogHelper already read from
(android/app/src/f_store/fastlane/metadata/android/<locale>/changelogs/
<build>.txt). Best-effort: skips a locale silently when there's no
changelog file for this build, or no matching Store listing language.
Skips entirely (no `msstore submission updateMetadata` call) when nothing
matched. Requires `msstore reconfigure` to have already run in this shell.

Also writes a `submission-id` GitHub Actions output with this
submission's Id, unconditionally (even when no changelog locale
matched) — the caller is expected to persist it (via `gh variable set`
into MSSTORE_LAST_CI_SUBMISSION_ID) so a later run of
check_draft_ownership.ps1 can tell this draft was staged by this
pipeline and is safe to overwrite.

.PARAMETER ProductId
Microsoft Store product ID (e.g. "9NG22PL73NGZ").

.PARAMETER PubspecPath
Path to pubspec.yaml, used to read the build number (the `+<n>` suffix of
the `version:` field).

.PARAMETER MetadataRoot
Root directory of the Android fastlane metadata to read changelogs from.

.PARAMETER LocaleMap
Hashtable mapping Android fastlane locale codes to Microsoft Store
language codes.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProductId,

    [string]$PubspecPath = "pubspec.yaml",

    [string]$MetadataRoot = "android/app/src/f_store/fastlane/metadata/android",

    [hashtable]$LocaleMap = @{ "en-US" = "en-us"; "zh-CN" = "zh-cn" }
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "common.ps1")

function Get-FlutterBuildNumber {
    param([string]$Path)

    $versionLine = Select-String -Path $Path -Pattern '^version:\s*(.+)$' | Select-Object -First 1
    if (-not $versionLine) {
        throw "Missing version in $Path"
    }
    $version = $versionLine.Matches[0].Groups[1].Value.Trim()
    if ($version -notmatch '\+(\d+)$') {
        throw "Missing build number in $Path version: $version"
    }
    return $Matches[1]
}

$buildNumber = Get-FlutterBuildNumber -Path $PubspecPath
$submission = ConvertFrom-MsstoreJson -Lines (msstore submission get $ProductId)

Write-Output "submission-id=$($submission.Id)" >> $env:GITHUB_OUTPUT
Write-Host "Submission Id is $($submission.Id)"

$changed = $false
foreach ($androidLocale in $LocaleMap.Keys) {
    $storeLang = $LocaleMap[$androidLocale]
    $changelogPath = Join-Path $MetadataRoot "$androidLocale/changelogs/$buildNumber.txt"
    $listing = $submission.Listings.$storeLang

    if (-not (Test-Path $changelogPath) -or $null -eq $listing) {
        Write-Host "Skipping $androidLocale -> $storeLang (no changelog file for build $buildNumber, or no matching Store listing language)"
        continue
    }

    $listing.BaseListing.ReleaseNotes = (Get-Content -Raw $changelogPath).Trim()
    $changed = $true
    Write-Host "Staged $storeLang release notes from $changelogPath"
}

if (-not $changed) {
    Write-Host "No matching changelog for build $buildNumber; skipping metadata update."
    exit 0
}

$updatedJson = $submission | ConvertTo-Json -Depth 20 -Compress
msstore submission updateMetadata $ProductId $updatedJson
