#!/usr/bin/env python3
# Copyright 2026 Fries_I23
# Licensed under the Apache License, Version 2.0.

"""Print an installed iPhone simulator destination for native XCTest."""

import json
import re
import subprocess


def main() -> None:
    """Prefer the newest supported runtime, then a booted phone within it."""
    devices = json.loads(subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "available", "--json"], text=True
    ))["devices"]
    sdk = tuple(int(part) for part in subprocess.check_output(
        ["xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"], text=True
    ).strip().split("."))
    candidates = []
    for runtime, phones in devices.items():
        match = re.search(r"\.iOS-(\d+)-(\d+)(?:-(\d+))?$", runtime)
        if not match:
            continue
        version = tuple(int(part or 0) for part in match.groups())
        if version[:2] > (sdk + (0,))[:2] or version < (17, 0, 0):
            continue
        for phone in phones:
            if phone.get("isAvailable") and "iPhone" in phone.get("deviceTypeIdentifier", ""):
                candidates.append((version, phone["state"] == "Booted", phone["udid"]))
    if not candidates:
        raise SystemExit("No compatible iPhone simulator found. Install an iOS 17+ runtime in Xcode or set IOS_TEST_DESTINATION.")
    print(f"platform=iOS Simulator,id={max(candidates)[2]}")


if __name__ == "__main__":
    main()
