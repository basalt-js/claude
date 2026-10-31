---
description: Show where the project is in its roadmap. Read-only.
allowed-tools: Read, Bash, Glob, Grep
disable-model-invocation: true
---

# /basalt:status

Report the project's position in its roadmap. Change nothing: no edits, no commits.

1. Read `.basalt/roadmap.md` and `.basalt/progress.md`. If they don't exist, say so and suggest `/basalt:plan`.
2. Run `git status` and `git log --oneline -5`, and note anything that contradicts `progress.md`.
3. Reply with:
   - **Position:** current milestone and phase, and `<done>/<total>` phases ticked overall and in the current milestone.
   - **Last done:** the last finished phase and its commit.
   - **Next:** the current phase's goal and its "Done when" check.
   - **Partial work, blockers, or questions waiting on the user**, if any.
   - **Mismatches** between `progress.md` and git, if any, with a note that `/basalt:continue` will reconcile them.

Keep it short: a few lines, or a small table for the milestones.
