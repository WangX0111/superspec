#!/usr/bin/env python3
"""Validate extension metadata and public docs stay aligned with spec-kit.

The spec-kit catalog enforces that an extension's command and hook namespace
matches its catalog id (i.e. ``speckit.<extension.id>.*``). This script
re-implements that rule statically so we catch namespace/slug drift in CI
*before* a user fails to install from the catalog.
"""

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


def extract_extension_id(manifest: str) -> str:
    """Extract the top-level ``extension.id`` field from extension.yml.

    We avoid pulling in PyYAML to keep the validator dependency-free.
    """
    match = re.search(
        r"^extension:\n(?:[ \t]+.+\n)*?[ \t]+id:[ \t]*[\"']?([A-Za-z0-9_-]+)[\"']?",
        manifest,
        re.MULTILINE,
    )
    if not match:
        fail("extension.yml must declare extension.id")
    return match.group(1)


def main() -> None:
    manifest = read("extension.yml")

    if re.search(r"^provides:\n(?:  .+\n)*  hooks:", manifest, re.MULTILINE):
        fail("extension.yml must not declare hooks under provides.hooks")

    if not re.search(r"^hooks:\n", manifest, re.MULTILINE):
        fail("extension.yml must declare top-level hooks")

    ext_id = extract_extension_id(manifest)
    namespace_prefix = f"speckit.{ext_id}."

    # 1. provides.commands[*].name must use namespace prefix.
    command_names = re.findall(
        r"^    - name:[ \t]*[\"']?([^\"'\n]+)[\"']?",
        manifest,
        re.MULTILINE,
    )
    if not command_names:
        fail("extension.yml must declare provides.commands[].name entries")
    for name in command_names:
        if not name.startswith(namespace_prefix):
            fail(
                f"command '{name}' must use namespace '{namespace_prefix}*' "
                f"(matching extension.id='{ext_id}')"
            )

    # 2. hooks[*].command must also use namespace prefix.
    hook_commands = re.findall(
        r"^[ \t]+command:[ \t]*[\"']?(speckit\.[^\"'\n]+)[\"']?",
        manifest,
        re.MULTILINE,
    )
    for hook in ("after_tasks", "before_implement", "after_implement"):
        pattern = rf"^  {hook}:\n    command:[ \t]*[\"']?{re.escape(namespace_prefix)}"
        if not re.search(pattern, manifest, re.MULTILINE):
            fail(
                f"extension.yml hook '{hook}' must map to a "
                f"'{namespace_prefix}*' command"
            )
    for cmd in hook_commands:
        if not cmd.startswith(namespace_prefix):
            fail(
                f"hook command '{cmd}' must use namespace '{namespace_prefix}*' "
                f"(matching extension.id='{ext_id}')"
            )

    # 3. Public docs must not contain stale '/superspec.' command references
    #    (an old naming we no longer use).
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

    # 4. Docs must not still reference the old extension namespace
    #    speckit.superpowers.* (which we replaced with speckit.<ext_id>.*).
    legacy_namespace = "speckit.superpowers."
    if legacy_namespace != namespace_prefix:
        legacy_refs: list[str] = []
        for path in docs:
            text = read(path)
            for line_no, line in enumerate(text.splitlines(), start=1):
                if legacy_namespace in line:
                    legacy_refs.append(f"{path}:{line_no}: {line.strip()}")
        if legacy_refs:
            print(f"Legacy '{legacy_namespace}*' references found:")
            print("\n".join(legacy_refs[:50]))
            fail(
                f"found {len(legacy_refs)} legacy namespace reference(s); "
                f"expected '{namespace_prefix}*'"
            )

    # 5. README catalog install command's slug must equal extension.id.
    readme = read("README.md")
    if "specify extension add superpowers-bridge --from ./superspec" in readme:
        fail("README.md still documents obsolete local --from install command")
    if "specify extension add ./superspec --dev" not in readme:
        fail("README.md must document local --dev install command")

    catalog_install_slugs = re.findall(
        r"specify extension add ([A-Za-z0-9_-]+)(?!\S)",
        readme,
    )
    # Filter out the local-path install (./superspec) and --dev variants.
    real_slugs = [s for s in catalog_install_slugs if not s.startswith(".")]
    if not real_slugs:
        fail("README.md must document a catalog install command "
             "'specify extension add <slug>'")
    for slug in real_slugs:
        if slug != ext_id:
            fail(
                f"README.md install command 'specify extension add {slug}' "
                f"must match extension.id='{ext_id}'"
            )

    print(f"OK: extension metadata and docs are aligned (id='{ext_id}')")


if __name__ == "__main__":
    main()
