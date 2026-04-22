# [PROJECT_NAME] Constitution

## Core Principles

### [PRINCIPLE_1_NAME]
<!-- Example: I. Library-First -->
[PRINCIPLE_1_DESCRIPTION]
<!-- Example: Every feature starts as a standalone library; Libraries must be self-contained, independently testable, documented; Clear purpose required - no organizational-only libraries -->

### [PRINCIPLE_2_NAME]
<!-- Example: II. CLI Interface -->
[PRINCIPLE_2_DESCRIPTION]
<!-- Example: Every library exposes functionality via CLI; Text in/out protocol: stdin/args → stdout, errors → stderr; Support JSON + human-readable formats -->

### [PRINCIPLE_3_NAME]
<!-- Example: III. Test-First (NON-NEGOTIABLE) -->
[PRINCIPLE_3_DESCRIPTION]
<!-- Example: TDD mandatory: Tests written → User approved → Tests fail → Then implement; Red-Green-Refactor cycle strictly enforced -->

### [PRINCIPLE_4_NAME]
<!-- Example: IV. Integration Testing -->
[PRINCIPLE_4_DESCRIPTION]
<!-- Example: Focus areas requiring integration tests: New library contract tests, Contract changes, Inter-service communication, Shared schemas -->

### [PRINCIPLE_5_NAME]
<!-- Example: V. Observability, VI. Versioning & Breaking Changes, VII. Simplicity -->
[PRINCIPLE_5_DESCRIPTION]
<!-- Example: Text I/O ensures debuggability; Structured logging required; Or: MAJOR.MINOR.BUILD format; Or: Start simple, YAGNI principles -->

## Technology Stack

<!-- Document the project's core technology choices -->

| Layer | Technology | Purpose |
|-------|-----------|---------|
| [LAYER_1] | [TECHNOLOGY] | [PURPOSE] |
| [LAYER_2] | [TECHNOLOGY] | [PURPOSE] |

## Development Workflow

<!--
  This section anchors the project to the superspec pipeline.
  Adjust the steps below to reflect your team's actual process.
-->

This project follows **specification-driven development** using the superspec pipeline:

1. **Constitution** (`/superspec.constitution`): Establish and maintain these governance principles
2. **Specification** (`/superspec.specify`): Define feature requirements before any code is written
3. **Brainstorming** (`/superspec.brainstorm`): Challenge assumptions and discover edge cases
4. **Planning** (`/superspec.plan`): Design technical approach with constitution compliance check
5. **Task Decomposition** (`/superspec.tasks`): Break down into executable, trackable tasks
6. **Execution** (`/superspec.execute`): Implement with appropriate discipline (TDD, subagents)
7. **Review** (`/superspec.review`): Verify implementation against spec and constitution

### Workflow Rules

- No code is written before a spec is approved
- Every spec goes through at least one brainstorm session
- Implementation plans must pass a constitution compliance check
- Phase checkpoints require explicit human approval

## Quality Gates

<!--
  Define what review and testing gates apply to this project.
  These feed into the /superspec.review and /superspec.execute commands.
-->

### Testing Requirements

- [ ] **Unit tests**: [REQUIRED/OPTIONAL] — [coverage target or "none specified"]
- [ ] **Integration tests**: [REQUIRED/OPTIONAL] — [scope description]
- [ ] **Contract tests**: [REQUIRED/OPTIONAL] — [API boundary description]
- [ ] **TDD discipline**: [REQUIRED/OPTIONAL] — tasks marked `[TDD]` must follow RED-GREEN-REFACTOR

### Review Requirements

- [ ] **Code review**: [REQUIRED/OPTIONAL] — [who reviews, what criteria]
- [ ] **Spec compliance**: [REQUIRED/OPTIONAL] — verify all acceptance scenarios pass
- [ ] **Security review**: [REQUIRED/OPTIONAL] — [scope description]
- [ ] **Performance review**: [REQUIRED/OPTIONAL] — [benchmarks or targets]

### Deployment Gates

- [ ] All tests pass
- [ ] All review items resolved
- [ ] Constitution compliance verified
- [ ] [PROJECT-SPECIFIC GATE]

## Governance

This constitution is the highest governing document for all development activities.
Any amendment requires:

- Documented change rationale
- Updated related specs and plans
- Verification that core principles are not violated

**Version**: [CONSTITUTION_VERSION] | **Ratified**: [RATIFICATION_DATE] | **Last Amended**: [LAST_AMENDED_DATE]
