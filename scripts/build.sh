#!/bin/zsh
set -euo pipefail

repo_root=${0:A:h:h}
app_dir="$repo_root/dist/Goal Watchdog.app"
source "$repo_root/scripts/localization.sh"

rm -rf "$app_dir"
mkdir -p "$app_dir/Contents/MacOS" "$app_dir/Contents/Resources"

xcrun swiftc -warnings-as-errors \
    -target "$(uname -m)-apple-macosx14.0" \
    "$repo_root/Sources/GoalWatchdog/main.swift" \
    -o "$app_dir/Contents/MacOS/GoalWatchdog"

cp "$repo_root/Config/Info.plist" "$app_dir/Contents/Info.plist"
cp "$repo_root/Resources/AppIcon.icns" "$app_dir/Contents/Resources/AppIcon.icns"
cp "$repo_root/Resources/MenuBarIcon.png" "$app_dir/Contents/Resources/MenuBarIcon.png"
cp -R "$repo_root/Resources/en.lproj" "$repo_root/Resources/zh-Hant.lproj" "$app_dir/Contents/Resources/"

codesign --force \
    --options runtime \
    --sign - \
    --entitlements "$repo_root/Config/GoalWatchdog.entitlements" \
    "$app_dir"

localized_message built "$app_dir"
