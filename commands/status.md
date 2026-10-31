---
description: Show where the project is in its roadmap. Read-only.
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
argument-hint: [milestone or phase id]
disable-model-invocation: true
---

# /basalt:status

Report the project's position in its roadmap. Change nothing: no edits, no commits.

## Arguments

The user typed: $ARGUMENTS

Read it by the rules in `${CLAUDE_PLUGIN_ROOT}/references/plain-language-arguments.md`. The exact form is `[<milestone id> | <phase id>]`:

- Empty: the report below.
- `<milestone id>`, such as `M2`: the report, then that milestone in detail: its Exit check and each phase with its tick and Done-when check.
- `<phase id>`, such as `P2.1`: the report, then that phase: its goal, its Done-when check, and its commit if it is done.

In plain words, a milestone or phase named by its id or its title becomes the id. A question about the position, such as "is anything waiting on me", is read as empty and answered in the report.

| The user typed | Read as |
|---|---|
| `/basalt:status what's left in content` | `Interpreting as: /basalt:status M2` |
| `/basalt:status is anything waiting on me` | `Interpreting as: /basalt:status`, answered under blockers |
| `/basalt:status the RSS one` (a phase and a milestone both mention RSS) | ask which, with the phase first |
| `/basalt:status M2` | exact: no echo |
| `/basalt:status start the next phase` | not this command: point to `/basalt:continue` |

## Report

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
