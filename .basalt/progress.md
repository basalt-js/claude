# Progress

Current: M1 → P1.4 Plain-language arguments (D7a) (next)
Last done: P1.3 PR workflow (D8)

## State

`claude plugin validate .` passes. `bash tests/run.sh` passes (34 tests); CI runs it on Ubuntu, macOS (also under /bin/bash 3.2) and Windows Git Bash. Every PR here, in core and in ci gets the Claude review; `claude / review` is a required check on `main` in all three.

## Decisions

- D1–D5 from `docs/design.md`: roadmap-first workflow, council for hard decisions only, desktop overlay mascot, own repo, overlay lives in this repo (P1.1).
- Hooks are plain bash with no python3 or jq dependency; JSON is escaped by hand (P1.1).
- `roadmap.md` and `progress.md` are committed; only `.basalt/session/` is local (P1.1).
- D6: `/basalt:init` and `/basalt:check` added to M1 (now P1.6 and P1.7).
- D7: three conventions from moku: plain-language arguments (P1.4), index-first knowledge (P1.5), opt-in unattended runs (P1.8).
- Tests may use node to parse JSON; hooks still may not (P1.2).
- D8: every change lands as a reviewed PR, squash-merged only after the user approves; `main` protected on core, ci and claude (2026-10-31).
- The review is a reusable workflow in basalt-js/ci (`pr-review.yml`); each repo has a thin `claude-review.yml` caller, as with `package-ci.yml` (P1.3).
- The review runs with the workflow's `GITHUB_TOKEN`, not the Claude app's token: the app skips PRs whose workflow differs from `main`, which includes the PR that adds the review (P1.3).
- The verdict is the action's `--json-schema` structured output; a bash step posts it as a PR comment starting with `<!-- basalt-review -->` and fails the check on `reject`. Each run posts a new comment, so review rounds stay readable (P1.3).
- Drafts and fork PRs skip the review; `/basalt:continue` opens a draft when it stops mid-phase and marks it ready at the end (P1.3).
- `Last done` names the phase, not a commit hash: the squash commit doesn't exist when progress.md is written. Commit and PR subjects end with the phase id, e.g. `(M1 P1.3)`, so `git log --grep` finds it (P1.3).
- An unmerged phase PR (branch `basalt/…`) is picked up by the next `/basalt:continue` (P1.3).
- Open: P1.8 unattended runs can open PRs but not merge them without the user; decide there whether to stack PRs or stop at the first one.
- Open: the review uses the action's default model (claude-sonnet-5-5); `pr-review.yml` could take a `model` input if reviews turn out too weak.

## Blockers / waiting on you

- None

## Read first next time

- docs/design.md, "Conventions for every command (D7)", item a: the rule P1.4 writes down.
- commands/plan.md, commands/continue.md, commands/status.md: the three commands it applies to.
- CLAUDE.md: how command files are written.
