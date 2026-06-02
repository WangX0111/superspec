# Quickstart: Static Landing Page

**Feature**: 001-static-landing-page | **Date**: 2026-05-30

## Prerequisites

- A modern web browser (Chrome, Firefox, Safari, or Edge — last 2 major versions)
- A text editor for authoring HTML/CSS
- No build tools, no package manager, no server required

## Getting Started

### 1. Create the output directory

```bash
mkdir -p web
```

### 2. Author the page

Create `web/index.html` with all HTML markup and inlined CSS in a single `<style>` tag.

### 3. Preview locally

Open the file directly in a browser:

```bash
# macOS
open web/index.html

# Linux
xdg-open web/index.html

# Or simply drag the file into a browser window
```

No HTTP server is required — the page renders identically via `file://` protocol.

### 4. Validate

- **HTML**: Submit `web/index.html` to [W3C Markup Validation Service](https://validator.w3.org/) — zero errors required
- **Accessibility**: Run axe-core browser extension — zero violations required
- **Responsive**: Test at 320px, 768px, and 1280px viewport widths
- **Print**: Use browser Print Preview to verify ink-friendly output
- **Offline**: Disconnect network, reload page — must render completely

### 5. Check page weight

```bash
wc -c web/index.html
# Must be ≤ 65536 bytes (64 KB)
```

## File Structure

```
web/
└── index.html    # The entire deliverable — single file
```

## Key Constraints

| Constraint | Value | Source |
|-----------|-------|--------|
| JavaScript | None | Constitution I |
| External resources | None | Constitution IV |
| Build tools | None | Constitution Constraints |
| Max page weight | 64 KB | Constitution Quality Standards |
| Output path | `web/index.html` | Constitution Constraints |
| Browser support | Last 2 major versions of Chrome, Firefox, Safari, Edge | Constitution Constraints |
