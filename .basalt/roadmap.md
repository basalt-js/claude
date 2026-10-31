# Roadmap: basalt Claude Code plugin

> **Draft, not yet approved.** Built from the brainstorm in `docs/design.md`. Change it only through a proposal the user approves; log each change in progress.md under Decisions.

## M1: Roadmap workflow

Exit: `claude plugin validate .` passes, and `/basalt:plan`, `/basalt:continue` and `/basalt:status` have each been run on a real project with the plugin installed.

- [x] **P1.1 Scaffold**: manifests, roadmap and progress templates, the three commands, the progress hooks. Done when: `claude plugin validate .` passes and the hook prints valid JSON for both events.
- [ ] **P1.2 Hook tests**: a test script for `hooks/progress-context.sh` (no progress file, SessionStart, PostCompact, JSON escaping), run in CI. Done when: `bash tests/run.sh` passes locally and in GitHub Actions.
- [ ] **P1.3 First real use**: install the plugin locally, run `/basalt:plan` on `basalt-js/core` from its §40 milestones, then one `/basalt:continue` session. Fix what's rough in the commands. Done when: core has an approved `.basalt/roadmap.md` and one phase was finished through `/basalt:continue`.
- [ ] **P1.4 Release 0.1.0**: README install steps, CHANGELOG, tag `v0.1.0`, GitHub release. Done when: `/plugin marketplace add basalt-js/claude` then `/plugin install basalt@basalt` works in a clean setup.

## M2: Mascot in the status line

Exit: during a real session the status line shows the main agent's state (Idle, Thinking, Creating, Polishing) and one marker per running subagent.

- [ ] **P2.1 Session state**: hooks on UserPromptSubmit, PreToolUse, Stop, SubagentStart and SubagentStop write `.basalt/session/state.json`, with its format documented. Done when: a scripted run of the hooks produces the expected state for each event.
- [ ] **P2.2 Status line**: `statusLine` and `subagentStatusLine` render the four states and the subagent markers from `state.json`. Done when: seen working in a live session.

## M3: Mascot overlay

Exit: `/basalt:interface` opens the corner overlay on Windows and shows the main mascot and subagent mascots live; CI builds it for Windows, macOS and Linux.

- [ ] **P3.1 Mascot design**: an original Basalt character, its four animations, and small coloured variants for subagents. Done when: the user approves the art.
- [ ] **P3.2 Overlay skeleton**: a Tauri app in `mascot/` with a transparent, always-on-top, click-through window in the bottom-right corner that follows `state.json`. Done when: it runs locally and switches animations as the state changes.
- [ ] **P3.3 Subagent mascots**: one small mascot per running subagent, coloured by agent type or council role, appearing and leaving with them. Done when: seen working with two or more subagents.
- [ ] **P3.4 `/basalt:interface`**: the command downloads the right build on first use and starts or shows the overlay for the current project. Done when: it works from a clean install on Windows.
- [ ] **P3.5 Release builds**: GitHub Actions builds the overlay per OS and attaches the builds to the plugin's releases. Done when: a tagged release has all three builds.

## M4: Lessons

Exit: lessons are proposed at the end of each phase, reviewed by the user, and their index is loaded at session start within a size budget.

- [ ] **P4.1 Lesson format and `/basalt:lessons`**: one file per lesson plus an index; the command lists them and suggests removals. Done when: the command works on a sample set.
- [ ] **P4.2 Capture**: `/basalt:continue` proposes lessons at the end of a phase, for the user to accept, edit or reject. Done when: tried on a real phase.
- [ ] **P4.3 Load**: the SessionStart hook adds the lesson index within a fixed budget. Done when: tested with a large lesson set staying under budget.

## M5: Council

Exit: `/basalt:council <question>` runs a discussion with up to three roles over two rounds, shows its budget, and records the decision in progress.md.

- [ ] **P5.1 Role agents**: lead, developer, devil's advocate, security, thinker and Basalt architect as agent definitions, each with a short brief and a model choice. Done when: each role answers a sample question in character.
- [ ] **P5.2 `/basalt:council`**: picks two or three roles, runs rounds over a shared transcript in `.basalt/council/`, prints a cost estimate first and usage at the end, and records the decision. Done when: used on one real hard decision.
