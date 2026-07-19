<p align="center">
  <img src="Resources/ReadmeBanner.png" alt="Goal Watchdog" width="1080">
</p>

<p align="center">
  <a href="README.md">English</a> · <strong>繁體中文</strong>
</p>

Goal Watchdog 是一款輕量的 macOS 狀態列工具，用來監控 ChatGPT 桌面版目前顯示的對話。當目標模式出現「**恢復目標**」按鈕時，Goal Watchdog 會自動點擊，接著還原原本位於前景的 App 與滑鼠位置。

## 為什麼需要 Goal Watchdog？

長時間執行的目標可能因本地網路不穩定、安全審核假陽性，或其他任何原因而暫停。Goal Watchdog 只有一個目的：當 ChatGPT 提供「**恢復目標**」時協助按下，讓目標能完整持續進行；它不會繞過 ChatGPT 未開放的安全機制或控制項。

## 功能

- 僅監控 ChatGPT 目前主視窗中的對話。
- 透過 macOS「輔助使用」動態尋找恢復按鈕的位置。
- 支援 `Resume goal`、`恢復目標` 與 `恢复目标`。
- 不讀取目標文字、不擷取螢幕、不儲存憑證，也不使用網路。
- 可從終端機執行，或作為沒有 Dock 圖示的狀態列 App 使用。

## 系統需求

- macOS 14 或更新版本
- ChatGPT 桌面版
- Xcode Command Line Tools（執行 `xcode-select --install` 安裝）

## 從終端機執行

```sh
./scripts/run.sh
```

Goal Watchdog 會持續附著於目前的終端機工作階段；按下 `Control-C` 即可停止。第一次執行會建立 App bundle，之後只有輸入檔案變更時才會重新編譯。

## 編譯 App

```sh
./scripts/build.sh
open "dist/Goal Watchdog.app"
```

本專案提供原始碼，不提供可直接下載的 App 執行檔。本機編譯使用 ad-hoc 簽章，且未經 Apple 公證，因此重新編譯後，macOS 可能會要求再次授予「輔助使用」權限。

## 權限

Goal Watchdog 需要以下權限：

- **輔助使用**：檢查目前的 ChatGPT 視窗並送出滑鼠點擊。
- **自動化 → ChatGPT**：在點擊前暫時將 ChatGPT 切換到前景。

如果啟用權限後仍無法使用，請前往「系統設定 → 隱私權與安全性 → 輔助使用」，移除舊的 Goal Watchdog 項目、重新加入剛編譯的 App，然後重新啟動 Goal Watchdog。通常不需要重新啟動 ChatGPT。

## 驗證專案

```sh
./scripts/check.sh
```

檢查程序會編譯 App、執行按鈕語系自我測試、驗證 property list 與本機簽章，並確認執行檔支援 macOS 14。

## 限制

- 只監控 ChatGPT 目前主視窗中顯示的對話。
- ChatGPT 必須正在執行，而且目前對話中必須出現支援的恢復目標按鈕。
- ChatGPT 的介面或「輔助使用」結構變更時，Goal Watchdog 可能需要配合更新。
- Goal Watchdog 是獨立的社群專案，與 OpenAI 沒有從屬或合作關係，也未獲其背書。

## 專案文件

- [隱私說明](PRIVACY.md)
- [安全政策](SECURITY.md)
- [貢獻指南](CONTRIBUTING.md)
- [發布流程](RELEASING.md)
- [MIT 授權條款](LICENSE)

## 授權

Goal Watchdog 採用 [MIT License](LICENSE)。
