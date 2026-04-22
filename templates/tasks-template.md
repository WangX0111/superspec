---
description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `.specify/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

## Task Format

```
[ID] [markers] [Story] Description
```

**Markers**:
- **[P]**: Can run in parallel (different files, no dependencies)
- **[TDD]**: Must follow RED-GREEN-REFACTOR (write test → fail → implement → pass → refactor)
- **[REVIEW]**: Requires code review before proceeding to next task
- **[SUBAGENT]**: Can be delegated to a subagent for parallel execution

**Story labels**: `[US1]`, `[US2]`, etc. map tasks to user stories for traceability.

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Adjust paths based on plan.md structure decisions

<!--
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.

  The /superspec.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Technical decisions from plan.md
  - Execution strategy from plan.md (TDD, parallel, review gates)
  - Entities from spec.md

  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment

  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize project with dependencies
- [ ] T003 [P] Configure linting and formatting tools

**Execution notes**: No special discipline required. Verify project builds before proceeding.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story

**CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T004 [TDD] Setup core data models/entities
- [ ] T005 [P] Implement shared utilities
- [ ] T006 [P] [REVIEW] Setup API routing and middleware
- [ ] T007 Configure error handling and logging infrastructure

**Execution notes**: Tasks marked [TDD] — write tests first, verify they fail, then implement.
Tasks marked [REVIEW] — pause for human review of API contracts before consumers are built.

**Checkpoint**: Foundation ready. Get human approval before starting user stories.

---

## Phase 3: User Story 1 - [Title] (Priority: P1) MVP

**Goal**: [Brief description of what this story delivers]
**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (if TDD applies)

> Write these tests FIRST. Verify they FAIL before implementation.

- [ ] T008 [P] [TDD] [US1] Contract test for [endpoint] in tests/contract/
- [ ] T009 [P] [TDD] [US1] Integration test for [user journey] in tests/integration/

### Implementation for User Story 1

- [ ] T010 [P] [US1] Create [Entity1] model in src/models/
- [ ] T011 [P] [US1] Create [Entity2] model in src/models/
- [ ] T012 [US1] Implement [Service] in src/services/ (depends on T010, T011)
- [ ] T013 [US1] Implement [endpoint/feature] in src/
- [ ] T014 [US1] [REVIEW] Add validation and error handling

**Execution notes**: If `subagent-driven-development` is available, T010 and T011 can be
dispatched as parallel subagents. T014 requires review before proceeding.

**Checkpoint**: User Story 1 fully functional and testable. Get human approval.

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description]
**Independent Test**: [How to verify]

### Implementation for User Story 2

- [ ] T015 [P] [SUBAGENT] [US2] Create [Entity] model
- [ ] T016 [US2] Implement [Service]
- [ ] T017 [US2] Implement [endpoint/feature]
- [ ] T018 [US2] Integrate with User Story 1 components (if needed)

**Checkpoint**: User Stories 1 AND 2 both work independently. Get human approval.

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] [SUBAGENT] Documentation updates
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX [P] Performance optimization
- [ ] TXXX [REVIEW] Security hardening
- [ ] TXXX Run full test suite — all tests must pass

**Execution notes**: Polish phase tasks can largely run in parallel. Final security
hardening requires review. All tests must pass before this phase is considered complete.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational completion
  - Stories can proceed in parallel (if using subagents) or sequentially by priority
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### Within Each User Story

1. Tests (if [TDD]) MUST be written and FAIL before implementation
2. Models before services
3. Services before endpoints
4. Core implementation before integration
5. [REVIEW] tasks pause for human review
6. Story complete before moving to next priority

### Parallel Opportunities

- All tasks marked [P] within the same phase can run in parallel
- All tasks marked [SUBAGENT] can be dispatched to subagents
- Once Foundational phase completes, user stories can start in parallel
- Different user stories can be worked on by different subagents

---

## Superpowers Execution

<!--
  This section documents how /superspec.execute should process this task list.
  The execute command reads these instructions to determine execution behavior.
-->

### Execution Discipline by Marker

- **[TDD]**: Follow RED-GREEN-REFACTOR. If `test-driven-development` skill is available,
  read and follow its process. Otherwise: write test → run (must fail) → implement →
  run (must pass) → refactor if needed.
- **[SUBAGENT]**: If `subagent-driven-development` skill is available, dispatch to a
  subagent. Otherwise: implement sequentially in the current session.
- **[REVIEW]**: Pause execution. Present completed work to user. Wait for explicit
  approval before continuing.
- **[P]**: Launch parallel tasks where possible using the Task tool.

### Checkpoint Protocol

At every phase boundary:
1. Summarize what was completed in this phase
2. Run applicable tests
3. Report test results
4. Ask user: "Phase [N] complete. Proceed to Phase [N+1]?"
5. Only continue after explicit user approval

---

## Notes

- [P] tasks = different files, no dependencies
- [TDD] tasks = strict RED-GREEN-REFACTOR discipline
- [REVIEW] tasks = human review gate
- [SUBAGENT] tasks = candidate for parallel subagent dispatch
- [Story] label maps task to specific user story for traceability
- Commit after each task or logical group
- Stop at any checkpoint to validate independently
