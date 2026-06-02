#!/usr/bin/env bash
# scripts/e2e-agent-claude.sh
#
# End-to-end AI-generation test for the superspec extension, driven by Claude
# Code in headless (-p) mode. This is the second of two e2e tests in this repo:
#
#   1. scripts/e2e-smoke.sh         — structural assertions, no LLM, ~60s
#   2. scripts/e2e-agent-claude.sh  — full agent-driven workflow, this file
#
# Goal
#   Drive a deterministic feature ("a static landing page for the superspec
#   project") through every stage of superspec's workflow, and assert at each
#   stage that the expected artifact + section structure was produced. This
#   tells us per-stage whether brainstorm / tasks / execute / review actually
#   work end-to-end (not just that they're registered).
#
# Pipeline
#   Stage 0  /speckit.constitution  → .specify/memory/constitution.md
#   Stage 1  /speckit.specify       → specs/001-.../spec.md
#   Stage 2  /speckit.superspec.brainstorm  (mutates spec.md, adds Edge Cases)
#   Stage 3  /speckit.plan          → specs/001-.../plan.md
#   Stage 4  /speckit.tasks         → specs/001-.../tasks.md
#                                     (after_tasks hook may invoke .superspec.tasks)
#   Stage 5  /speckit.superspec.execute   → web/index.html + progress updates
#   Stage 6  /speckit.superspec.review    → checklists/review.md
#
# Each stage is a separate `claude -p` invocation. After each, we assert
# (a) expected file exists, (b) certain section headings exist (contract
# markers, NOT prose). First failure stops the whole run.
#
# Environment
#   ANTHROPIC_API_KEY     required (unless E2E_DRY_RUN=1)
#   E2E_DRY_RUN=1         echo the prompts but don't call claude (free)
#   E2E_MAX_BUDGET_USD    per-stage budget cap, default 0.50
#   E2E_MAX_TURNS         per-stage turn cap, default 12
#   E2E_KEEP_WORKDIR=0    delete tmp project at the end (default: keep)
#
# Usage
#   ANTHROPIC_API_KEY=sk-ant-... bash scripts/e2e-agent-claude.sh
#   E2E_DRY_RUN=1            bash scripts/e2e-agent-claude.sh    # logic test only
#
# Exit code
#   0 if every stage's assertions pass, otherwise 1.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${E2E_DRY_RUN:-0}"
MAX_BUDGET="${E2E_MAX_BUDGET_USD:-0.50}"
MAX_TURNS="${E2E_MAX_TURNS:-30}"
KEEP_WORKDIR="${E2E_KEEP_WORKDIR:-1}"
# Resume support: skip prep + earlier stages by reusing an existing workdir.
#   E2E_RESUME_WORKDIR=/abs/path  reuse this workdir (skip prep stage)
#   E2E_RESUME_FROM=N             skip stages 1..N-1 (default: 1, run all)
RESUME_WORKDIR="${E2E_RESUME_WORKDIR:-}"
RESUME_FROM="${E2E_RESUME_FROM:-1}"

if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[33m'
  C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_RST=$'\033[0m'
else
  C_GREEN=""; C_RED=""; C_YELLOW=""; C_DIM=""; C_BOLD=""; C_RST=""
fi

# ---------- preflight ----------------------------------------------------
if [ "$DRY_RUN" != "1" ]; then
  if ! command -v claude >/dev/null 2>&1; then
    printf '%s✗%s claude CLI not in PATH. Install: npm i -g @anthropic-ai/claude-code\n' "$C_RED" "$C_RST"; exit 1
  fi
  # claude supports ANTHROPIC_API_KEY env var, OAuth (claude login -> keychain),
  # or apiKeyHelper. We don't enforce env var; claude itself will error out if
  # no auth is available. Only warn if neither env var is set and we're in CI.
  if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -n "${CI:-}" ]; then
    printf '%s✗%s ANTHROPIC_API_KEY not set in CI environment.\n' "$C_RED" "$C_RST"; exit 1
  fi
