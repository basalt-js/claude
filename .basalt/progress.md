# Progress

Current: M1 → P1.2 Hook tests (next)
Last done: P1.1 Scaffold (the commit that adds this file)

## State

Branch main. `claude plugin validate .` passes. The roadmap is a **draft** waiting for the user's approval.

## Decisions

- D1–D5 from `docs/design.md`: roadmap-first workflow, council for hard decisions only, desktop overlay mascot, own repo, overlay lives in this repo (P1.1).
- Hooks are plain bash with no python3 or jq dependency; JSON is escaped by hand (P1.1).
- `roadmap.md` and `progress.md` are committed; only `.basalt/session/` is local (P1.1).

## Blockers / waiting on you

- Approve or change the roadmap in `.basalt/roadmap.md`.

## Read first next time

- hooks/progress-context.sh: the script P1.2 tests.
- hooks/hooks.json: how the script is wired to SessionStart and PostCompact.
- templates/progress.md: the "Current" and "Last done" lines the hook reads.
