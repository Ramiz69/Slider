#!/usr/bin/env python3
"""Prints an `xcodebuild -destination` string for the newest available iPhone simulator.

Pinning a device by name breaks whenever a runner image drops it, so CI asks the machine
what it actually has instead.
"""

import json
import subprocess
import sys


def runtime_version(runtime: str) -> tuple[int, ...]:
    """Turns `com.apple.CoreSimulator.SimRuntime.iOS-26-5` into `(26, 5)`."""
    identifier = runtime.rsplit(".", 1)[-1]
    if not identifier.startswith("iOS-"):
        return ()

    return tuple(int(part) for part in identifier[len("iOS-"):].split("-") if part.isdigit())


def rank(name: str) -> int:
    """Prefers Pro models, then plain iPhones, so the chosen device is stable across runs."""
    if "Pro Max" in name:
        return 2
    if "Pro" in name:
        return 3

    return 1


def main() -> int:
    listing = subprocess.run(["xcrun", "simctl", "list", "devices", "available", "--json"],
                             capture_output=True,
                             text=True,
                             check=True).stdout
    best = None
    for runtime, devices in json.loads(listing)["devices"].items():
        version = runtime_version(runtime)
        if not version:
            continue

        for device in devices:
            name = device.get("name", "")
            if not name.startswith("iPhone"):
                continue

            candidate = (version, rank(name), name)
            if best is None or candidate > best:
                best = candidate

    if best is None:
        print("No available iPhone simulator found", file=sys.stderr)

        return 1

    version, _, name = best
    print(f"platform=iOS Simulator,name={name},OS={'.'.join(map(str, version))}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
