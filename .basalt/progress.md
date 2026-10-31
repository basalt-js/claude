# Progress

Current: M1 → P1.5 Basalt knowledge, index first (D7b) (next)
Last done: P1.4 Plain-language arguments (D7a)

## State

`claude plugin validate .` passes. `bash tests/run.sh` passes (34 tests); CI runs it on Ubuntu, macOS (also under /bin/bash 3.2) and Windows Git Bash. Every PR here, in core and in ci gets the Claude review (Claude Opus 5.5, from `basalt-js/ci`'s `pr-review.yml`); `claude / review` is a required check on `main` in all three.

## Decisions

- D1–D5 from `docs/design.md`: roadmap-first workflow, council for hard decisions only, desktop overlay mascot, own repo, overlay lives in this repo (P1.1).
- Hooks are plain bash with no python3 or jq dependency; JSON is escaped by hand (P1.1). Tests may use node (P1.2).
- `roadmap.md` and `progress.md` are committed; only `.basalt/session/` is local (P1.1).
- D6: `/basalt:init` and `/basalt:check` are in M1 (P1.6, P1.7). D7: moku conventions (P1.4, P1.5, P1.8).
- D8: every change lands as a reviewed PR on a `basalt/<phase>` branch. The review is a reusable workflow in basalt-js/ci with thin `claude-review.yml` callers, runs with `GITHUB_TOKEN`, and fails its check on `reject`. `Last done` names the phase; commit subjects end with the phase id. Drafts and fork PRs skip the review; a session that stops mid-phase opens a draft PR, and the next `/basalt:continue` picks up an unmerged `basalt/…` PR. Details: `commands/continue.md` Step 5 and `basalt-js/ci`'s `pr-review.yml` (P1.3).
- The review model is Claude Opus 5.5, set by `pr-review.yml`'s `model` input (2026-10-31, after P1.3).
- Plain-language rules live in one file, `references/plain-language-arguments.md`; each command has an "Arguments" section with its exact form and examples (P1.4).
- Exact forms (P1.4): `plan new "<description>"` / `revise "<change>"`; `continue [<phase id>] ["<note>"]`; `status [<milestone or phase id>]`. `continue` with a phase other than the next one asks first, since that reorders the roadmap.
- Only quoted free text counts as exact; unquoted notes and descriptions get the `Interpreting as:` echo. The echo may come after reading the roadmap, but before the command's own work. A vague request echoes without the missing value and asks for it (P1.4).
- Open: P1.8 unattended runs can open PRs but not merge them without the user; decide there whether to stack PRs or stop at the first one.
- Merge on green (user, 2026-10-31, after P1.4): a phase PR squash-merges on its own once CI and the Claude review pass; no approval question. D8 in `docs/design.md`, the PR rule in `CLAUDE.md` and in the workspace `CLAUDE.md`, and `/basalt:continue` Step 5 still say to ask: change them in P1.5's PR, and follow the new rule from now on.

## Blockers / waiting on you

- None

## Read first next time

- docs/design.md, "Conventions for every command (D7)", item b: the rule P1.5 builds.
- ../core/docs/basalt-design.md: the doc to split by section (about 1,160 lines; Part V lists the decisions, §40 the milestones).
- moku's `skills/moku-core/SKILL.md` and its `references/` (in the moku plugin cache) and its `spec-sync` skill: the index-first pattern and the refresh script to model.
- CLAUDE.md: how command files and skills are written.
- commands/continue.md Step 5, docs/design.md D8, CLAUDE.md: the merge-on-green change that also goes into P1.5's PR.
