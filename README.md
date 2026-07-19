<p align="center">
  <img src="Resources/ReadmeBanner.png" alt="Goal Watchdog" width="1080">
</p>

<p align="center">
  <strong>English</strong> · <a href="README.zh-TW.md">繁體中文</a>
</p>

Goal Watchdog is a lightweight macOS menu bar utility that watches the conversation currently displayed in the ChatGPT desktop app. When Goal mode exposes a **Resume goal** button, Goal Watchdog clicks it and restores the previously active app and pointer position.

## Why Goal Watchdog?

Long-running goals can pause because of an unstable local connection, a false-positive safety review, or any other interruption. Goal Watchdog has one purpose: when ChatGPT offers **Resume goal**, click it so the goal can continue to completion; it does not bypass safeguards or controls that ChatGPT has not made available.

## Features

- Watches only the current ChatGPT main window.
- Locates the resume button dynamically through macOS Accessibility.
- Recognizes `Resume goal`, `恢復目標`, and `恢复目标`.
- The app can follow macOS or switch between English and Traditional Chinese from its menu; the CLI follows the preferred macOS language.
- Does not read goal text, capture the screen, store credentials, or use the network.
- Runs from Terminal or as a menu bar app without a Dock icon.

## Requirements

- macOS 14 or later
- The ChatGPT desktop app
- Xcode Command Line Tools (`xcode-select --install`)

## Run from Terminal

```sh
./scripts/run.sh
```

Goal Watchdog remains attached to the Terminal session. Press `Control-C` to stop it. The first run builds the app bundle; later runs rebuild only when an input file changes.

## Build the app

```sh
./scripts/build.sh
open "dist/Goal Watchdog.app"
```

The project distributes source code rather than downloadable app binaries. Local builds use an ad-hoc signature and are not notarized by Apple, so macOS may request Accessibility authorization again after a rebuild.

## Permissions

Goal Watchdog requires:

- **Accessibility** to inspect the current ChatGPT window and post a mouse click.
- **Automation → ChatGPT** to bring ChatGPT to the foreground before clicking.

If Accessibility remains unavailable after enabling it, remove the existing Goal Watchdog entry from **System Settings → Privacy & Security → Accessibility**, add the newly built app again, and relaunch Goal Watchdog. ChatGPT normally does not need to be restarted.

## Verify the project

```sh
./scripts/check.sh
```

The check builds the app, runs the button-language self-test, validates the property list and local signature, and confirms that the binary supports macOS 14.

## Limitations

- Only the conversation shown in ChatGPT's current main window is monitored.
- ChatGPT must be running, with a supported Resume goal button visible in the current conversation.
- Changes to ChatGPT's interface or Accessibility hierarchy may require a Goal Watchdog update.
- Goal Watchdog is an independent community project and is not affiliated with or endorsed by OpenAI.

## Project documents

- [Privacy](PRIVACY.md)
- [Security policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Release process](RELEASING.md)
- [MIT License](LICENSE)

## License

Goal Watchdog is available under the [MIT License](LICENSE).
