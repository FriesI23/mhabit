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
# Same semantics github/command@v2.0.3 uses for its `fork` output
# (pr.data.head.repo.fork) on the manual /build path, so both entry points
# agree on whether to route through the check-ci-review gate. Defaults to
# "fork" (the safer choice) if head.repo is missing, e.g. a deleted fork.
FORK=$(echo "$PR_JSON" | jq -r 'if .head.repo == null then true else .head.repo.fork end')

if [ "$DRAFT" = "true" ]; then
  PROCEED="false"
elif echo "$PR_JSON" | jq -e '[.labels[].name] | any(. == "need test-build")' >/dev/null; then
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
