# speckit.superpowers.brainstorm

Deep-dive edge cases and refine a spec document using brainstorming skills.

## Usage

```
/speckit.superpowers.brainstorm [spec-path] [focus-topic]
```

**Example**: `/speckit.superpowers.brainstorm specs/001-develop/spec.md "Discuss the Edge Cases in the requirements document and confirm how to resolve these scenarios."`

## Process

1. Read the target spec file
2. Read the constitution for project constraints
3. **Superpowers detection**: Check for `brainstorming` skill
   - **If found**: Read the brainstorming SKILL.md and follow its questioning protocol,
     adapting all outputs to the target spec file
   - **If not found**: Use the built-in 5-category questioning protocol:
     - Boundary conditions (min/max, empty states, edge-of-range)
     - Error scenarios (service down, malformed input, partial failures)
     - Scale & performance (load, concurrency, rate limits)
     - Security & privacy (injection, authorization, data exposure)
     - User experience (confusion points, accessibility, unintended usage)
4. Ask questions **one at a time**, preferring multiple choice format
5. After each answer, update the spec:
   - New requirements → add to Functional Requirements
   - Resolved questions → update Open Questions table
   - New edge cases → add to Edge Cases section
6. When the user confirms the spec is ready, update the "Brainstorm Log" with a
   dated summary of insights discovered

## Output

Updated spec file with refined edge cases, resolved open questions, and brainstorm log entries.

## Iteration

This command can be run multiple times on the same spec. Each session appends to the
brainstorm log and skips previously explored categories.

## Superpowers Adaptation

When using the `brainstorming` skill, adapt its outputs:
- Design documents → fold insights back into the existing `spec.md`
- Output location → write to `.specify/specs/NNN/spec.md` (not `docs/superpowers/`)

See `references/superpowers-bridge.md` for full adaptation rules.
