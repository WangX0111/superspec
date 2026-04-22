# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link to spec.md]
**Input**: Feature specification from `.specify/specs/[###-feature-name]/spec.md`

## Summary

[Extract from feature spec: primary requirement + technical approach]

## Technical Context

<!--
  ACTION REQUIRED: Replace placeholders with actual technical details.
  Mark unknown items as NEEDS CLARIFICATION.
-->

**Language/Version**: [e.g., Python 3.11, TypeScript 5.x, Rust 1.75 or NEEDS CLARIFICATION]
**Primary Dependencies**: [e.g., FastAPI, React, Express or NEEDS CLARIFICATION]
**Storage**: [if applicable, e.g., PostgreSQL, localStorage, files or N/A]
**Testing**: [e.g., pytest, vitest, cargo test or NEEDS CLARIFICATION]
**Target Platform**: [e.g., Linux server, iOS 15+, mobile-first H5 or NEEDS CLARIFICATION]
**Project Type**: [e.g., library/cli/web-service/mobile-app or NEEDS CLARIFICATION]
**Performance Goals**: [domain-specific targets or NEEDS CLARIFICATION]
**Constraints**: [domain-specific constraints or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before proceeding. Re-check after design phase.*

<!--
  Verify each constitution principle is respected by this plan.
  Mark each as PASS, NEEDS ATTENTION, or VIOLATION (with justification).
-->

| Principle | Status | Notes |
|-----------|--------|-------|
| [Principle 1 from constitution] | PASS / NEEDS ATTENTION / VIOLATION | [explanation] |
| [Principle 2 from constitution] | PASS / NEEDS ATTENTION / VIOLATION | [explanation] |

## Project Structure

### Documentation (this feature)

```text
.specify/specs/[###-feature]/
├── spec.md              # Feature specification
├── plan.md              # This file
├── tasks.md             # Task breakdown (/superspec.tasks output)
└── checklist-*.md       # Generated checklists
```

### Source Code (repository root)

<!--
  ACTION REQUIRED: Replace with the concrete layout for this feature.
  Delete unused options and expand with real paths.
-->

```text
src/
├── models/
├── services/
└── [feature-specific]/

tests/
├── unit/
├── integration/
└── contract/
```

**Structure Decision**: [Document the selected structure and rationale]

## Execution Strategy

<!--
  This section identifies HOW tasks should be executed, feeding into /superspec.tasks
  and /superspec.execute commands.
-->

### TDD Requirements

<!--
  Which areas of this feature require strict RED-GREEN-REFACTOR discipline?
  Tasks for these areas will be marked [TDD] in the task breakdown.
-->

- [ ] [Component/module]: [Why TDD is needed — e.g., "Complex business logic with many edge cases"]
- [ ] [Component/module]: [Why TDD is needed]

### Parallel Execution Opportunities

<!--
  Which work streams are independent and can be dispatched to parallel subagents?
  Tasks for these areas will be marked [SUBAGENT] in the task breakdown.
-->

- [ ] [Work stream A] and [Work stream B] have no shared files or dependencies
- [ ] [Work stream C] can proceed independently after [prerequisite]

### Human Checkpoints

<!--
  Define explicit gates where the agent must pause and get human approval.
  These become phase boundaries in the task breakdown.
-->

1. After foundational setup — verify project structure and dependencies are correct
2. After each user story — verify behavior matches acceptance scenarios
3. After all stories — run full test suite before polish phase
4. Before merge — final review against spec

### Review Gates

<!--
  Which tasks require code review before proceeding?
  Tasks for these areas will be marked [REVIEW] in the task breakdown.
-->

- [ ] [API contracts/interfaces]: Review before implementing consumers
- [ ] [Security-sensitive code]: Review before integration
- [ ] [Data model changes]: Review before migration

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., extra dependency] | [current need] | [why simpler approach insufficient] |
