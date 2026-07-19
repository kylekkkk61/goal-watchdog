#!/bin/zsh
set -euo pipefail

repo_root=${0:A:h:h}
app="$repo_root/dist/Goal Watchdog.app"
binary="$app/Contents/MacOS/GoalWatchdog"
source "$repo_root/scripts/localization.sh"

"$repo_root/scripts/build.sh"
"$repo_root/scripts/run.sh" --self-test
plutil -lint "$app/Contents/Info.plist"
codesign --verify --strict "$app"
test -f "$app/Contents/Resources/MenuBarIcon.png"
plutil -lint "$app/Contents/Resources/en.lproj/Localizable.strings" \
    "$app/Contents/Resources/en.lproj/InfoPlist.strings" \
    "$app/Contents/Resources/zh-Hant.lproj/Localizable.strings" \
    "$app/Contents/Resources/zh-Hant.lproj/InfoPlist.strings"

minimum_os=$(vtool -show-build "$binary" | awk '$1 == "minos" { print $2; exit }')
if [[ "$minimum_os" != "14.0" ]]; then
    localized_message unexpectedMinimumOS "$minimum_os" >&2
    exit 1
fi

localized_message checksPassed
