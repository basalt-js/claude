---
description: Show where the project is in its roadmap. Read-only.
allowed-tools: Read, Bash, Glob, Grep
disable-model-invocation: true
---

# /basalt:status

Report the project's position in its roadmap. Change nothing: no edits, no commits.

1. Read `.basalt/roadmap.md` and `.basalt/progress.md`. If they don't exist, say so and suggest `/basalt:plan`.
2. Run `git status`, `git log --oneline -5` and `git log --oneline --grep "<last done phase id>"`, and note anything that contradicts `progress.md`. If `gh` works here, also list open phase PRs: `gh pr list --state open --json number,title,headRefName,url --jq '.[] | select(.headRefName | startswith("basalt/"))'`.
3. Reply with:
   - **Position:** current milestone and phase, and `<done>/<total>` phases ticked overall and in the current milestone.
   - **Last done:** the last finished phase, and its commit on `main` if `git log --grep` finds one.
   - **Open PR:** a phase PR waiting on review or on the user's approval, with its link, if any.
   - **Next:** the current phase's goal and its "Done when" check.
   - **Partial work, blockers, or questions waiting on the user**, if any.
   - **Mismatches** between `progress.md` and git, if any, with a note that `/basalt:continue` will reconcile them.

Keep it short: a few lines, or a small table for the milestones.