fi
if ! command -v uvx >/dev/null 2>&1; then
  printf '%s✗%s uvx not in PATH. Install uv: https://docs.astral.sh/uv/\n' "$C_RED" "$C_RST"; exit 1
fi

WORK=""
if [ -n "$RESUME_WORKDIR" ]; then
  if [ ! -d "$RESUME_WORKDIR" ]; then
    printf '%s✗%s E2E_RESUME_WORKDIR=%s does not exist.\n' "$C_RED" "$C_RST" "$RESUME_WORKDIR"; exit 1
  fi
  WORK="$RESUME_WORKDIR"
else
  WORK="$(mktemp -d -t superspec-agent.XXXXXX)"
fi
LOGS="$WORK/.logs"; mkdir -p "$LOGS"

cleanup() {
  if [ "$KEEP_WORKDIR" = "1" ]; then
    printf '\n%sworkdir kept:%s %s\n' "$C_DIM" "$C_RST" "$WORK"
  else
    rm -rf "$WORK"
  fi
}
trap cleanup EXIT

# ---------- output helpers ----------------------------------------------
PASS=0; FAIL=0; FAILED_STAGE=""
pass()  { printf '    %s✓%s %s\n'   "$C_GREEN" "$C_RST" "$1"; PASS=$((PASS+1)); }
miss()  { printf '    %s✗%s %s\n'   "$C_RED"   "$C_RST" "$1"; FAIL=$((FAIL+1)); }
note()  { printf '    %s•%s %s\n'   "$C_DIM"   "$C_RST" "$1"; }
title() { printf '\n%s[Stage %s]%s %s\n'   "$C_BOLD" "$1" "$C_RST" "$2"; }

skip()           { printf '    %s~%s %s %s(dry-run)%s\n' "$C_YELLOW" "$C_RST" "$1" "$C_DIM" "$C_RST"; }
assert_file()    { if [ "$DRY_RUN" = "1" ]; then skip "$1"; return 0; fi; [ -f "$2" ]   && pass "$1" || { miss "$1 (missing: ${2#$WORK/})"; return 1; }; }
assert_dir()     { if [ "$DRY_RUN" = "1" ]; then skip "$1"; return 0; fi; [ -d "$2" ]   && pass "$1" || { miss "$1 (missing: ${2#$WORK/})"; return 1; }; }
assert_no_path() { if [ "$DRY_RUN" = "1" ]; then skip "$1"; return 0; fi; [ ! -e "$2" ] && pass "$1" || { miss "$1 (unexpected: ${2#$WORK/})"; return 1; }; }
assert_grep() {
  local desc="$1" pattern="$2" file="$3"
  if [ "$DRY_RUN" = "1" ]; then skip "$desc"; return 0; fi
  if [ -f "$file" ] && grep -qE -- "$pattern" "$file"; then pass "$desc"
  else miss "$desc (pattern '$pattern' missing from ${file#$WORK/})"; return 1; fi
}

