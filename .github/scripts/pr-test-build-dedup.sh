#!/usr/bin/env bash
# Resolves what the `/build` comment should do: print help, stop/cancel the
# in-progress run for this PR, reject an unrecognized target, ignore a
# duplicate request, or proceed.
#
# Required env: GH_TOKEN, ISSUE_NUMBER, COMMENT_BODY, LABELED, GITHUB_OUTPUT,
# GITHUB_RUN_ID (the latter two are provided automatically by the runner).
set -eo pipefail

# COMMENT_BODY is the full `/build ...` comment text (github/command's own
# `params` output is unusable here: actions/core trims whitespace-only input
# values, so a literal " " param_separator collapses to "", which makes it
# split params character-by-character instead of on spaces).
RAW_PARAMS=$(printf '%s' "$COMMENT_BODY" | sed -E 's#^/build[[:space:]]*##')
PARAM_NORM=$(printf '%s' "$RAW_PARAMS" | tr ',|' ' ' | tr '[:upper:]' '[:lower:]' | xargs)
MODE="build"
if echo "$PARAM_NORM" | grep -qE '^(stop|cancel)$'; then
  MODE="stop"
elif echo "$PARAM_NORM" | grep -qE '^(help|-h|--help)$'; then
  MODE="help"
elif [ -n "$PARAM_NORM" ] && [ "$PARAM_NORM" != "auto" ] && ! echo " $PARAM_NORM " | grep -qw all; then
  # An explicit target list (anything other than empty/auto/all) must name
  # at least one real platform, or nothing will actually build.
  VALID_TARGET=false
  for p in android ios linux macos; do
    echo " $PARAM_NORM " | grep -qw "$p" && VALID_TARGET=true
  done
  [ "$VALID_TARGET" = false ] && MODE="invalid"
fi

if [ "$MODE" = "help" ]; then
  MSG=$(cat <<'HELP_EOF'
Usage: /build [target]

  /build                 same as `/build auto`
  /build auto            build only platforms whose paths changed
  /build all             build all platforms (android, ios, linux, macos) unconditionally
  /build <platforms>     build only the given platforms, comma- or space-separated
                         e.g. /build android,ios
  /build stop            cancel an in-progress build
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

if [ "$MODE" = "invalid" ]; then
  MSG="⚠️ No recognized platform in \`/build $RAW_PARAMS\` — nothing would be built. Valid targets: \`android\`, \`ios\`, \`linux\`, \`macos\`, \`all\`, \`auto\` (or no argument). Comment \`/build help\` for full usage."
  echo "proceed=false" >> "$GITHUB_OUTPUT"
  {
    echo "message<<EOF"
    echo "$MSG"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

# An actual build request requires the `need test-build` label; `stop` must
# still be able to cancel a build that started while the label was present,
# so only `$MODE = build` is gated here (`help`/`invalid` already exited above).
if [ "$MODE" = "build" ] && [ "$LABELED" != "true" ]; then
  # shellcheck disable=SC2016 # intentionally literal, no expansion wanted
  MSG='⚠️ This PR does not have the `need test-build` label — add it to enable `/build`.'
  echo "proceed=false" >> "$GITHUB_OUTPUT"
  {
    echo "message<<EOF"
    echo "$MSG"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

RUNS_JSON=$(gh run list --workflow=pr-test-build.yml --status in_progress --json databaseId,name,status --limit 50; \
            gh run list --workflow=pr-test-build.yml --status queued --json databaseId,name,status --limit 50)
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
