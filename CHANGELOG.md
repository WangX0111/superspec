# Changelog

All notable changes to the Superpowers Bridge extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