# ---------- agent driver -------------------------------------------------
# Args: <stage_id> <prompt>
# Side-effect: cwd must be $WORK so claude picks up .claude/ and .specify/.
run_claude() {
  local stage_id="$1"; shift
  local prompt="$1"
  local log="$LOGS/stage-$stage_id.log"

  if [ "$stage_id" -lt "$RESUME_FROM" ]; then
    note "SKIP claude call (resumed past stage $stage_id, reusing prior artifacts)"
    return 0
  fi

  if [ "$DRY_RUN" = "1" ]; then
    note "DRY_RUN: would call claude with prompt:"
    printf '%s        %s%s\n' "$C_DIM" "$prompt" "$C_RST" | head -c 400; echo
    : > "$log"
    return 0
  fi

  # --permission-mode acceptEdits  → no interactive prompt for file writes
  # --max-turns                    → cap agent loops
  # --max-budget-usd               → cap per-stage spend
  # --output-format text           → human-readable response (we don't parse it)
  # We rely on claude reading the project dir (.claude/, .specify/, AGENTS.md
  # auto-discovery) so it knows about the spec-kit + superspec slash commands.
  # Note: claude exits non-zero on max-turns or budget, but artifacts may have
  # already been written. We log a warning but don't abort here — the on-disk
  # assertions after this call are the source of truth for whether the stage
  # actually delivered.
  if claude -p \
        --permission-mode acceptEdits \
        --max-turns "$MAX_TURNS" \
        --max-budget-usd "$MAX_BUDGET" \
        --output-format text \
        "$prompt" >"$log" 2>&1; then
    note "claude transcript: ${log#$WORK/}"
  else
    local rc=$?
    note "claude exited non-zero (rc=$rc) — likely max-turns/budget. Checking artifacts."
    note "claude transcript: ${log#$WORK/}"
  fi
}

# ========================================================================
#  PREP: spec-kit init + install superspec from local checkout
# ========================================================================
if [ -n "$RESUME_WORKDIR" ]; then
  title 0 "prep — RESUMING from existing workdir"
  cd "$WORK"
  pass "reusing workdir: $WORK"
  note "skipping init/install (will reuse existing .specify/, .claude/, specs/)"
else
  title 0 "prep — init spec-kit + install superspec (--dev)"
  cd "$WORK"

  uvx --from git+https://github.com/github/spec-kit.git specify init \
      --here --offline --integration claude --ignore-agent-tools --no-git --force \
      </dev/null >"$LOGS/init.log" 2>&1 \
    || { miss "specify init failed (see $LOGS/init.log)"; tail -n 20 "$LOGS/init.log"; exit 1; }
  pass "specify init (--integration claude) succeeded"

  uvx --from git+https://github.com/github/spec-kit.git specify extension add "$REPO_ROOT" --dev \
      </dev/null >"$LOGS/add.log" 2>&1 \
    || { miss "specify extension add failed (see $LOGS/add.log)"; tail -n 20 "$LOGS/add.log"; exit 1; }
  pass "superspec installed --dev"
fi

assert_file ".specify/extensions.yml present" "$WORK/.specify/extensions.yml" || exit 1
[ -d "$WORK/.claude" ] && pass ".claude/ scaffolding present (slash commands discoverable)" \
                       || miss ".claude/ missing — agent won't see slash commands"

# Show what slash command files Claude will see (helps diagnose later)
note "slash commands visible to claude (.claude/skills/):"
find "$WORK/.claude" -type f \( -name '*.md' -o -name 'SKILL.md' \) 2>/dev/null \
  | sed "s|^$WORK/.claude/|        |" | sort | head -n 30 || true

# Critical: assert all 5 superspec commands are actually visible to claude.
# spec-kit compiles commands/X.md into SKILL.md with frontmatter, but in some
# install modes the compiled artifacts land under
#   .specify/extensions/<slug>/.specify-dev/agent-commands/claude/...
# instead of .claude/skills/, leaving them invisible to the agent.
DISTRIB_FAIL=0
for c in status brainstorm tasks execute review; do
  if [ -f "$WORK/.claude/skills/speckit-superspec-$c/SKILL.md" ]; then
    pass "  /speckit.superspec.$c is visible to claude"
  else
    miss "  /speckit.superspec.$c NOT in .claude/skills/ — agent cannot see it"
    DISTRIB_FAIL=1
  fi
done
if [ "$DISTRIB_FAIL" = "1" ]; then
  printf '\n%sDistribution gap detected.%s superspec SKILLs were compiled here:\n' "$C_YELLOW" "$C_RST"
  find "$WORK/.specify/extensions/superspec" -name 'SKILL.md' 2>/dev/null \
    | sed "s|^$WORK/|    |"
  printf '%sBut not symlinked/copied into .claude/skills/.%s\n' "$C_YELLOW" "$C_RST"
  printf 'Skipping agent stages — would yield meaningless results.\n'
  exit 1
