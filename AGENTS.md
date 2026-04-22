# Repository Guidelines

## Project Structure & Module Organization
`templates/` contains the source of truth: one agent template per `*.role.json` file, for example `templates/sophie.role.json`. `scripts/` holds the repository automation: `validate-templates.ps1` validates template shape and dictionary usage, and `generate-index.ps1` rebuilds `index.json`. `jobTitle.json` is the shared job dictionary. `index.html` powers the GitHub Pages viewer. `.github/workflows/` runs validation, regenerates `index.json` on `main`, and deploys Pages.

## Build, Test, and Development Commands
Run validation before opening a PR:

```powershell
pwsh -File .\scripts\validate-templates.ps1
```

Regenerate the published index after changing `templates/` or `jobTitle.json`:

```powershell
pwsh -File .\scripts\generate-index.ps1
```

There is no separate build step. Treat `index.json` as generated output and do not hand-edit it.

## Coding Style & Naming Conventions
Use 2-space indentation in JSON files and keep keys stable unless the schema changes. Template files should use the `templates/<name>.role.json` pattern. Template `schema` must remain `openstaff.role-sync.v2`. `job` must match a `key` from `jobTitle.json`, whose entries are sorted by `key`. Keep `mcps` and `skills` as arrays of objects with a `key` field.

## Testing Guidelines
The validation script is the main test gate; there is no separate unit test suite in this repo. Any change to a template, `jobTitle.json`, or validation logic should pass `validate-templates.ps1`. If you modify templates or the job dictionary, regenerate `index.json` and confirm the diff is expected.

## Commit & Pull Request Guidelines
Follow the existing Conventional Commit style seen in history: `feat: ...`, `docs: ...`, `chore: ...`. Keep commits focused; generated `index.json` updates should accompany the source change that caused them. PRs should describe the changed templates or dictionary entries, note any schema or validation impact, and include a screenshot only when `index.html` or Pages output changes.

## Repository-Specific Notes
Do not add unsupported fields without updating `scripts/validate-templates.ps1`. Large base64 avatars are expected inside template JSON; avoid reformatting them unless necessary.
