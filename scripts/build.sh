#!/bin/zsh
set -euo pipefail

repo_root=${0:A:h:h}
app_dir="$repo_root/dist/ChatGPT Goal Watchdog.app"

rm -rf "$app_dir"
mkdir -p "$app_dir/Contents/MacOS" "$app_dir/Contents/Resources"

xcrun swiftc -warnings-as-errors \
    -target "$(uname -m)-apple-macosx14.0" \
    "$repo_root/Sources/ChatGPTGoalWatchdog/main.swift" \
    -o "$app_dir/Contents/MacOS/ChatGPTGoalWatchdog"

cp "$repo_root/Config/Info.plist" "$app_dir/Contents/Info.plist"
cp "$repo_root/Resources/AppIcon.icns" "$app_dir/Contents/Resources/AppIcon.icns"

codesign --force \
    --options runtime \
    --sign - \
    --entitlements "$repo_root/Config/ChatGPTGoalWatchdog.entitlements" \
    "$app_dir"

echo "Built: $app_dir"
