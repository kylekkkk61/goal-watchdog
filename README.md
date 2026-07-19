# ChatGPT Goal Watchdog

![ChatGPT Goal Watchdog icon](Resources/AppIcon.png)

A small macOS watchdog that watches the currently displayed conversation in the ChatGPT desktop app. When Goal mode exposes a **Resume goal** button, the watchdog clicks it and restores the previous app and pointer position.

> Private pre-release. There are no official downloadable binaries. Build and run it locally from source.

## What it does

- Watches only the current ChatGPT main window.
- Resolves the resume button and its position dynamically through macOS Accessibility.
- Supports `恢復目標`, `恢复目标`, and `Resume goal`.
- Does not read goal text, capture the screen, or use the network.
- Runs as a menu bar app without a Dock icon.

## Requirements

- macOS 14 or later
- The ChatGPT desktop app
- Xcode Command Line Tools (`xcode-select --install`)

## Run from Terminal

The watchdog stays attached to the current Terminal session. Stop it with `Control-C`.

```sh
./scripts/run.sh
```

The first run builds the app bundle. Later runs reuse it until a source or configuration file changes.

## Build the app

```sh
./scripts/build.sh
open "dist/ChatGPT Goal Watchdog.app"
```

The local build is ad-hoc signed. It is not notarized by Apple, and macOS may require Accessibility authorization again after rebuilding because an ad-hoc signature does not provide a stable identity across versions.

## Permissions

The app needs:

- **Accessibility** to inspect the ChatGPT window and send the mouse click.
- **Automation → ChatGPT** to bring ChatGPT to the foreground before clicking.

No credentials or ChatGPT data are stored.

If permission remains unavailable after enabling it, remove the existing ChatGPT Goal Watchdog entry from Accessibility, add the newly built app again, and relaunch the watchdog. ChatGPT itself does not normally need to be restarted.

## Verify a build

```sh
./scripts/check.sh
```

This compiles the app, runs its small language-matching self-test, validates the property list, and verifies the local signature.

## Scope and limitations

- Only the conversation shown in ChatGPT's current main window is monitored.
- The watchdog reacts to the accessible button descriptions `恢復目標`, `恢复目标`, and `Resume goal`.
- ChatGPT must be running and the relevant button must be present in the current conversation.
- UI or accessibility changes in ChatGPT may require a watchdog update.
- This is an independent community project and is not affiliated with or endorsed by OpenAI.

## Project documents

- [Privacy](PRIVACY.md)
- [Security policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Release process](RELEASING.md)

## Release status and license

Releases are source-only unless the project later adopts Developer ID signing and Apple notarization. Automatic updates are intentionally out of scope.

An open-source license has not been selected yet. Until a license file is added, the source remains copyright-protected and the repository must not be described as open source.
