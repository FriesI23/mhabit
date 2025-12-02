#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd "$CI_PRIMARY_REPOSITORY_PATH" # change working directory to the root of your cloned repo.

# Use Flutter from the project's submodule instead of cloning from GitHub.
export PATH="$PATH:$CI_PRIMARY_REPOSITORY_PATH/.flutter/bin"

# Build
if [[ -n "$CI_XCODE_SCHEME" ]]; then
    echo "Detected scheme: $CI_XCODE_SCHEME"
    echo "Running: flutter build macos --release --flavor $CI_XCODE_SCHEME"
    flutter build macos --release --flavor "$CI_XCODE_SCHEME" --config-only
else
    echo "No scheme detected. Running: flutter build macos --release"
    flutter build macos --release --config-only
fi
