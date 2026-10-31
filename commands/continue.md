---
description: Pick up the roadmap where the last session stopped and do the next phase.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Agent
argument-hint: [optional note for this session]
disable-model-invocation: true
---

# /basalt:continue

Do exactly one phase of the roadmap, from start to a clean finish. Each phase gets its own session, so conversations stay small.

Note from the user for this session (may be empty): $ARGUMENTS

## Step 1: Load where we are

1. Read `.basalt/progress.md` and `.basalt/roadmap.md`. If either is missing, stop and tell the user to run `/basalt:plan` first.
2. Check them against git: run `git status` and `git log --oneline -10`. If progress says something git contradicts (a "last done" commit that doesn't exist, uncommitted changes nobody recorded), **git wins**: tell the user what differs and correct `progress.md` before going on.
3. Read every file under "Read first next time".

## Step 2: Say where you're picking up

In one or two lines, tell the user which milestone and phase you're starting, and its goal. If the phase has a **Partial** section in `progress.md`, say you're resuming it and from where.

If `progress.md` lists a blocker that is waiting on the user, raise it now and wait for their answer before starting.

## Step 3: Do the phase

- Stay inside the phase's goal. Note anything else you find for a later phase instead of doing it now.
- Follow the project's own rules (`CLAUDE.md`, lint, tests).
- If you discover the roadmap is wrong (a missing phase, a wrong order, a phase too big for one session), stop and propose the change to the user. Change the roadmap only after they approve, and log it under Decisions.
- If you reach a decision the user should make, ask them. Don't guess on things that are expensive to undo.

## Step 4: Finish the phase

1. Run the phase's **Done when** check. If this is the last phase of its milestone, also run the milestone's **Exit** check. Both must pass; if they don't, fix the problem or record it as a blocker.
2. Tick the phase (`[x]`) in `.basalt/roadmap.md`.
3. Rewrite `.basalt/progress.md` from `${CLAUDE_PLUGIN_ROOT}/templates/progress.md`. `Current` becomes the next unticked phase. Fill in State, Decisions from this phase, Blockers, and the files the *next* phase should read first. Remove the Partial section.
4. Commit the phase's work together with the roadmap and progress updates, following the repository's commit conventions. The user started `/basalt:continue`, which includes committing the finished phase. Don't push unless the user asks.

## Step 5: Stop

Tell the user in a few lines: what the phase did, the commit, and what the next phase is. Suggest starting it with `/basalt:continue` in a fresh conversation. Do not start the next phase in this session.

## If you have to stop early

If the phase can't be finished in this session (it turned out bigger than planned, or you're blocked), don't leave the state unrecorded. Add a **Partial** section to `progress.md`: what's done, what's left, and exactly where to resume. Keep `Current` on this phase, commit any finished work, and tell the user. If the phase was too big, propose splitting it in the roadmap.
