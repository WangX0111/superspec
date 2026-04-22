# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: Fill in the right edge cases for this feature.
  Use the brainstorm prompts below as conversation starters for /superspec.brainstorm.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

#### Brainstorm Prompts

<!--
  These prompts guide the /superspec.brainstorm command. They serve as starting points
  for deep-dive questioning sessions. Add domain-specific prompts as needed.
-->

- **Boundary conditions**: What are the minimum and maximum valid inputs? What happens at the edges?
- **Error scenarios**: What if the network is down? What if the database is unavailable? What if input is malformed?
- **Scale**: What happens with 10x or 100x expected load? Are there rate limits to consider?
- **Security**: Can this feature be abused? Are there injection vectors? What about unauthorized access?
- **User confusion**: Where might users misunderstand the feature? What if they use it in an unintended way?
- **Data integrity**: What happens during concurrent modifications? What about partial failures?
- **Backwards compatibility**: Does this break existing behavior? How do we handle migration?

## Open Questions

<!--
  This section tracks unresolved questions discovered during brainstorming.
  Each question has a status (Open/Resolved) and a resolution summary.
  /superspec.brainstorm updates this section as questions are explored.
-->

| # | Question | Status | Resolution |
|---|----------|--------|------------|
| Q1 | [Question discovered during brainstorming] | Open | — |
| Q2 | [Another question] | Resolved | [How it was resolved] |

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific capability]
- **FR-002**: System MUST [specific capability]
- **FR-003**: Users MUST be able to [key interaction]
- **FR-004**: System MUST [data requirement]
- **FR-005**: System MUST [behavior]

*Mark unclear requirements explicitly:*

- **FR-006**: System MUST [capability] [NEEDS CLARIFICATION: reason]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete task in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users"]
- **SC-003**: [User satisfaction metric]
- **SC-004**: [Business metric]

## Assumptions

- [Assumption about target users]
- [Assumption about scope boundaries]
- [Assumption about data/environment]
- [Dependency on existing system/service]

## Brainstorm Log

<!--
  This section records insights from /superspec.brainstorm sessions.
  Each entry is dated and summarizes what was discovered and decided.
  Do not edit manually — this is maintained by the brainstorm command.
-->

<!-- Example entry:
### Session 2026-04-22
**Focus**: Edge cases in authentication flow
**Key insights**:
- Discovered need for rate limiting on login attempts
- Clarified token expiration strategy: 24h access + 30d refresh
- Identified missing requirement: account lockout after 5 failed attempts
**Spec updates**: Added FR-006 (rate limiting), updated US1 acceptance scenarios
-->
