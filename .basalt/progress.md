# Progress

Current: M1 → P1.3 Plain-language arguments (D7a) (next)
Last done: P1.2 Hook tests (the commit that adds this file)

## State

Branch main. `claude plugin validate .` passes. `bash tests/run.sh` passes (34 tests); CI runs it on Ubuntu, macOS (also under /bin/bash 3.2) and Windows Git Bash.

## Decisions

- D1–D5 from `docs/design.md`: roadmap-first workflow, council for hard decisions only, desktop overlay mascot, own repo, overlay lives in this repo (P1.1).
- Hooks are plain bash with no python3 or jq dependency; JSON is escaped by hand (P1.1).
- `roadmap.md` and `progress.md` are committed; only `.basalt/session/` is local (P1.1).
- D6: `/basalt:init` and `/basalt:check` added to M1 as P1.5 and P1.6.
- D7: three conventions from moku: plain-language arguments (P1.3), index-first knowledge (P1.4), opt-in unattended runs (P1.7).
- Roadmap approved by the user on 2026-10-31 (P1.2).
- Tests may use node to parse JSON; hooks still may not (P1.2): node is on every CI runner, and the hooks' no-dependency rule is about users' machines.
- Hook fixes found by the tests (P1.2): a one-line `<!-- -->` comment no longer drops the rest of progress.md after compaction; control characters other than tab, CR and LF are dropped so the JSON stays valid.

## Blockers / waiting on you

- None

## Read first next time

- docs/design.md, "Conventions for every command (D7)": the rules P1.3 writes down.
- commands/plan.md, commands/continue.md, commands/status.md: the three commands P1.3 applies them to.
- CLAUDE.md: how command files are written (direct numbered steps, `disable-model-invocation`).
