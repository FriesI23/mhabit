#!/usr/bin/env bash
# Resolves the PR associated with a completed check-pr-main.yml run (via the
# commits API, so this works for fork PRs too), then gates on draft status
# and the `need test-build` label.
#
# Required env: GH_TOKEN, SHA, GITHUB_REPOSITORY, GITHUB_OUTPUT (the latter
# two are provided automatically by the runner).
set -eo pipefail

PULLS_JSON=$(gh api "repos/$GITHUB_REPOSITORY/commits/$SHA/pulls")
NUMBER=$(echo "$PULLS_JSON" | jq -r --arg sha "$SHA" '[.[] | select(.state=="open" and .head.sha==$sha)][0].number // empty')
if [ -z "$NUMBER" ]; then
  echo "proceed=false" >> "$GITHUB_OUTPUT"
  exit 0
fi

PR_JSON=$(gh api "repos/$GITHUB_REPOSITORY/pulls/$NUMBER")
DRAFT=$(echo "$PR_JSON" | jq -r '.draft')
BASE_SHA=$(echo "$PR_JSON" | jq -r '.base.sha')
LABELS=$(echo "$PR_JSON" | jq -r '[.labels[].name] | join(",")')

HEAD_REPO=$(echo "$PR_JSON" | jq -r '.head.repo.full_name')
BASE_REPO=$(echo "$PR_JSON" | jq -r '.base.repo.full_name')
if [ "$HEAD_REPO" != "$BASE_REPO" ]; then
  FORK="true"
else
  FORK="false"
fi

if [ "$DRAFT" = "true" ]; then
  PROCEED="false"
elif printf ',%s,' "$LABELS" | grep -q ',need test-build,'; then
  PROCEED="true"
else
  PROCEED="false"
fi

{
  echo "number=$NUMBER"
  echo "sha=$SHA"
  echo "base-sha=$BASE_SHA"
  echo "fork=$FORK"
  echo "proceed=$PROCEED"
} >> "$GITHUB_OUTPUT"
