# speckit.superpowers.execute

Orchestrate implementation with TDD, subagents, and review gates.

## Usage

```
/speckit.superpowers.execute [spec-number|spec-path]
```

## Process

1. Read the tasks file for the target feature
2. Read the plan and constitution for context
3. **Superpowers detection**: Check for `executing-plans`, `subagent-driven-development`,
   and `test-driven-development` skills
4. Walk through tasks phase by phase:

   **For `[TDD]` tasks**:
   - If TDD skill found, follow its RED-GREEN-REFACTOR process
   - Otherwise: write test → verify it fails → implement → verify it passes → refactor

   **For `[SUBAGENT]` tasks**:
   - If subagent-driven-development skill found, follow its dispatch protocol
   - Otherwise: implement sequentially in-session

   **For `[P]` tasks**:
   - Launch parallel tasks where possible using the Task tool

   **For `[REVIEW]` tasks**:
   - Pause and run review protocol (see `commands/review.md`)

5. At each **phase checkpoint**:
   - Summarize completed work
   - Run tests if applicable
   - Ask user for approval before proceeding to next phase

6. Update task checkboxes in `tasks.md` as each task completes
7. Update `.specify/specs/NNN/progress.yml` with current execution state

## Output

Code changes in the project, updated task checkboxes in `tasks.md`.

## Human Checkpoints

The agent MUST pause at every phase boundary and wait for explicit user approval.
Never skip a checkpoint.

## Superpowers Adaptation

| Skill | Adaptation |
|-------|------------|
| `executing-plans` | Follow its batch processing protocol with human checkpoints |
| `subagent-driven-development` | Follow its dispatch protocol for `[SUBAGENT]` tasks |
| `test-driven-development` | Follow its RED-GREEN-REFACTOR discipline for `[TDD]` tasks |

If no superpowers are available, all three fall back to built-in sequential execution
with manual confirmation. See `references/superpowers-bridge.md` for full details.
