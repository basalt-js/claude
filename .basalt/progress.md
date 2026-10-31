# Progress

Current: M1 → P1.7 `/basalt:check` (next)
Last done: P1.6 `/basalt:init`

## State

`claude plugin validate .` passes. `bash tests/run.sh` passes (80 tests: the hook, `sync-basalt-core.sh`, and `init-project.sh` in files-only mode, which needs bun). CI runs them on Ubuntu, macOS (also /bin/bash 3.2) and Windows Git Bash; a new `init` job runs the real install and `bun run check` for both kinds (not a required check yet). Every PR gets the Claude review (`claude / review`, required on `main`). `skills/basalt-core/` is pinned to core `1a7c213`.

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
- P1.6: `/basalt:init` has two kinds: `package` (published: tsdown build, publint + attw, the 12 KB size gate, `publish.yml`) and `app` (private, CI with `build: false`). Both mirror core's setup.
- P1.6: versions are looked up when init runs: the latest `@basalt-js/ci`; its peers (Biome, ESLint, TypeScript) at the versions ci's own devDependencies pin, because the latest ESLint (10) is outside ci's `^9` peer; other tools at their latest, with `@vitest/coverage-istanbul` matched to Vitest. CI's `typescript-versions` and `bun-version` follow what was installed.
- P1.6: the files are templates in `templates/init/` written by `scripts/init-project.sh` (testable, never overwrites); the command handles questions, the first commit (the one direct commit to `main`), GitHub and protection. Reusable workflows are called at `@main`, since ci's `v0.1.0` tag predates `pr-review.yml`.
- P1.5: when core splits its doc into `spec/NN-*.md` (core M6), the sync script must switch to that folder.

## Blockers / waiting on you

- None

## Read first next time

- docs/design.md: the `/basalt:check` row in "The command set" (install, tooling versions, roadmap/progress/git agreement, `check usage`).
- commands/status.md: the read-only report `/basalt:check` sits next to, and its git/progress agreement checks.
- scripts/init-project.sh: the version policy `check` should compare a project against.
- Deferred from PR #4's review, small fixes for `scripts/sync-basalt-core.sh`: indented code fences aren't detected, and a broken routing link is reported after the files are already written.
- Not yet tried live: `/basalt:init` Step 5 (creating the GitHub repo, protection, the first CI run). P1.9's first real use covers it.
