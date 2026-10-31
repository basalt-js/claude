---
description: Create or revise the project roadmap (.basalt/roadmap.md). The first step in every Basalt project.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
argument-hint: [what you are building, in plain words]
disable-model-invocation: true
---

# /basalt:plan

Create the roadmap that every later session works from. The output is two files: `.basalt/roadmap.md` and `.basalt/progress.md`. Templates: `${CLAUDE_PLUGIN_ROOT}/templates/roadmap.md` and `${CLAUDE_PLUGIN_ROOT}/templates/progress.md`. Read both templates before writing anything, and follow the rules in their comments.

The user's description of the project: $ARGUMENTS

## Step 1: Check for an existing roadmap

If `.basalt/roadmap.md` already exists, do **not** overwrite it. Show the user its milestones and the current position from `.basalt/progress.md`, then ask what they want to change. Revising means proposing an edit and getting approval (Step 4), then logging the change in `progress.md` under Decisions.

## Step 2: Understand the project

Read what already exists before asking anything: `README.md`, `CLAUDE.md`, `package.json`, any design or spec documents, and the top-level layout. If the project uses Basalt, note which framework and plugins it already has.

Then ask the user only what you genuinely can't work out: the goal, what "done" looks like, hard constraints, and what matters most. Use AskUserQuestion, at most four questions at once, each with a recommended option. Don't ask about things the code already answers.

## Step 3: Draft the roadmap

- **Milestones** are deliverables, in the order they should be built. Each has an **Exit** line: a check that proves it is done, such as a command that passes or a behaviour that can be shown.
- **Phases** split each milestone into steps that each fit in **one session**: one coherent change, finished with its tests, and committed. When unsure, make phases smaller. A phase that touches many unrelated areas should be split.
- Each phase has a one-line goal and a **Done when** check.
- Put risky or uncertain work early, so problems show up before much is built on top.

## Step 4: Get approval

Show the user the full draft. Wait for explicit approval; apply their changes and show it again until they approve. Never write the roadmap without approval.

## Step 5: Write the files

1. Write `.basalt/roadmap.md` from the approved draft, with today's date in the "Approved" line.
2. Write `.basalt/progress.md` from the template: `Current` is the first phase, `Last done` is "nothing yet", and the State section reflects `git status`.
3. If `.gitignore` doesn't already ignore `.basalt/session/`, add that line. (`roadmap.md` and `progress.md` are meant to be committed; `session/` is local state.)

## Step 6: Hand over

Tell the user, in two or three lines, how many milestones and phases the roadmap has and what the first phase is. Then tell them to run `/basalt:continue` to start it, ideally in a fresh conversation.
