# Privacy

Goal Watchdog runs entirely on the local Mac.

It uses macOS Accessibility APIs to inspect the current ChatGPT main window for a supported **Resume goal** button. When found, it temporarily activates ChatGPT and sends a mouse click to that button.

The watchdog:

- does not read or store goal or conversation text;
- does not capture screenshots;
- does not collect analytics, diagnostics, identifiers, or credentials;
- does not make network requests; and
- does not transmit data to the maintainer or any third party.

The app requires Accessibility and Automation permissions only for the behavior described above. Its source code is the authoritative description of its behavior.
