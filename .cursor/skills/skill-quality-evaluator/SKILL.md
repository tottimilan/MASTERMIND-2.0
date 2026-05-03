---
name: skill-quality-evaluator
description: Static analysis lint for MASTERMIND skills. Evaluates SKILL.md files against the canonical 9-section template, validates YAML frontmatter (name, description), enforces line-count budget (≤500), and detects four anti-patterns (BLOATED_SKILL, MISSING_TRIGGER, EMPTY_DESCRIPTION, MISSING_SECTION). Use when adding a new skill, refactoring an existing one, auditing the skill library, or before merging any PR that touches .cursor/skills/. Produces a per-skill score (0-100) and a list of findings. Runs as PowerShell CLI with no external dependencies. Trigger keywords "evaluate skill", "lint skill", "skill quality", "audit skills", "score skill".
---

# Skill Quality Evaluator

> Body completed in Task 9 of plan `2026-05-03-build-skill-quality-evaluator.md`.
