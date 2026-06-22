#!/usr/bin/env bash
# Collapses the four ANDROID/IOS/LINUX/MACOS "true"/"false" env vars into a
# single JSON array output (e.g. '["android","linux"]' or '[]'), consumed
# directly by the calling workflow's `build` job matrix.
#
# Required env: ANDROID, IOS, LINUX, MACOS, GITHUB_OUTPUT (the latter
# provided automatically by the runner).
set -eo pipefail

PARTS=()
[ "$ANDROID" = "true" ] && PARTS+=("\"android\"")
[ "$IOS" = "true" ] && PARTS+=("\"ios\"")
[ "$LINUX" = "true" ] && PARTS+=("\"linux\"")
[ "$MACOS" = "true" ] && PARTS+=("\"macos\"")

JSON="[$(IFS=,; echo "${PARTS[*]:-}")]"
echo "platforms=$JSON" >> "$GITHUB_OUTPUT"
