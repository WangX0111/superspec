#!/usr/bin/env python3
"""Validate extension metadata and public docs stay aligned with spec-kit."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def main() -> None:
    manifest = read("extension.yml")

    if re.search(r"^provides:\n(?:  .+\n)*  hooks:", manifest, re.MULTILINE):
        fail("extension.yml must not declare hooks under provides.hooks")

    if not re.search(r"^hooks:\n", manifest, re.MULTILINE):
        fail("extension.yml must declare top-level hooks")

    for hook in ("after_tasks", "before_implement", "after_implement"):
        pattern = rf"^  {hook}:\n    command: [\"']?speckit\.superpowers\."
        if not re.search(pattern, manifest, re.MULTILINE):
            fail(f"extension.yml missing canonical command mapping for {hook}")

    docs = [
        "README.md",
        "README_zh.md",
        "SKILL.md",
        "references/superpowers-bridge.md",
        "references/workflow-guide.md",
        "examples/sample-workflow.md",
        "templates/constitution-template.md",
        "templates/spec-template.md",
        "templates/plan-template.md",
        "templates/tasks-template.md",
        "templates/checklist-template.md",
    ]

    stale_command_refs: list[str] = []
    for path in docs:
        text = read(path)
        for line_no, line in enumerate(text.splitlines(), start=1):
            if re.search(r"(^|[^A-Za-z0-9_-])/superspec\.", line):
                stale_command_refs.append(f"{path}:{line_no}: {line.strip()}")

    if stale_command_refs:
        print("Stale /superspec.* references:")
        print("\n".join(stale_command_refs[:50]))
        fail(f"found {len(stale_command_refs)} stale command reference(s)")

    readme = read("README.md")
    if "specify extension add superpowers-bridge --from ./superspec" in readme:
        fail("README.md still documents obsolete local --from install command")
    if "specify extension add ./superspec --dev" not in readme:
        fail("README.md must document local --dev install command")

    print("OK: extension metadata and docs are aligned")


if __name__ == "__main__":
    main()
