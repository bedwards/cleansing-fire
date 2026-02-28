---
name: implement
description: Implement a feature following the Cleansing Fire development workflow
user_invocable: true
---

# Implement: $ARGUMENTS

You are implementing a feature for Cleansing Fire. Follow the definitive development loop from CLAUDE.md.

## Steps

1. **Read CLAUDE.md** to understand project conventions
2. **Search GitHub Issues** for an existing issue matching "$ARGUMENTS"
   - If found, reference it
   - If not, create one with `gh issue create`
3. **Create a feature branch**: `cf/<issue-number>-<short-description>`
4. **Read existing code** that your changes will touch — understand before modifying
5. **Implement the work** following project conventions:
   - Python: stdlib only, 3.9+
   - Shell: `set -euo pipefail`
   - Plugins: JSON stdin/stdout per specs/plugin-schema.json
   - Never bolt on — integrate coherently with existing work
6. **Test your changes** — run relevant scripts, check for regressions
7. **Commit with clear messages** using the project's commit format
8. **Create a Pull Request** with `gh pr create`
   - Reference the issue
   - Include a clear description of changes
   - List what was added/modified

Remember the Coherence Principle: read existing work before adding. Never destroy, never regress.
