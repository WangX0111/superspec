# Hook: before_execute

Runs before `/speckit.execute` starts. Enforces TDD discipline and verifies prerequisites.

## Checks

1. **Prerequisites**: Verify `tasks.md`, `plan.md`, and `spec.md` all exist
2. **TDD enforcement**: If constitution requires TDD and any `[TDD]` task exists,
   enforce RED-GREEN-REFACTOR discipline for those tasks
3. **Superpowers detection**: Check for `executing-plans`, `subagent-driven-development`,
   and `test-driven-development` skills; update `.specify/superpowers.yml`
4. **Progress state**: Read `progress.yml` to determine resume point (if any)

## Gate

If any prerequisite is missing, abort with guidance on which command to run first.
