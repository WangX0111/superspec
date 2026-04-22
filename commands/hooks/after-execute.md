# Hook: after_execute

Runs after `/speckit.execute` completes a phase or the entire execution. Requires
evidence before completion claims are accepted.

## Checks

1. **Evidence verification**: For each completed task, verify that the expected output
   exists (tests pass, files created, etc.)
2. **Test results**: If tests were run, verify they pass
3. **Progress update**: Update `.specify/specs/NNN/progress.yml` with completed tasks
   and current phase status
4. **Review suggestion**: If all tasks in a phase are complete, suggest running
   `/speckit.superpowers.review` before proceeding to the next phase

## Gate

Cannot mark a task as complete without evidence. Cannot advance to the next phase
without explicit human approval at the checkpoint.
