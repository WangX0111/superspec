# Changelog

All notable changes to the Superpowers Bridge extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-05-30

### Changed

- **Catalog namespace alignment** (BREAKING for command names):
  - `extension.id` renamed from `superpowers` to `superspec` (matches repository
    name and the catalog id required by spec-kit's registry validator).
  - All command names migrated:
    `/speckit.superpowers.{status,brainstorm,tasks,execute,review}` →
    `/speckit.superspec.{status,brainstorm,tasks,execute,review}`.
  - All three lifecycle hooks (`after_tasks`, `before_implement`, `after_implement`)
    now point to the new `speckit.superspec.*` commands.
  - README catalog install command updated to `specify extension add superspec`.

### Fixed

- v1.0.0 could not be installed via `specify extension add superpowers-bridge`
  due to a mismatch between the catalog id and the command namespace
  (`Validation Error: Command 'speckit.superpowers.status' must use extension
  namespace 'superpowers-bridge'`). v1.0.1 fixes this by aligning the
  namespace with the (renamed) catalog id.

### CI / Tooling

- `scripts/validate-extension-metadata.py` rewritten to derive the expected
  namespace dynamically from `extension.yml`'s `id`, so future namespace/slug
  drift fails CI before reaching the catalog. New checks:
  - every `commands[].name` and every `hooks[].command` must start with
    `speckit.<extension.id>.`;
  - the README catalog install command's slug must equal `extension.id`;
  - docs must not retain legacy `speckit.superpowers.*` references.

## [1.0.0] - 2026-04-22

### Added

- Extension manifest (`extension.yml`) for spec-kit extension registry
- 5 superpowers-bridge commands: status, brainstorm, tasks, execute, review
- 3 lifecycle hooks: after-tasks, before-execute, after-execute
- 5 enhanced templates: constitution, spec, plan, tasks, checklist
- Session resumability via `progress.yml` and `superpowers.yml`
- Superpowers detection with graceful fallback when skills not installed
- Built-in brainstorming protocol (5 categories) as fallback for superpowers
- Built-in code review checklist as fallback for requesting-code-review
- TDD/REVIEW/SUBAGENT execution markers in task templates
- Bilingual documentation (English + Chinese)
- Architecture diagrams for both EN and CN
- Reference documentation: workflow guide and superpowers bridge
- End-to-end sample workflow example
