#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd "$CI_PRIMARY_REPOSITORY_PATH" # change working directory to the root of your cloned repo.

# Use Flutter from the project's submodule instead of cloning from GitHub.
export PATH="$PATH:$CI_PRIMARY_REPOSITORY_PATH/.flutter/bin"

# Build
if [[ -n "$CI_XCODEBUILD_SCHEME" ]]; then
    echo "Detected scheme: $CI_XCODEBUILD_SCHEME"
    echo "Running: flutter build macos --release --flavor $CI_XCODEBUILD_SCHEME"
    flutter build macos --release --flavor "$CI_XCODEBUILD_SCHEME"
else
    echo "No scheme detected. Running: flutter build macos --release"
    flutter build macos --release
fi
