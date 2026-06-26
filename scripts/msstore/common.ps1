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
Shared helpers for scripts/msstore/*.ps1.
#>

function ConvertFrom-MsstoreJson {
    <#
    .SYNOPSIS
    Parses the JSON object out of `msstore`'s console output.

    .DESCRIPTION
    msstore wraps long console lines (observed around column 80). For a
    long non-ASCII string value (e.g. a Chinese listing description),
    that wrap can fall in the middle of a \uXXXX escape, splitting it
    across two lines. Piping that text straight into ConvertFrom-Json
    then fails with "Invalid Unicode escape sequence", since the joined
    text contains a raw newline inside the escape.

    Recovered by slicing out just the {...} body (dropping any
    non-JSON status lines like "Retrieving Submission") and stripping
    embedded raw newlines before parsing. This is safe regardless of
    where the wrap fell: JSON is whitespace-insensitive between tokens,
    and a spec-compliant encoder never emits a literal raw newline
    inside a string value (it would escape it as \n).

    .PARAMETER Lines
    Captured stdout from an msstore command, as returned by PowerShell
    when assigning or passing through an external command's output
    (one string per line).
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Lines
    )

    $raw = $Lines -join "`n"
    $start = $raw.IndexOf('{')
    $end = $raw.LastIndexOf('}')
    if ($start -lt 0 -or $end -lt $start) {
        throw "msstore output did not contain a JSON object:`n$raw"
    }

    $json = $raw.Substring($start, $end - $start + 1) -replace '[\r\n]', ''
    return $json | ConvertFrom-Json
}
