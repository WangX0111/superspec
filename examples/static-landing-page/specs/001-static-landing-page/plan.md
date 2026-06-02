# Implementation Plan: Static Landing Page

**Branch**: `001-static-landing-page` | **Date**: 2026-05-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-static-landing-page/spec.md`

## Summary

Build a single-file static landing page (`web/index.html`) for SuperSpec using pure HTML5 + CSS3 with zero build tooling, zero JavaScript, and zero external dependencies. The page comprises three sections: a full-viewport hero with project name/tagline/CTA, a features grid showcasing the five core commands, and a workflow diagram with install snippet. All styles are inlined; all content is semantic and mobile-first responsive.

## Technical Context

**Language/Version**: HTML5 + CSS3 (no JavaScript)

**Primary Dependencies**: None (self-contained single-file delivery)

**Storage**: N/A

**Testing**: Manual browser testing at 320px/768px/1280px viewports, W3C Markup Validation (zero errors), axe-core accessibility audit (zero violations), `wc -c` page weight check (≤64 KB), print preview verification

**Target Platform**: Web browsers — Chrome, Firefox, Safari, Edge (last 2 major versions)

**Project Type**: Static web page (marketing/landing page)

**Performance Goals**: ≤64 KB uncompressed page weight, zero console errors, instant render (no JS to block)

**Constraints**: Single file (`web/index.html`), no external resources, no JavaScript, no build tools, WCAG AA color contrast, keyboard navigable, `file://` protocol compatible, print stylesheet required

**Scale/Scope**: Single page, 3 content sections, ~18 functional requirements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Pre-Design Gate

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Zero Build, Zero Runtime Dependencies | ✅ PASS | Spec mandates pure HTML+CSS with no build tooling or runtime deps (FR-010) |
| II. Semantic HTML First | ✅ PASS | Spec requires landmark regions, sequential heading hierarchy, semantic elements (FR-016, edge cases) |
| III. Mobile-First Responsive Design | ✅ PASS | Spec requires 320px+ support with progressive enhancement (FR-012, FR-013) |
| IV. Self-Contained Single-File Delivery | ✅ PASS | Spec requires `web/index.html` as sole deliverable with inlined styles (FR-011, FR-015) |
| V. Developer-Audience Clarity | ✅ PASS | Spec prioritizes technical content — command descriptions, install snippet, workflow diagram |

**Result**: All 5 principles pass. No violations to track.

### Post-Design Gate (re-check after Phase 1)

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Zero Build, Zero Runtime Dependencies | ✅ PASS | Design uses no build tools, no JS, no CDN links, no external resources |
| II. Semantic HTML First | ✅ PASS | Design specifies `<header>`, `<main>`, `<section>`, `<footer>`, `<ol>` for workflow, `<code>` for snippet |
| III. Mobile-First Responsive Design | ✅ PASS | Design uses mobile-first CSS with `min-width` breakpoints at 768px and 1024px |
| IV. Self-Contained Single-File Delivery | ✅ PASS | All CSS inlined in `<style>` tag; system font stack (no web fonts); CSS-only step indicator (no images) |
| V. Developer-Audience Clarity | ✅ PASS | Content is concrete and technical: command names, descriptions, install command, workflow sequence |

**Result**: All 5 principles pass post-design. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-static-landing-page/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output — resolved open questions
├── data-model.md        # Phase 1 output — content entities
├── quickstart.md        # Phase 1 output — dev workflow
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
web/
└── index.html           # The entire deliverable — single file, all HTML + inlined CSS
```

**Structure Decision**: Single-file output per Constitution Principle IV. No `src/`, `dist/`, `assets/`, or build directories. The `web/` directory contains exactly one file: `index.html`.

## Technical Approach

### HTML Structure

```text
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SuperSpec — Specification-Driven Development</title>
  <style>/* All CSS inlined here */</style>
</head>
<body>
  <header>          ← Hero section (h1, tagline, CTA button)
  <main>
    <section>       ← Features grid (5 cards in CSS Grid)
    <section>       ← Workflow diagram (ordered list step indicator) + install snippet
  </main>
  <footer>          ← Minimal footer
</body>
</html>
```

### CSS Architecture

1. **Reset/Base**: Minimal CSS reset (box-sizing, margin/padding normalization)
2. **Typography**: System font stack with `clamp()` for responsive font sizing
3. **Layout**: Flexbox for hero and workflow; CSS Grid for features card layout
4. **Components**: `.card`, `.step-indicator`, `.code-block` utility classes
5. **Responsive**: Mobile-first with `@media (min-width: 768px)` and `@media (min-width: 1024px)`
6. **Accessibility**: `:focus-visible` outlines, `forced-colors` media query adjustments
7. **Print**: `@media print` — suppress decorative elements, linear flow, serif font

### Workflow Diagram (Step Indicator)

- Semantic `<ol>` with 5 `<li>` items (one per command)
- CSS Flexbox for horizontal layout on wider viewports; vertical stack on mobile
- Each step: numbered circle (`::before` pseudo-element with counter) + command name
- Connecting line between steps via `::after` pseudo-element (border-based)
- Last step has no connecting line

### Features Grid

- CSS Grid: `grid-template-columns: 1fr` on mobile → `repeat(2, 1fr)` at 768px → `repeat(3, 1fr)` at 1024px
- Cards use semantic `<article>` elements with `<h3>` command name and `<p>` description
- Second row centers the remaining 2 cards using flexbox wrapper or grid placement

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| "Get Started" destination | `#install` | Scrolls to install section; no external URL available yet (OQ-001) |
| Install command | `npm install -g superspec` | Standard for developer CLI tools; confirm before production (OQ-002) |
| Workflow diagram style | Step indicator (numbered circles + connecting lines) | Lightweight, consistent rendering, accessible (OQ-003) |
| Font strategy | System font stack | No external deps per Constitution I & IV |
| Layout mechanism | Flexbox + CSS Grid | Baseline-supported in all target browsers |
| Responsive breakpoints | 768px, 1024px (mobile-first) | Covers tablet and desktop; aligns with Constitution III |

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Page weight exceeds 64 KB | Low | High | Step indicator pattern chosen over CSS arrows for weight efficiency; monitor with `wc -c` during development; simplify typography/layout rules if needed |
| CSS rendering inconsistencies across browsers | Low | Medium | Use only baseline CSS features (flexbox, grid, `clamp()`); test in all 4 target browsers |
| "Get Started" link points to placeholder | Medium | Low | `#install` provides functional in-page navigation; destination URL is trivially updatable |
| Install command incorrect | Medium | Low | `npm install -g superspec` is the assumed default; must be confirmed before deployment |
| Print stylesheet breaks layout | Low | Medium | Dedicated `@media print` block with explicit overrides; verify with Print Preview in all target browsers |
| Forced-colors mode removes visual distinction | Low | Medium | Use `forced-colors` media query to add explicit borders; never rely on `background-color` alone per FR-018 |

## Complexity Tracking

> No constitution violations. This section is empty.
