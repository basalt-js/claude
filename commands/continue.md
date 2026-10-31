---
description: Pick up the roadmap where the last session stopped and do the next phase.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Agent
argument-hint: [optional note for this session]
disable-model-invocation: true
---

# /basalt:continue

Do exactly one phase of the roadmap, from start to a clean finish. Each phase gets its own session, so conversations stay small. Each phase lands as one pull request: it is worked on a branch, reviewed, and squash-merged only after the user approves.

Note from the user for this session (may be empty): $ARGUMENTS

## Step 1: Load where we are

1. Read `.basalt/progress.md` and `.basalt/roadmap.md`. If either is missing, stop and tell the user to run `/basalt:plan` first.
2. Check them against git: run `git status`, `git log --oneline -10` and `git log --oneline --grep "<last done phase id>"`. If progress says something git contradicts (a "last done" phase with no commit on `main`, uncommitted changes nobody recorded), **git wins**: tell the user what differs and correct `progress.md` before going on.
3. Check for a phase PR that hasn't merged yet: `gh pr list --state open --json number,title,headRefName,isDraft --jq '.[] | select(.headRefName | startswith("basalt/"))'`. If there is one, switch to its branch and say you're resuming it. If its work is finished, go straight to Step 5; otherwise continue from its Partial section.
4. Read every file under "Read first next time".

## Step 2: Say where you're picking up

In one or two lines, tell the user which milestone and phase you're starting, and its goal. If the phase has a **Partial** section in `progress.md`, say you're resuming it and from where.

If `progress.md` lists a blocker that is waiting on the user, raise it now and wait for their answer before starting.

## Step 3: Do the phase

1. Start a branch for the phase from an up-to-date `main`: `git switch main`, `git pull --ff-only`, then `git switch -c basalt/<phase id>-<short name>`, for example `basalt/p1.3-pr-workflow`. Skip this when resuming a phase branch.
2. Do the work:
   - Stay inside the phase's goal. Note anything else you find for a later phase instead of doing it now.
   - Follow the project's own rules (`CLAUDE.md`, lint, tests).
   - If you discover the roadmap is wrong (a missing phase, a wrong order, a phase too big for one session), stop and propose the change to the user. Change the roadmap only after they approve, and log it under Decisions.
   - If you reach a decision the user should make, ask them. Don't guess on things that are expensive to undo.

## Step 4: Finish the phase

1. Run the phase's **Done when** check. If this is the last phase of its milestone, also run the milestone's **Exit** check. Both must pass; if they don't, fix the problem or record it as a blocker.
2. Tick the phase (`[x]`) in `.basalt/roadmap.md`.
3. Rewrite `.basalt/progress.md` from `${CLAUDE_PLUGIN_ROOT}/templates/progress.md`. `Current` becomes the next unticked phase and `Last done` this phase. Fill in State, Decisions from this phase, Blockers, and the files the *next* phase should read first. Remove the Partial section.
4. Commit the phase's work together with the roadmap and progress updates on the phase branch, following the repository's commit conventions. End the subject with the milestone and phase id, for example `feat: reviewed pull requests (M1 P1.3)`: the squash-merge keeps it, and that is how the next session finds the phase in `git log`. The user started `/basalt:continue`, which includes committing the finished phase.

## Step 5: Open the pull request and get it merged

If the repository has no GitHub remote, or `gh auth status` fails, skip this step: tell the user the phase is committed on its branch and that pushing and merging are up to them.

1. Push the branch (`git push -u origin <branch>`). If a draft PR is already open for it, run `gh pr ready <number>`. Otherwise open one with `gh pr create`: the commit subject as the title, and a body that says what the phase did and how its Done-when check went. Follow the repository's PR template and conventions.
2. Wait for the checks: run `gh pr checks <number> --watch --interval 30` in the background and wait until it finishes. The checks are CI plus, where the repository has one, the Claude review (`claude / review`).
3. **CI failed:** read the failing log (`gh run view <run id> --log-failed`), fix the cause on the same branch, commit, push, and go back to 2.
4. **The review rejected:** read its latest comment, which starts with `<!-- basalt-review -->`: `gh pr view <number> --json comments --jq '[.comments[] | select(.body | startswith("<!-- basalt-review -->"))] | last | .body'`. Fix every blocking finding on the same branch, commit, push, and go back to 2. Apply a suggestion only when it is small and inside the phase's goal. If you think a blocking finding is wrong, ask the user instead of pushing around it. After three rejected rounds, stop and ask the user how to go on.
5. **Everything passes:** ask the user whether to merge, with AskUserQuestion. Give the PR link and the review's summary. Only an answer in this session counts; an approval from an earlier session or PR does not.
6. **Approved:** `gh pr merge <number> --squash --delete-branch`, then `git switch main` and `git pull --ff-only`. **Not yet:** leave the PR open; the next `/basalt:continue` picks it up at this step.

## Step 6: Stop

Tell the user in a few lines: what the phase did, the PR and whether it merged, and what the next phase is. Suggest starting it with `/basalt:continue` in a fresh conversation. Do not start the next phase in this session.

## If you have to stop early

If the phase can't be finished in this session (it turned out bigger than planned, or you're blocked), don't leave the state unrecorded. Add a **Partial** section to `progress.md`: what's done, what's left, and exactly where to resume. Keep `Current` on this phase, commit any finished work on the phase branch, push it, and open a draft PR (`gh pr create --draft`) so the work isn't only on this machine. Tell the user. If the phase was too big, propose splitting it in the roadmap.
