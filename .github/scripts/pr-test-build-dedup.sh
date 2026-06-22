#!/usr/bin/env bash
# Resolves what the `/build` comment should do: print help, stop/cancel the
# in-progress run for this PR, ignore a duplicate request, or proceed.
#
# Required env: GH_TOKEN, ISSUE_NUMBER, RAW_PARAMS, GITHUB_OUTPUT,
# GITHUB_RUN_ID (the latter two are provided automatically by the runner).
set -eo pipefail

PARAM_NORM=$(printf '%s' "$RAW_PARAMS" | tr '[:upper:]' '[:lower:]' | xargs)
MODE="build"
if echo "$PARAM_NORM" | grep -qE '^(stop|cancel)$'; then
  MODE="stop"
elif echo "$PARAM_NORM" | grep -qE '^(help|-h|--help)$'; then
  MODE="help"
fi

if [ "$MODE" = "help" ]; then
  MSG=$(cat <<'HELP_EOF'
Usage: /build [target]

  /build                 same as `/build auto`
  /build auto            build only platforms whose paths changed (same logic as automatic builds)
  /build all             build all platforms (android, ios, linux, macos) unconditionally
  /build <platforms>     build only the given platforms, comma- or space-separated
                         e.g. /build android,ios
  /build stop            cancel an in-progress manual build
  /build cancel          alias for stop
  /build help            show this message
HELP_EOF
  )
  echo "proceed=false" >> "$GITHUB_OUTPUT"
  {
    echo "message<<EOF"
    echo "$MSG"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

RUNS_JSON=$(gh run list --workflow=pr-test-build.yml --json databaseId,name,status --limit 50)
RUNNING_IDS=$(echo "$RUNS_JSON" | jq -r \
  --arg prefix "/build #$ISSUE_NUMBER (" \
  --arg self "$GITHUB_RUN_ID" \
  '.[] | select(.status == "in_progress" or .status == "queued") | select(.name | startswith($prefix)) | select((.databaseId | tostring) != $self) | .databaseId')

if [ "$MODE" = "stop" ]; then
  if [ -z "$RUNNING_IDS" ]; then
    MSG="ℹ️ No test build is currently running for this PR."
  else
    for id in $RUNNING_IDS; do gh run cancel "$id"; done
    MSG="🛑 Cancelled the in-progress test build for this PR."
  fi
  echo "proceed=false" >> "$GITHUB_OUTPUT"
elif [ -n "$RUNNING_IDS" ]; then
  # shellcheck disable=SC2016 # intentionally literal, no expansion wanted
  MSG='⏳ A test build is already running for this PR — ignoring this `/build` request. Comment `/build stop` to cancel it first.'
  echo "proceed=false" >> "$GITHUB_OUTPUT"
else
  MSG=""
  echo "proceed=true" >> "$GITHUB_OUTPUT"
fi
{
  echo "message<<EOF"
  echo "$MSG"
  echo "EOF"
} >> "$GITHUB_OUTPUT"
