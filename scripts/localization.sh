preferred_language=$(defaults read -g AppleLanguages 2>/dev/null | awk -F '"' '/"/ { print $2; exit }')

case "$preferred_language" in
    zh-Hant*|zh-TW*|zh-HK*|zh-MO*) cli_language=zh-Hant ;;
    *) cli_language=en ;;
esac

localized_message() {
    case "$cli_language:$1" in
        zh-Hant:built) print -r -- "建置完成：$2" ;;
        zh-Hant:unexpectedMinimumOS) print -r -- "最低 macOS 版本不符：$2" ;;
        zh-Hant:checksPassed) print -r -- "所有檢查均已通過。" ;;
        en:built) print -r -- "Built: $2" ;;
        en:unexpectedMinimumOS) print -r -- "Unexpected minimum macOS version: $2" ;;
        en:checksPassed) print -r -- "Checks passed." ;;
    esac
}
