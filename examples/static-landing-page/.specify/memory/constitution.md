<!--
Sync Impact Report
==================
Version change: N/A → 1.0.0
Modified principles: N/A (initial ratification)
Added sections:
  - Core Principles (5 principles)
  - Quality Standards
  - Constraints
  - Governance
Removed sections: None
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ compatible (Constitution Check
    section is dynamic; no hardcoded principle names)
  - .specify/templates/spec-template.md ✅ compatible (no principle-specific
    references)
  - .specify/templates/tasks-template.md ✅ compatible (no principle-specific
    references)
  - .specify/templates/commands/*.md ✅ N/A (directory does not exist)
Follow-up TODOs: None
-->

# Superspec Landing Page Constitution

## Core Principles

### I. Zero Build, Zero Runtime Dependencies

The landing page MUST be authored as raw HTML and CSS with no build
tooling, no transpilation, no bundling, and no runtime dependency on
external resources. Every byte required to render the page MUST be
contained within the single output file or inlined assets.

**Rationale**: A landing page for a spec-kit tool should embody the
simplicity it advocates. Zero build eliminates CI complexity, deploy
friction, and supply-chain risk. Zero runtime deps guarantees the page
loads even on restricted networks.

### II. Semantic HTML First

All markup MUST use semantically appropriate HTML5 elements (`<header>`,
`<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`, etc.).
Presentational `<div>` or `<span>` elements MUST NOT be used where a
semantic element exists. Heading hierarchy MUST be strictly sequential
without skipping levels.

**Rationale**: Semantic HTML is the foundation of accessibility, SEO,
and maintainability. It communicates structure to assistive technology
and search engines without relying on class-name conventions.

### III. Mobile-First Responsive Design

Layouts MUST be designed for the smallest viewport first (≥320 px) and
progressively enhanced for wider screens via CSS media queries. Touch
targets MUST be at least 44 × 44 px. Text MUST remain readable without
horizontal scrolling at any viewport width.

**Rationale**: Mobile-first is the correct default for a page whose
audience includes developers browsing on phones during conferences or
commutes. Progressive enhancement avoids desktop-centric assumptions.

### IV. Self-Contained Single-File Delivery

The sole deliverable MUST be `web/index.html`. All styles MUST be
inlined in a `<style>` tag within the document. Images MUST be inlined
as data URIs or replaced with pure-CSS alternatives. No `<link>`,
`<script src>`, or `<img src>` pointing to external resources is
permitted.

**Rationale**: A single file simplifies deployment (drop it on any
static host), eliminates CDN outages, and guarantees offline rendering.

### V. Developer-Audience Clarity

Content and visual hierarchy MUST prioritize what a developer evaluating
spec-kit extensions needs: what superspec does, how to get started, and
where to find deeper documentation. Marketing language MUST be avoided
in favor of concrete, technical descriptions. Code snippets and CLI
examples SHOULD appear where they reduce ambiguity.

**Rationale**: The audience is technically discerning. Vague or
promotional copy erodes credibility; precise, example-driven content
builds trust.

## Quality Standards

- **HTML Validation**: The output MUST pass the W3C Markup Validation
  Service with zero errors (warnings acceptable).
- **Responsive Verification**: The page MUST be verified at 320 px,
  768 px, and 1280 px viewport widths with no layout breakage or
  horizontal overflow.
- **Accessibility Baseline**: The page MUST pass axe-core automated
  checks at zero violations. Color contrast MUST meet WCAG AA (4.5:1
  for normal text, 3:1 for large text).
- **Page Weight**: Total transferred size of `web/index.html` MUST NOT
  exceed 64 KB (uncompressed).
- **Zero Console Errors**: Opening the page in a browser MUST produce
  zero console errors or warnings.
- **Offline Functional**: The page MUST render correctly when opened
  from a local file with no network connection.

## Constraints

- **Technology**: Pure HTML5 + CSS3 only. JavaScript MUST NOT be used.
  CSS features limited to those with baseline support in the latest
  two major versions of Chrome, Firefox, Safari, and Edge.
- **Build Tooling**: None. No pre-processors (Sass, PostCSS), no
  templating engines, no static site generators. Files are authored
  and deployed as-is.
- **Output Path**: `web/index.html` — a single file at the project
  root under `web/`. No subdirectories, no asset folders.
- **External Network Dependencies**: None at runtime. No CDN links,
  no web fonts, no analytics scripts, no third-party resources of
  any kind. System font stacks MUST be used.
- **Browser Support**: Last two major versions of Chrome, Firefox,
  Safari, and Edge. Graceful degradation is acceptable; feature
  parity is not required for Internet Explorer or legacy EdgeHTML.

## Governance

This constitution is the authoritative reference for all design and
implementation decisions on the Superspec Landing Page. When a conflict
arises between this document and any other artifact (spec, plan, tasks),
the constitution prevails.

**Amendment Procedure**:
1. Propose amendment with written rationale.
2. Validate that the change does not violate an existing principle
   without explicit justification recorded in the Complexity Tracking
   section of the active plan.
3. Increment version per semantic versioning:
   - MAJOR: principle removal or redefinition
   - MINOR: new principle or materially expanded guidance
   - PATCH: clarification, wording, typo fixes
4. Update all dependent templates (plan, spec, tasks) to reflect the
   amendment before merging.

**Compliance Review**: Every implementation task MUST include a
constitution compliance check before marking the task complete.

**Version**: 1.0.0 | **Ratified**: 2026-05-30 | **Last Amended**: 2026-05-30
