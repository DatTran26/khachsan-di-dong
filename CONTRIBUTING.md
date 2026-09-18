# Contributing

- Default branch: `main` (production).
- Integration branch: `develop` (GitFlow).
- Work on `develop/<name>` or `developN`, then open a PR into `develop`.
- Do not push or PR personal branches into `main`.
- Cut `release/x.y.z` from `develop` when shipping. Hotfix from `main`.
- Do not commit `.env` or secrets.
- Commit messages: Conventional Commits (`ak:git` if present; else caveman-commit short subject).
- Releases: update `CHANGELOG.md` + `docs/releases/x.y.z.md`, merge `release/x.y.z` to `main`, then GitHub Release (`create-release.ps1` or `ak:ship official` + `gh release`).
