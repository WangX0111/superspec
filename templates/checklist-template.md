# [CHECKLIST TYPE] Checklist: [FEATURE NAME]

**Purpose**: [Brief description of what this checklist covers]
**Created**: [DATE]
**Feature**: [Link to spec.md or relevant documentation]

<!--
  ============================================================================
  IMPORTANT: The checklist items below are SAMPLE ITEMS for illustration only.

  The /superspec.checklist command MUST replace these with actual items based on:
  - User's specific checklist request
  - Feature requirements from spec.md
  - Technical context from plan.md
  - Implementation details from tasks.md

  DO NOT keep these sample items in the generated checklist file.
  ============================================================================
-->

## Spec Compliance

<!--
  Verify each acceptance scenario from the spec is implemented and passing.
  Generated from spec.md user stories and acceptance scenarios.
-->

- [ ] CHK001 US1 Scenario 1: [Given/When/Then from spec] — implemented and tested
- [ ] CHK002 US1 Scenario 2: [Given/When/Then from spec] — implemented and tested
- [ ] CHK003 US2 Scenario 1: [Given/When/Then from spec] — implemented and tested
- [ ] CHK004 Edge case: [Edge case from spec] — handled correctly

## Code Review

<!--
  Standard code quality checks applicable to most features.
  Adjust based on constitution quality gates.
-->

### Correctness

- [ ] CHK010 Logic is correct and handles all acceptance scenarios
- [ ] CHK011 Edge cases from brainstorming are handled
- [ ] CHK012 Error handling is comprehensive (no silent failures)
- [ ] CHK013 Data validation at system boundaries

### Security

- [ ] CHK020 No injection vulnerabilities (SQL, XSS, command injection)
- [ ] CHK021 Authentication and authorization checks in place
- [ ] CHK022 Sensitive data is not logged or exposed
- [ ] CHK023 Input sanitization at all entry points

### Performance

- [ ] CHK030 No N+1 queries or unnecessary database calls
- [ ] CHK031 Appropriate caching where beneficial
- [ ] CHK032 No blocking operations in critical paths
- [ ] CHK033 Resource cleanup (connections, file handles, etc.)

### Code Quality

- [ ] CHK040 Follows project conventions from constitution
- [ ] CHK041 Functions are focused and appropriately sized
- [ ] CHK042 No code duplication beyond acceptable thresholds
- [ ] CHK043 Naming is clear and consistent

## Constitution Compliance

<!--
  Verify each constitution principle is respected.
  Generated from .specify/memory/constitution.md principles.
-->

- [ ] CHK050 [Principle 1]: [Specific verification for this feature]
- [ ] CHK051 [Principle 2]: [Specific verification for this feature]
- [ ] CHK052 [Principle 3]: [Specific verification for this feature]

## Test Coverage

<!--
  Verify tests exist and pass for critical functionality.
-->

- [ ] CHK060 Unit tests cover core business logic
- [ ] CHK061 Integration tests cover user journeys
- [ ] CHK062 All tests pass in CI environment
- [ ] CHK063 [TDD] tasks followed RED-GREEN-REFACTOR discipline

## [Custom Category]

<!--
  Add domain-specific checklist categories as needed.
  Examples: Accessibility, Internationalization, Data Migration, API Compatibility
-->

- [ ] CHK070 [Custom checklist item]
- [ ] CHK071 [Custom checklist item]

## Notes

- Check items off as completed: `[x]`
- Add inline comments for findings or exceptions
- Link to relevant code, tests, or documentation
- Items are numbered sequentially (CHK###) for easy reference
- Report issues with confidence scores (0-100, only flag items >= 80 confidence)
