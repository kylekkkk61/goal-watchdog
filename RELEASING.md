# Release Process

## Current policy

- Releases contain source code only.
- Do not attach an unnotarized `.app`, archive, installer, or automatic updater.
- Users build locally with `./scripts/build.sh` or run with `./scripts/run.sh`.
- The repository remains private until the public-readiness checklist below is complete and the owner explicitly changes its visibility.

## Public-readiness checklist

- [x] Select and add an open-source `LICENSE` file.
- [ ] Enable GitHub private vulnerability reporting immediately after making the repository public, then verify the link described in `SECURITY.md`.
- [x] Confirm the latest ChatGPT version still exposes a supported Resume goal accessibility description.
- [ ] Run `./scripts/check.sh` on the minimum supported macOS version and the current macOS version. CI covers macOS 14; the current macOS check is also required before tagging.
- [x] Review tracked files and Git history for secrets, personal data, and private ChatGPT content.
- [ ] Review the project name, app name, description, icon, topics, and screenshots against the current OpenAI brand guidelines; rename or obtain permission if required, and do not imply affiliation with OpenAI.
- [ ] Create a source-only version tag and GitHub release notes.
- [ ] Change repository visibility only as a separate, explicit final action.

## Versioning

Use semantic version tags such as `v0.1.0`. Before tagging, update both `CFBundleShortVersionString` and `CFBundleVersion` in `Config/Info.plist`, run all checks, and summarize user-visible changes in the GitHub release notes.

If signed downloadable binaries are introduced later, define Developer ID ownership, notarization, artifact checksums, and key-compromise handling before the first binary release.
