# Hook: after_tasks

Runs after `/speckit.tasks` completes. Verifies the task plan covers the specification
and checks if superpowers skills can enhance the task breakdown.

## Checks

1. **Coverage verification**: Ensure every user story from the spec has corresponding tasks
2. **Superpowers enhancement**: If `writing-plans` skill is detected, suggest re-running
   `/speckit.superpowers.tasks` for enhanced decomposition
3. **TDD readiness**: If constitution requires TDD, verify `[TDD]` markers are present
   on appropriate tasks
4. **Review gates**: If constitution requires code review, verify `[REVIEW]` markers
   are present on appropriate tasks

## Output

Warnings printed to user if any checks fail. No files modified.
