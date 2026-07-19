#!/bin/zsh
set -euo pipefail

repo_root=${0:A:h:h}
app="$repo_root/dist/Goal Watchdog.app"
binary="$app/Contents/MacOS/GoalWatchdog"

"$repo_root/scripts/build.sh"
"$repo_root/scripts/run.sh" --self-test
plutil -lint "$app/Contents/Info.plist"
codesign --verify --strict "$app"
test -f "$app/Contents/Resources/MenuBarIcon.png"

minimum_os=$(vtool -show-build "$binary" | awk '$1 == "minos" { print $2; exit }')
if [[ "$minimum_os" != "14.0" ]]; then
    echo "Unexpected minimum macOS version: $minimum_os" >&2
    exit 1
fi

echo "Checks passed."
