# Progress

Current: M1 → P1.6 `/basalt:init` (next)
Last done: P1.5 Basalt knowledge, index first (D7b)

## State

`claude plugin validate .` passes. `bash tests/run.sh` passes (57 tests: the hook, and now `scripts/sync-basalt-core.sh`); CI runs it on Ubuntu, macOS (also under /bin/bash 3.2) and Windows Git Bash. Every PR here, in core and in ci gets the Claude review (`claude / review`, required on `main`). `skills/basalt-core/` is pinned to core commit `1a7c213`; `bash scripts/sync-basalt-core.sh --check` reports drift.

## Decisions

- D1–D5 from `docs/design.md`: roadmap-first workflow, council for hard decisions only, desktop overlay mascot, own repo, overlay lives in this repo (P1.1).
- Hooks are plain bash with no python3 or jq dependency; JSON is escaped by hand (P1.1). Tests may use node (P1.2).
- `roadmap.md` and `progress.md` are committed; only `.basalt/session/` is local (P1.1).
- D6: `/basalt:init` and `/basalt:check` are in M1 (P1.6, P1.7). D7: moku conventions (P1.4, P1.5, P1.8).
- D8: every phase lands as a reviewed PR on a `basalt/<phase>` branch and squash-merges once CI and the Claude review pass, with no approval question unless the user asked to see it. Details: `commands/continue.md` Step 5 and `basalt-js/ci`'s `pr-review.yml` (P1.3, P1.4). Merge on green was the user's call (2026-10-31); the review model is Claude Opus 5.5, set by `pr-review.yml`'s `model` input.
- Plain-language rules live in `references/plain-language-arguments.md`; each command has an "Arguments" section with its exact form and examples (P1.4).
- P1.8: with merge on green, an unattended run can merge each phase PR and go on to the next phase; it stops at a rejected review it can't fix.
- P1.5: the design doc is split one file per section (`## N.` → `NN-slug.md`; parts only group the index; appendices are sections), not per part, so a lookup opens 5–90 lines. Commands read `${CLAUDE_PLUGIN_ROOT}/skills/basalt-core/references/index.md` directly instead of loading the skill, and cite sections as `core §N`.
- P1.5: the index has a hand-written part (rules, "Where to look" table) and a generated block (pin, section map). The sync script keeps the hand-written part and fails on routing links to sections that no longer exist. It pins the last commit that touched the doc, with no date, so `--check` is deterministic.
- P1.5: when core splits its doc into `spec/NN-*.md` (core M6), the sync script must switch to that folder.

## Blockers / waiting on you

- None

## Read first next time

- docs/design.md: D6 and the `/basalt:init` row in "The command set".
- ../ci/README.md and ../ci/package.json: what `@basalt-js/ci` exports (configs, `basalt-release`, `basalt-size`, workflows) and how a package extends it.
- ../core/package.json, biome.json, eslint.config.js, tsconfig.json, lefthook.yml, .github/workflows/: the reference setup `/basalt:init` should reproduce.
- commands/plan.md and references/plain-language-arguments.md: how a command file and its Arguments section are written.
