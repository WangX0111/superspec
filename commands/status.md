# speckit.superpowers.status

Show current project progress, feature status, and superpowers detection results.

## Usage

```
/speckit.superpowers.status [spec-number|all]
```

## Process

1. Scan `.specify/` directory structure
2. Check if `constitution.md` exists
3. **Run superpowers detection**: Check for all superpowers skills at
   `.agents/skills/` and `~/.agents/skills/`. Update `.specify/superpowers.yml`
   with current detection results.
4. For each spec directory, read `progress.yml` (or infer progress from existing files)
5. Display a status summary:

```
Superspec Project Status
========================
Constitution: Done (2026-04-22)
Superpowers:  brainstorming (detected), writing-plans (not found)

Features:
  001-user-auth    [####------] execute (Phase 5/6) — T012/T019 tasks done
  002-photo-upload [##--------] brainstorm (Phase 2/6) — 2 open questions
  003-settings     [#---------] specify (Phase 1/6) — draft

Suggested next step: /speckit.superpowers.execute 001
```

6. If no `.specify/` exists, suggest: "No superspec project found. Run
   `/speckit.constitution` to get started."

## File Inference Fallback

If `progress.yml` does not exist, infer progress from which files are present:
- `spec.md` exists → specify is done
- `spec.md` has Brainstorm Log entries → brainstorm was run
- `plan.md` exists → plan is done
- `tasks.md` exists → tasks are done
- `tasks.md` has `[x]` checkboxes → execute is in progress (count checked vs total)

## Superpowers Detection

Check for skills at these paths:
1. `.agents/skills/{skill-name}/SKILL.md` (project-local)
2. `~/.agents/skills/{skill-name}/SKILL.md` (user-global)

Results are persisted to `.specify/superpowers.yml`. See `references/superpowers-bridge.md`
for full detection and adaptation details.
