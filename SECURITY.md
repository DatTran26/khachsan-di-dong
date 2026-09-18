# Security policy

## Supported versions

Track supported lines in GitHub Releases. Until the first app ship, treat `main` as the only supported line.

## Report a vulnerability

- Prefer GitHub **Private vulnerability reporting** on this repository (Security tab) when enabled.
- Do not open a public issue for an unpatched vulnerability.
- Do not commit secrets, tokens, private keys, or `.env` files.
- Include: impact, affected branch/tag, reproduction, and a suggested fix if you have one.

## Project defaults

- Secret scanning and push protection are enabled when the GitHub plan allows.
- Dependabot updates GitHub Actions weekly.
- Personal branches PR into `develop`, never into `main`.
