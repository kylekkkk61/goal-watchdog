#!/bin/zsh
set -euo pipefail

repo_root=${0:A:h:h}
app="$repo_root/dist/ChatGPT Goal Watchdog.app"

"$repo_root/scripts/build.sh"
"$repo_root/scripts/run.sh" --self-test
plutil -lint "$app/Contents/Info.plist"
codesign --verify --strict "$app"

echo "Checks passed."
