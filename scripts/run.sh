#!/bin/zsh
set -euo pipefail

repo_root=${0:A:h:h}
binary="$repo_root/dist/Goal Watchdog.app/Contents/MacOS/GoalWatchdog"

if [[ ! -x "$binary" \
    || "$repo_root/Sources/GoalWatchdog/main.swift" -nt "$binary" \
    || "$repo_root/Config/Info.plist" -nt "$binary" \
    || "$repo_root/Config/GoalWatchdog.entitlements" -nt "$binary" \
    || "$repo_root/Resources/AppIcon.icns" -nt "$binary" \
    || "$repo_root/Resources/MenuBarIcon.png" -nt "$binary" \
    || "$repo_root/scripts/build.sh" -nt "$binary" ]]; then
    "$repo_root/scripts/build.sh"
fi

exec "$binary" "$@"
