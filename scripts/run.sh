#!/bin/zsh
set -euo pipefail

repo_root=${0:A:h:h}
binary="$repo_root/dist/ChatGPT Goal Watchdog.app/Contents/MacOS/ChatGPTGoalWatchdog"

if [[ ! -x "$binary" \
    || "$repo_root/Sources/ChatGPTGoalWatchdog/main.swift" -nt "$binary" \
    || "$repo_root/Config/Info.plist" -nt "$binary" \
    || "$repo_root/Config/ChatGPTGoalWatchdog.entitlements" -nt "$binary" \
    || "$repo_root/Resources/AppIcon.icns" -nt "$binary" \
    || "$repo_root/scripts/build.sh" -nt "$binary" ]]; then
    "$repo_root/scripts/build.sh"
fi

exec "$binary" "$@"
