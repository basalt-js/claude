# Progress

Current: M1 → P1.3 PR workflow (D8) (next)
Last done: P1.2 Hook tests (da06dc8)

## State

Branch main. `claude plugin validate .` passes. `bash tests/run.sh` passes (34 tests); CI runs it on Ubuntu, macOS (also under /bin/bash 3.2) and Windows Git Bash.

## Decisions

- D1–D5 from `docs/design.md`: roadmap-first workflow, council for hard decisions only, desktop overlay mascot, own repo, overlay lives in this repo (P1.1).
- Hooks are plain bash with no python3 or jq dependency; JSON is escaped by hand (P1.1).
- `roadmap.md` and `progress.md` are committed; only `.basalt/session/` is local (P1.1).
- D6: `/basalt:init` and `/basalt:check` added to M1 (now P1.6 and P1.7).
- D7: three conventions from moku: plain-language arguments (now P1.4), index-first knowledge (P1.5), opt-in unattended runs (P1.8).
- Roadmap approved by the user on 2026-10-31 (P1.2).
- Tests may use node to parse JSON; hooks still may not (P1.2): node is on every CI runner, and the hooks' no-dependency rule is about users' machines.
- Hook fixes found by the tests (P1.2): a one-line `<!-- -->` comment no longer drops the rest of progress.md after compaction; control characters other than tab, CR and LF are dropped so the JSON stays valid.
- D8: every change lands as a PR, reviewed by a Claude Code Action and squash-merged only after the user approves. New phase P1.3 PR workflow; former P1.3–P1.9 are now P1.4–P1.10; `/basalt:init` (P1.6) also adds the review workflow and `main` protection. Approved by the user 2026-10-31.
- `main` protected on core, ci and claude (PR and CI required, admins can bypass), squash-only merges, branches deleted on merge (2026-10-31, outside a phase).
- P1.8 unattended runs must fit D8: an unattended run can open PRs but can't merge them without the user; decide in P1.8 whether it stacks PRs or stops at the first one.

## Blockers / waiting on you

- Before P1.3: install the Claude GitHub app and give the repos a Claude token (run `/install-github-app` in Claude Code, or add a `CLAUDE_CODE_OAUTH_TOKEN` from `claude setup-token` as an org secret so core, ci and claude all get it).

## Read first next time

- docs/design.md, D8: the PR rule P1.3 builds.
- commands/continue.md, Step 4: where committing turns into branch, PR, review and merge.
- .github/workflows/ci.yml: the checks the review runs beside; its job names are the required checks on `main`.
- CLAUDE.md: how command files are written.
