# Release Process

## Distribution policy

- Releases contain source code only.
- Do not attach an unnotarized `.app`, archive, installer, or automatic updater.
- Users build locally with `./scripts/build.sh` or run with `./scripts/run.sh`.
- GitHub private vulnerability reporting must remain enabled for public releases.

## Versioning

Use semantic version tags such as `v0.1.0`. Keep `CFBundleShortVersionString` aligned with the release version and increment `CFBundleVersion` for every release build.

## Release checklist

1. Confirm that the current ChatGPT version exposes a supported Resume goal accessibility description.
2. Run `./scripts/check.sh` locally and confirm that the GitHub Actions check passes on macOS 14.
3. Review tracked files and Git history for secrets, personal data, and private ChatGPT content.
4. Update `CFBundleShortVersionString` and `CFBundleVersion` in `Config/Info.plist`.
5. Create an annotated Git tag and a GitHub release with user-visible release notes.
6. Publish source code only and verify the private vulnerability reporting link in the **Security** tab.

Binary distribution requires a documented Developer ID owner, Apple notarization, artifact checksums, and a key-compromise response process.
