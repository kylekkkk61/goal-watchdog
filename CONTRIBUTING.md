# Contributing

Contributions should stay within the project's narrow purpose: safely resuming an interrupted Goal in the currently displayed ChatGPT conversation.

## Before submitting a change

1. Keep the implementation native and dependency-free unless a dependency is demonstrably necessary.
2. Do not add telemetry, network access, conversation storage, or screen capture.
3. Use English for code comments. Keep the English and Traditional Chinese READMEs aligned when changing shared content.
4. Run `./scripts/check.sh`.

For behavior changes, explain the user-visible problem, the smallest proposed solution, and how it was verified. Never include private ChatGPT content in issues, logs, screenshots, or test data.

## Commits and pull requests

- Keep each commit atomic and use an English [Conventional Commit](https://www.conventionalcommits.org/) subject.
- Keep each pull request focused on one coherent change and use a concise Conventional Commit title under 70 characters.
- Explain why the change is needed, its user impact, and how it was verified. Review the complete diff and exclude unrelated changes before submission.

This repository does not require a Contributor License Agreement. By submitting a contribution, you agree to provide it under the project's MIT License.
