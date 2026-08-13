#!/usr/bin/env python3
"""Validate the ZIP that spec-kit's catalog will actually download.

`specify extension add superspec` resolves to GitHub's generated tag archive
(https://github.com/WangX0111/superspec/archive/refs/tags/vX.Y.Z.zip), which is
produced by `git archive` and therefore honours the `export-ignore` rules in
.gitattributes. This script rebuilds that archive locally and checks it against
the limits spec-kit enforces in `src/specify_cli/_download_security.py` before
extracting an untrusted archive, so a regression fails CI instead of failing
users at install time (issue #6).

Usage:
    python3 scripts/validate-release-archive.py [git-ref]

Default ref is HEAD.
"""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

# Mirrors specify_cli._download_security. Keep in sync when spec-kit changes.
MAX_DOWNLOAD_BYTES = 50 * 1024 * 1024
MAX_ZIP_ENTRIES = 512
MAX_ZIP_MEMBER_BYTES = 10 * 1024 * 1024
MAX_ZIP_TOTAL_BYTES = 50 * 1024 * 1024

# Warn well before a limit is reached rather than at the cliff edge.
WARN_RATIO = 0.5

REPO_ROOT = Path(__file__).resolve().parent.parent

# Paths that must survive into the archive because the installed extension
# needs them. Command/template files declared in extension.yml are checked
# separately and do not need to be repeated here.
REQUIRED_MEMBERS = (
    "extension.yml",
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "SKILL.md",
    # commands/*.md link to these at runtime ("See references/...").
    "references/superpowers-bridge.md",
    "references/workflow-guide.md",
)

# Prefixes .gitattributes strips. Keep in sync with the export-ignore list.
EXCLUDED_PREFIXES = (
    "assets/",
    "examples/",
    "scripts/",
    ".github/",
)
EXCLUDED_MEMBERS = (
    ".gitattributes",
    ".gitignore",
    "README_zh.md",
)

failures: list[str] = []


def fail(message: str) -> None:
    failures.append(message)
    print(f"  FAIL  {message}")


def ok(message: str) -> None:
    print(f"  ok    {message}")


def human(size: int) -> str:
    return f"{size / (1024 * 1024):.2f} MiB"


def declared_payload_files(manifest: str) -> list[str]:
    """Return every `file:` path declared under provides in extension.yml."""
    provides = manifest.partition("\nprovides:\n")[2]
    provides = re.split(r"^\S", provides, maxsplit=1, flags=re.MULTILINE)[0]
    return re.findall(r"^\s*-?\s*file:\s*[\"']?([^\"'\n]+)[\"']?\s*$", provides, re.MULTILINE)


def build_archive(ref: str, destination: Path) -> None:
    subprocess.run(
        ["git", "archive", "--format=zip", f"--prefix=superspec/", "-o", str(destination), ref],
        cwd=REPO_ROOT,
        check=True,
    )


def main() -> int:
    ref = sys.argv[1] if len(sys.argv) > 1 else "HEAD"
    print(f"Validating release archive for ref '{ref}'\n")

    with tempfile.TemporaryDirectory() as tmpdir:
        archive_path = Path(tmpdir) / "superspec.zip"
        build_archive(ref, archive_path)

        download_size = archive_path.stat().st_size
        with zipfile.ZipFile(archive_path) as archive:
            infos = archive.infolist()
            members = {
                info.filename.split("/", 1)[1]: info
                for info in infos
                if "/" in info.filename
            }
            manifest_info = members.get("extension.yml")
            # `git archive` applies the local text conversion, so a Windows
            # checkout with core.autocrlf=true yields CRLF members even though
            # GitHub's generated archive uses LF. Normalize before parsing.
            manifest = (
                archive.read(manifest_info.filename)
                .decode("utf-8")
                .replace("\r\n", "\n")
                if manifest_info
                else ""
            )

        files = {name: info for name, info in members.items() if not name.endswith("/")}
        total_size = sum(info.file_size for info in files.values())

        print("Archive limits (spec-kit _download_security):")
        for label, actual, limit in (
            ("download size", download_size, MAX_DOWNLOAD_BYTES),
            ("uncompressed total", total_size, MAX_ZIP_TOTAL_BYTES),
        ):
            message = f"{label}: {human(actual)} / {human(limit)}"
            if actual > limit:
                fail(message)
            elif actual > limit * WARN_RATIO:
                fail(f"{message} (over {WARN_RATIO:.0%} of the limit; slim the archive)")
            else:
                ok(message)

        entries = len(infos)
        entry_message = f"entries: {entries} / {MAX_ZIP_ENTRIES}"
        if entries > MAX_ZIP_ENTRIES:
            fail(entry_message)
        elif entries > MAX_ZIP_ENTRIES * WARN_RATIO:
            fail(f"{entry_message} (over {WARN_RATIO:.0%} of the limit)")
        else:
            ok(entry_message)

        oversized = [
            (name, info.file_size)
            for name, info in files.items()
            if info.file_size > MAX_ZIP_MEMBER_BYTES
        ]
        if oversized:
            for name, size in oversized:
                fail(f"member {name} is {human(size)} (limit {human(MAX_ZIP_MEMBER_BYTES)})")
        else:
            largest = max(files.items(), key=lambda item: item[1].file_size)
            ok(
                f"largest member: {largest[0]} at {human(largest[1].file_size)} "
                f"/ {human(MAX_ZIP_MEMBER_BYTES)}"
            )

        print("\nRuntime payload present:")
        for name in REQUIRED_MEMBERS:
            if name in files:
                ok(name)
            else:
                fail(f"missing required member: {name}")

        if not manifest:
            fail("extension.yml could not be read from the archive")
        else:
            declared = declared_payload_files(manifest)
            if not declared:
                fail("no command/template files parsed from extension.yml provides")
            for name in declared:
                if name in files:
                    ok(f"declared in extension.yml: {name}")
                else:
                    fail(f"extension.yml declares '{name}' but it is not in the archive")

        print("\nNon-runtime paths excluded:")
        for prefix in EXCLUDED_PREFIXES:
            present = sorted(name for name in members if name.startswith(prefix))
            if present:
                fail(f"{prefix} should be export-ignored but ships {len(present)} member(s)")
            else:
                ok(f"{prefix} excluded")
        for name in EXCLUDED_MEMBERS:
            if name in files:
                fail(f"{name} should be export-ignored but is in the archive")
            else:
                ok(f"{name} excluded")

    print()
    if failures:
        print(f"{len(failures)} check(s) failed:")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("Release archive is within every spec-kit install limit.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
