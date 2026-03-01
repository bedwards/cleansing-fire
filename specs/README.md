# specs/ -- Machine-Readable Project Specifications

This directory contains structured, machine-parseable documentation for AI agents working on the Cleansing Fire project.

## For AI Agents

If you are an AI agent (Claude Code worker, autonomous agent, or any LLM-based system) working on this project, this directory is your primary reference for:

- **What exists and how it connects:** `project-graph.yaml`
- **How plugins must behave:** `plugin-schema.json`
- **What you are allowed to do:** `agent-capabilities.yaml`
- **What the project is trying to achieve:** `goals.yaml`

Read these files before making architectural decisions. When in doubt about an interface, check the schema. When in doubt about priorities, check the goals. When in doubt about boundaries, check the capabilities.

For narrative context, motivation, and philosophical grounding, read the human documentation in `docs/` and `philosophy.md`.

## For Humans

These files are structured data (YAML, JSON Schema) designed primarily for machine consumption, but they are intentionally human-readable too. If you want to understand the project architecture at a glance, `project-graph.yaml` is a good starting point. If you want to understand the plugin contract, `plugin-schema.json` defines it formally.

The narrative, motivational, philosophical documentation lives in `docs/` and `philosophy.md`. This directory is the structured complement to those human-oriented documents.

## Conventions

### File Formats

- **YAML** (`.yaml`) for configuration, graphs, capabilities, goals -- anything with hierarchy, comments, and descriptions
- **JSON Schema** (`.json`) for interface validation -- formal definitions of data shapes that can be automatically validated
- **OpenAPI** (`.yaml`) for HTTP API specifications (future)

### Required Fields

Every spec file must include a top-level `metadata` block:

```yaml
metadata:
  version: "0.1.0"          # Semantic version of this spec
  updated: "2026-02-28"     # Last update date
  description: "..."        # What this spec defines
  human_docs:               # Links to narrative documentation
    - path: "docs/foo.md"
      description: "Human-readable version of this spec"
```

### Versioning

Spec versions use semantic versioning:
- **Patch** (0.1.0 -> 0.1.1): Clarifications, typo fixes, added descriptions
- **Minor** (0.1.0 -> 0.2.0): New fields, new capabilities, backward-compatible changes
- **Major** (0.1.0 -> 1.0.0): Breaking changes to structure or semantics

### Comments

Use comments generously. YAML comments (`#`) should explain *why*, not just *what*. An agent reading a spec should understand the reasoning behind constraints, not just the constraints themselves.

### Validation

Specs should be validatable:
- YAML files should parse without errors
- JSON Schema files should be valid JSON Schema (draft 2020-12)
- Cross-references between files should resolve
- Future: CI pipeline validates all specs on every commit

## File Index

| File | Format | Purpose |
|------|--------|---------|
| `project-graph.yaml` | YAML | Component dependency graph -- what exists and how it connects |
| `plugin-schema.json` | JSON Schema | Formal definition of the plugin interface contract |
| `plugin-registry.yaml` | YAML | Catalog of all plugins with actions, dependencies, and API requirements |
| `agent-capabilities.yaml` | YAML | What AI agents can do, their tools, and their boundaries |
| `goals.yaml` | YAML | Project goal hierarchy with success criteria and priorities |
| `deployment-spec.yaml` | YAML | Deployment targets, configurations, and infrastructure bindings |
| `data-model.yaml` | YAML | D1 database schema -- tables, columns, types, constraints |

## Relationship to CLAUDE.md

`CLAUDE.md` in the project root is the bridge between human and AI documentation. It provides conversational context that Claude Code loads at session start. The specs in this directory provide formal definitions that agents should reference for precise interface details, decision criteria, and validation.

Think of it this way:
- `CLAUDE.md` tells you how to work on this project (conventions, commands, workflow)
- `specs/` tells you what this project is (structure, interfaces, goals, boundaries)
- `docs/` and `philosophy.md` tell you why this project exists (motivation, philosophy, research)
