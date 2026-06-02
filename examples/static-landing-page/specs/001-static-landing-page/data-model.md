# Data Model: Static Landing Page

**Feature**: 001-static-landing-page | **Date**: 2026-05-30

## Overview

This is a static content page with no persistent data, no database, and no dynamic state. The "data model" describes the structured content entities that appear on the page, their fields, and their relationships.

## Entities

### Hero Section

| Field | Type | Validation | Notes |
|-------|------|------------|-------|
| project_name | text | Required, non-empty | "SuperSpec" |
| tagline | text | Required, non-empty | "Specification-driven development for modern teams" |
| cta_label | text | Required, non-empty | "Get Started" |
| cta_href | URL/anchor | Required, valid href | `#install` (placeholder) |

### Feature Card

| Field | Type | Validation | Notes |
|-------|------|------------|-------|
| command_name | text | Required, non-empty | One of: status, brainstorm, tasks, execute, review |
| description | text | Required, 1–2 sentences | Brief description of command purpose |
| sequence_order | integer | Required, 1–5 | Display order in grid and workflow |

### Workflow Step

| Field | Type | Validation | Notes |
|-------|------|------------|-------|
| step_number | integer | Required, 1–5 | Sequential position |
| command_name | text | Required | Must match a Feature Card command_name |
| is_last | boolean | Derived | If step_number = 5, no connecting line after |

### Install Snippet

| Field | Type | Validation | Notes |
|-------|------|------------|-------|
| command | text | Required, valid shell command | `npm install -g superspec` |
| label | text | Optional | "Install" or similar heading text |

## Relationships

```
Hero Section (1) ──contains── (1) CTA → links to Install Snippet
Feature Card (5) ──ordered by── sequence_order
Workflow Step (5) ──references── Feature Card.command_name
```

## Static Data Instances

### Feature Cards (ordered by sequence)

| # | command_name | description |
|---|-------------|-------------|
| 1 | status | Check the current state of your specification and implementation progress |
| 2 | brainstorm | Generate creative ideas and explore solution spaces for your feature |
| 3 | tasks | Decompose your plan into concrete, actionable implementation tasks |
| 4 | execute | Run the implementation workflow, processing tasks in order |
| 5 | review | Verify the implementation against the specification and constitution |

## State Transitions

N/A — No dynamic state. All content is static and rendered at page load.
