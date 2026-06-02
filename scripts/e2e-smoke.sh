#!/usr/bin/env bash
# scripts/e2e-smoke.sh
#
# End-to-end smoke test for the superspec extension.
#
# What it does (no LLM/agent required):
#   1. Initializes a fresh spec-kit project in a temp dir (offline + --no-git).
#   2. Installs THIS local checkout of superspec via `specify extension add --dev`.
#   3. Simulates `/speckit.specify` by directly invoking spec-kit's
#      `.specify/scripts/bash/create-new-feature.sh` (which is the same script
#      the agent calls). This proves the file system layout spec-kit really
#      produces — independent of which LLM is used.
#   4. Asserts everything spec-kit + superspec jointly promise:
#        - .specify/  contains memory/, templates/, scripts/, integrations/
#        - .specify/extensions.yml  registers all 5 superspec commands + 3 hooks
#        - specs/NNN-...  is at the project ROOT (NOT under .specify/)
#        - .specify/specs/  does NOT exist (catches the path drift in issue #4)
#        - superspec's own command/hook docs do not contradict the actual
#          spec-kit layout (i.e. they shouldn't reference `.specify/specs/`).
#   5. Prints a PASS/FAIL summary and a tree of artifacts that were generated,
#      so a human can eyeball the workdir and decide whether the repo is OK.
#
# Usage:
#   bash scripts/e2e-smoke.sh
#
# Exit code:
#   0 if every assertion passed; 1 otherwise.
#
# Tip:
#   The temp project is left behind on purpose so you can inspect it. The path
#   is printed at the end. Delete it manually when you're done (`rm -rf <path>`).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d -t superspec-e2e.XXXXXX)"
INIT_LOG="$WORK/.init.log"
ADD_LOG="$WORK/.add.log"
FEAT_LOG="$WORK/.feat.log"

if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_RST=$'\033[0m'
else
  C_GREEN=""; C_RED=""; C_DIM=""; C_BOLD=""; C_RST=""
fi

PASS=0
FAIL=0
FAILS=()

pass() { printf '  %s✓%s %s\n' "$C_GREEN" "$C_RST" "$1"; PASS=$((PASS+1)); }
fail() { printf '  %s✗%s %s\n' "$C_RED"   "$C_RST" "$1"; FAIL=$((FAIL+1)); FAILS+=("$1"); }
step() { printf '\n%s[%s]%s %s\n' "$C_BOLD" "$1" "$C_RST" "$2"; }

# Assertion helpers --------------------------------------------------------
assert_file()    { if [ -f "$2" ]; then pass "$1";   else fail "$1 (missing: $2)"; fi; }
assert_dir()     { if [ -d "$2" ]; then pass "$1";   else fail "$1 (missing: $2)"; fi; }
assert_no_dir()  { if [ ! -d "$2" ]; then pass "$1"; else fail "$1 (unexpected: $2)"; fi; }
assert_grep()    {
  local desc="$1" pattern="$2" file="$3"
  if [ -f "$file" ] && grep -q -- "$pattern" "$file"; then
    pass "$desc"
  else
    fail "$desc (pattern '$pattern' not found in $file)"
  fi
}

# -------------------------------------------------------------------------
step "1/5" "Initialize spec-kit in a fresh project"
cd "$WORK"
if ! uvx --from git+https://github.com/github/spec-kit.git specify init \
        --here --offline --integration codex --ignore-agent-tools --no-git --force \
        </dev/null >"$INIT_LOG" 2>&1; then
  fail "specify init exited non-zero (see $INIT_LOG)"
  echo "----- last 30 lines of init log -----"
  tail -n 30 "$INIT_LOG"
  exit 1
fi

assert_dir  ".specify/ created"                              "$WORK/.specify"
assert_file ".specify/memory/constitution.md present"        "$WORK/.specify/memory/constitution.md"
assert_file ".specify/templates/spec-template.md present"    "$WORK/.specify/templates/spec-template.md"
assert_file ".specify/templates/plan-template.md present"    "$WORK/.specify/templates/plan-template.md"
assert_file ".specify/templates/tasks-template.md present"   "$WORK/.specify/templates/tasks-template.md"
assert_file "create-new-feature.sh present"                  "$WORK/.specify/scripts/bash/create-new-feature.sh"

# -------------------------------------------------------------------------
step "2/5" "Install superspec from local checkout (--dev)"
if ! uvx --from git+https://github.com/github/spec-kit.git specify extension add "$REPO_ROOT" --dev \
        </dev/null >"$ADD_LOG" 2>&1; then
  fail "specify extension add exited non-zero (see $ADD_LOG)"
  echo "----- last 30 lines of add log -----"
  tail -n 30 "$ADD_LOG"
fi

assert_file ".specify/extensions.yml created" "$WORK/.specify/extensions.yml"

# All 5 slash commands are advertised in the install output (spec-kit prints them).
for c in status brainstorm tasks execute review; do
  assert_grep "command speckit.superspec.$c advertised on install" \
              "speckit.superspec.$c" \
              "$ADD_LOG"
