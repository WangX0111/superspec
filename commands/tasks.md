# speckit.superpowers.tasks

Generate a phased task breakdown using writing-plans skills.

## Usage

```
/speckit.superpowers.tasks [spec-number|spec-path]
```

## Process

1. Read the spec, plan, and constitution for the target feature
2. Read the template at `.specify/templates/tasks-template.md`
3. **Superpowers detection**: Check for `writing-plans` skill
   - **If found**: Read the writing-plans SKILL.md and follow its task decomposition
     process, adapting outputs to the tasks template structure
   - **If not found**: Decompose directly from the plan using the template
4. Organize tasks by phase: Setup → Foundational → User Stories (by priority) → Polish
5. Apply execution markers to each task:
   - `[P]` — can run in parallel (different files, no dependencies)
   - `[TDD]` — must follow RED-GREEN-REFACTOR discipline
   - `[REVIEW]` — requires code review before proceeding
   - `[SUBAGENT]` — can be delegated to a subagent
6. Define phase dependencies and checkpoint gates
7. Write to `.specify/specs/NNN-feature-name/tasks.md`

## Output

`.specify/specs/NNN-feature-name/tasks.md` with phased task breakdown.

## Execution Markers

| Marker | Meaning | Behavior |
|--------|---------|----------|
| `[P]` | Parallel | Can run concurrently with other `[P]` tasks |
| `[TDD]` | Test-Driven | Must follow RED-GREEN-REFACTOR: write test → fail → implement → pass |
| `[REVIEW]` | Review Gate | Pause for human code review before proceeding |
| `[SUBAGENT]` | Subagent | Can be dispatched to a parallel subagent |

## Superpowers Adaptation

When using the `writing-plans` skill, adapt its outputs:
- Implementation blueprints → merge into `.specify/specs/NNN/tasks.md` using template structure
- Task dependencies → map to the Dependencies section
- Parallel opportunities → mark with `[P]` and `[SUBAGENT]`

See `references/superpowers-bridge.md` for full adaptation rules.