fi

# ========================================================================
#  STAGE 1: /speckit.constitution
# ========================================================================
title 1 "/speckit.constitution — establish project principles"
LANDING_VISION='Static landing page for the superspec project.
Audience: developers evaluating spec-kit extensions.
Constraints: pure HTML+CSS, no build tooling, output goes to web/index.html.
Quality bars: semantic HTML, mobile-friendly, no external network deps at runtime.'

run_claude 1 "$(cat <<EOF
You are working in a fresh spec-kit project. Use the slash command
/speckit.constitution to establish a constitution for this project.

Project intent:
$LANDING_VISION

Run /speckit.constitution and produce .specify/memory/constitution.md with at
least these sections: ## Core Principles, ## Quality Standards, ## Constraints.
Then stop.
EOF
)" || { FAILED_STAGE=1; }

if [ -z "$FAILED_STAGE" ]; then
  assert_file ".specify/memory/constitution.md exists" "$WORK/.specify/memory/constitution.md"           || FAILED_STAGE=1
  assert_grep "  has ## Core Principles section"        '^#{2,4}[[:space:]]+Core Principles' "$WORK/.specify/memory/constitution.md" || FAILED_STAGE=1
fi
[ -n "$FAILED_STAGE" ] && { printf '\n%sStopped at Stage %s%s\n' "$C_RED" "$FAILED_STAGE" "$C_RST"; exit 1; }

# ========================================================================
#  STAGE 2: /speckit.specify
# ========================================================================
title 2 "/speckit.specify — write the feature spec"
run_claude 2 "$(cat <<EOF
Use the slash command /speckit.specify with this feature description:

"Static landing page for superspec. Three priorities:
 P1: Hero section with project name, tagline, and a 'Get Started' button.
 P2: Features grid showing the 5 core commands (status, brainstorm, tasks, execute, review).
 P3: Workflow diagram and an install command snippet.
 Output target: web/index.html, pure HTML+CSS, no JavaScript build."

Run /speckit.specify, ensure spec.md is created under specs/<NNN>-<slug>/spec.md
at the project ROOT (not under .specify/), and that it contains user scenarios
labeled P1, P2, P3. Then stop.
EOF
)" || FAILED_STAGE=2

# Locate the spec dir (slug is agent-chosen, so glob it)
SPEC_DIR=""
if [ "$DRY_RUN" = "1" ]; then
  SPEC_DIR="$WORK/specs/001-dry-run-placeholder"
  skip "spec dir at project root"
elif [ -z "$FAILED_STAGE" ]; then
  SPEC_DIR="$(ls -d "$WORK"/specs/[0-9][0-9][0-9]-* 2>/dev/null | head -n1 || true)"
  if [ -n "$SPEC_DIR" ]; then
    pass "spec dir at project root: ${SPEC_DIR#$WORK/}"
  else
    miss "no specs/NNN-*/ directory found at project root"
    FAILED_STAGE=2
  fi
fi
if [ -z "$FAILED_STAGE" ]; then
  assert_file "  spec.md exists"       "$SPEC_DIR/spec.md"              || FAILED_STAGE=2
  # issue #4 anti-regression: spec must be at root specs/, not under .specify/
  assert_no_path "  no .specify/specs/ leak (issue #4)" "$WORK/.specify/specs"  || FAILED_STAGE=2
  assert_grep "  spec.md mentions P1/P2/P3" '\b(P1|P2|P3)\b' "$SPEC_DIR/spec.md" || FAILED_STAGE=2
fi
[ -n "$FAILED_STAGE" ] && { printf '\n%sStopped at Stage %s%s\n' "$C_RED" "$FAILED_STAGE" "$C_RST"; exit 1; }