done

# Hook commands are stored in extensions.yml under each hook name.
# Format (real):
#   hooks:
#     after_tasks:
#     - extension: superspec
#       command: speckit.superspec.tasks
HOOK_COUNT=0
if [ -f "$WORK/.specify/extensions.yml" ]; then
  HOOK_COUNT=$(grep -cE "^[[:space:]]+command:[[:space:]]*speckit\.superspec\." \
               "$WORK/.specify/extensions.yml" 2>/dev/null || true)
  HOOK_COUNT=${HOOK_COUNT:-0}
fi
if [ "$HOOK_COUNT" = "3" ]; then
  pass "3 hooks reference speckit.superspec.* in extensions.yml"
else
  fail "expected 3 hooks referencing speckit.superspec.*, got $HOOK_COUNT"
fi

# Cross-check via `specify extension list` (the same assertion the CI uses).
LIST_LOG="$WORK/.list.log"
uvx --from git+https://github.com/github/spec-kit.git specify extension list \
    </dev/null >"$LIST_LOG" 2>&1 || true
assert_grep "extension list shows 'Commands: 5 | Hooks: 3'" \
            "Commands: 5 | Hooks: 3" \
            "$LIST_LOG"

# -------------------------------------------------------------------------
step "3/5" "Simulate /speckit.specify (calls create-new-feature.sh directly)"
cd "$WORK"
bash .specify/scripts/bash/create-new-feature.sh \
     --short-name "smoke-test-feature" \
     "Smoke test feature for end-to-end validation" \
     >"$FEAT_LOG" 2>&1 || true

FEATURE_DIR_ACTUAL="$(ls -d "$WORK"/specs/*-smoke-test-feature 2>/dev/null | head -n1 || true)"

assert_dir     "specs/ created at project ROOT"        "$WORK/specs"
assert_no_dir  "no .specify/specs/ (issue #4 anti-regression)"  "$WORK/.specify/specs"

if [ -n "$FEATURE_DIR_ACTUAL" ] && [ -d "$FEATURE_DIR_ACTUAL" ]; then
  pass "feature dir created: ${FEATURE_DIR_ACTUAL#$WORK/}"
  assert_file "  spec.md inside feature dir" "$FEATURE_DIR_ACTUAL/spec.md"
else
  fail "feature dir matching specs/*-smoke-test-feature not found"
  echo "----- create-new-feature log -----"
  cat "$FEAT_LOG"
fi

# -------------------------------------------------------------------------
step "4/5" "Verify superspec docs match spec-kit's real layout"
# Catches the bug from issue #4: superspec docs say `.specify/specs/...` but
# spec-kit really puts files under `specs/...`. We check three doc tiers:
#   - commands/*.md and commands/hooks/*.md  (agent-facing instructions)
#   - templates/*.md                          (templates that get installed)
#   - README* / SKILL.md / examples/*.md      (human-facing docs)
check_drift() {
  local desc="$1"; shift
  local hits=0
  # examples/static-landing-page/ is a real-run e2e snapshot. Its README
  # legitimately contains the wrong path in teaching prose (e.g. "X, not
  # .specify/specs/..."), so we exclude that directory from drift checks.
  hits=$(grep -rEn --exclude-dir='static-landing-page' '\.specify/specs/' "$@" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$hits" -eq 0 ]; then
    pass "$desc"
  else
    fail "$desc — $hits stale '.specify/specs/' reference(s):"
    grep -rEn --exclude-dir='static-landing-page' '\.specify/specs/' "$@" 2>/dev/null | sed 's|^|        |'
  fi
}

cd "$REPO_ROOT"
check_drift "commands/ uses 'specs/' not '.specify/specs/'"      commands/
check_drift "templates/ uses 'specs/' not '.specify/specs/'"     templates/
check_drift "README/SKILL/examples use 'specs/' not '.specify/specs/'" \
            README.md README_zh.md SKILL.md examples/ references/

# -------------------------------------------------------------------------
step "5/5" "Generated artifacts (for human review)"
cd "$WORK"
echo "  ${C_DIM}workdir:${C_RST} $WORK"
echo
find . -type f \
  \( -path './.specify/*' -o -path './specs/*' -o -name 'AGENTS.md' -o -name 'CLAUDE.md' \) \
  -not -path '*/.git/*' \
  | sed 's|^./|    |' \
  | sort

# -------------------------------------------------------------------------
TOTAL=$((PASS + FAIL))
printf '\n%sSummary:%s %d/%d passed' "$C_BOLD" "$C_RST" "$PASS" "$TOTAL"
if [ "$FAIL" -gt 0 ]; then
  printf ', %s%d failed%s\n' "$C_RED" "$FAIL" "$C_RST"
  printf 'Failures:\n'
  for f in "${FAILS[@]}"; do printf '  - %s\n' "$f"; done
  printf '\nWorkdir kept at: %s\n' "$WORK"
  exit 1
fi
printf ' %s✓%s\n' "$C_GREEN" "$C_RST"
printf 'Workdir kept at: %s\n' "$WORK"
exit 0
