# Security Policy

## Supported versions

Only the latest source on the default branch is supported during the pre-release period.

## Reporting a vulnerability

Do not disclose a suspected vulnerability in a public issue. After the repository becomes public, use GitHub's private vulnerability reporting form in the repository's **Security** tab. The repository must remain private until that reporting channel is enabled.

Include the affected revision, macOS version, reproduction steps, and impact. Do not include private conversation content, credentials, or other sensitive data.

## Trust model

The project does not currently distribute signed and notarized binaries. Review the source and build it locally. The app's Accessibility permission allows it to inspect UI elements and post input events, so only run code from a revision you trust.