# ========================================================================
#  STAGE 3: /speckit.superspec.brainstorm — superspec-specific
# ========================================================================
title 3 "/speckit.superspec.brainstorm — deep-dive edge cases"
SPEC_REL="${SPEC_DIR#$WORK/}/spec.md"
if [ "$DRY_RUN" = "1" ]; then
  SPEC_BEFORE_HASH="placeholder"
else
  SPEC_BEFORE_HASH="$(shasum "$SPEC_DIR/spec.md" 2>/dev/null | awk '{print $1}')"
fi

run_claude 3 "$(cat <<EOF
Use the superspec slash command /speckit.superspec.brainstorm against the
existing spec at $SPEC_REL.

Per the superspec contract, brainstorm should mutate the spec file IN PLACE
and add (or expand) at minimum:
  - an "## Edge Cases" section
  - an "## Open Questions" or "## Assumptions" section

Run /speckit.superspec.brainstorm $SPEC_REL and stop when the spec file has
been updated.
EOF
)" || FAILED_STAGE=3

if [ "$DRY_RUN" = "1" ]; then
  skip "spec.md was modified in place"
elif [ 3 -lt "$RESUME_FROM" ]; then
  skip "spec.md was modified in place"
elif [ -z "$FAILED_STAGE" ]; then
  SPEC_AFTER_HASH="$(shasum "$SPEC_DIR/spec.md" | awk '{print $1}')"
  if [ "$SPEC_BEFORE_HASH" != "$SPEC_AFTER_HASH" ]; then
    pass "spec.md was modified in place"
  else
    miss "spec.md content unchanged after brainstorm"
    FAILED_STAGE=3
  fi
  assert_grep "  ## Edge Cases section added" '^#{2,4}[[:space:]]+Edge Cases'           "$SPEC_DIR/spec.md" || FAILED_STAGE=3
  assert_grep "  ## Open Questions or Assumptions added" '^#{2,4}[[:space:]]+(Open Questions|Assumptions)' "$SPEC_DIR/spec.md" || FAILED_STAGE=3
fi
[ -n "$FAILED_STAGE" ] && { printf '\n%sStopped at Stage %s%s\n' "$C_RED" "$FAILED_STAGE" "$C_RST"; exit 1; }

# ========================================================================
#  STAGE 4: /speckit.plan
# ========================================================================
title 4 "/speckit.plan — technical implementation plan"
run_claude 4 "$(cat <<EOF
Run /speckit.plan to produce a technical implementation plan for the spec at
$SPEC_REL. The plan should be written to ${SPEC_DIR#$WORK/}/plan.md with
sections covering technical approach, file structure, and any risks.
EOF
)" || FAILED_STAGE=4

if [ -z "$FAILED_STAGE" ]; then
  assert_file "plan.md exists at ${SPEC_DIR#$WORK/}/plan.md" "$SPEC_DIR/plan.md" || FAILED_STAGE=4
fi
[ -n "$FAILED_STAGE" ] && { printf '\n%sStopped at Stage %s%s\n' "$C_RED" "$FAILED_STAGE" "$C_RST"; exit 1; }

# ========================================================================
#  STAGE 5: /speckit.tasks (may trigger superspec.tasks via after_tasks hook)
# ========================================================================
title 5 "/speckit.tasks — phased task breakdown"
run_claude 5 "$(cat <<EOF
Run /speckit.tasks to produce a phased task breakdown for the plan at
${SPEC_DIR#$WORK/}/plan.md. Tasks should be written to
${SPEC_DIR#$WORK/}/tasks.md with phase markers and ID-style task numbers
(e.g. T001, T002, ...). If the after_tasks hook prompts you to also run
/speckit.superspec.tasks, accept and run it.
EOF
)" || FAILED_STAGE=5

if [ -z "$FAILED_STAGE" ]; then
  assert_file "tasks.md exists" "$SPEC_DIR/tasks.md" || FAILED_STAGE=5
  assert_grep "  contains T001-style task IDs" '\bT[0-9]{3}\b' "$SPEC_DIR/tasks.md" || FAILED_STAGE=5
fi
[ -n "$FAILED_STAGE" ] && { printf '\n%sStopped at Stage %s%s\n' "$C_RED" "$FAILED_STAGE" "$C_RST"; exit 1; }

# ========================================================================
#  STAGE 6: /speckit.superspec.execute — actually build web/index.html
# ========================================================================
title 6 "/speckit.superspec.execute — implement"
run_claude 6 "$(cat <<EOF
Run /speckit.superspec.execute to implement the tasks in
${SPEC_DIR#$WORK/}/tasks.md. The deliverable is a static landing page at
web/index.html (pure HTML+CSS, no JS build tooling). Per the superspec
contract, also keep ${SPEC_DIR#$WORK/}/progress.yml updated as tasks complete.
EOF
)" || FAILED_STAGE=6

if [ -z "$FAILED_STAGE" ]; then
  assert_file "web/index.html generated"        "$WORK/web/index.html"      || FAILED_STAGE=6
  assert_grep "  index.html has <html>"        '<html'                     "$WORK/web/index.html" || FAILED_STAGE=6
  assert_grep "  index.html mentions superspec" 'superspec'                "$WORK/web/index.html" || FAILED_STAGE=6
  if [ -f "$SPEC_DIR/progress.yml" ]; then
    pass "progress.yml exists at ${SPEC_DIR#$WORK/}/progress.yml"
  else
    note "progress.yml not produced (soft signal — superspec contract suggests it)"
  fi
fi
[ -n "$FAILED_STAGE" ] && { printf '\n%sStopped at Stage %s%s\n' "$C_RED" "$FAILED_STAGE" "$C_RST"; exit 1; }

# ========================================================================
#  STAGE 7: /speckit.superspec.review
# ========================================================================
title 7 "/speckit.superspec.review — review against spec"
run_claude 7 "$(cat <<EOF
Run /speckit.superspec.review to review the implementation under web/ against
the spec/plan/tasks at ${SPEC_DIR#$WORK/}. Per the superspec contract, write
the review output to ${SPEC_DIR#$WORK/}/checklists/review.md as a checklist.
EOF
)" || FAILED_STAGE=7

if [ -z "$FAILED_STAGE" ]; then
  assert_file "review.md exists" "$SPEC_DIR/checklists/review.md" || FAILED_STAGE=7
  assert_grep "  review.md is a checklist" '\[[ xX]\]' "$SPEC_DIR/checklists/review.md" || FAILED_STAGE=7
fi
[ -n "$FAILED_STAGE" ] && { printf '\n%sStopped at Stage %s%s\n' "$C_RED" "$FAILED_STAGE" "$C_RST"; exit 1; }

# ========================================================================
#  Summary
# ========================================================================
printf '\n%sSummary%s — %d assertions passed across 7 stages\n' "$C_BOLD" "$C_RST" "$PASS"
echo
echo "Final artifacts under workdir:"
find "$WORK" -type f \
  \( -path '*/specs/*' -o -path '*/web/*' -o -path '*/.specify/memory/*' -o -name 'AGENTS.md' -o -name 'CLAUDE.md' \) \
  -not -path '*/.git/*' \
  | sed "s|^$WORK/|    |" | sort

if [ "$DRY_RUN" = "1" ]; then
  printf '\n%sDRY_RUN complete.%s All real assertions skipped.\n' "$C_YELLOW" "$C_RST"
  printf 'Set ANTHROPIC_API_KEY and re-run without E2E_DRY_RUN=1 to execute the agent stages.\n'
  exit 0
fi
[ "$FAIL" -gt 0 ] && exit 1
exit 0
