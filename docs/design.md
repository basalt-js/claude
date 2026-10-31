# Basalt Claude Code plugin: design

> **Status:** brainstorm, with some decisions made (below). 2026-10-31.
> **What:** the `basalt` Claude Code plugin (`/basalt:*` commands), the way `moku` has one. This repo, `github.com/basalt-js/claude`, is the plugin.
> **Roadmap:** `.basalt/roadmap.md` in this repo; the plugin is built with its own workflow.
> **Ideas:** (1) progressive learning, (2) roadmap-first workflow with `/basalt:continue`, (3) mascot interface with `/basalt:interface`, (4) agent council with roles, for hard decisions only.

## Decided so far

| # | Decision |
|---|---|
| D1 | Every Basalt project starts with a roadmap. There is no `/basalt:handoff`; progress is written at each phase boundary and `/basalt:continue` does the next thing (idea 2). |
| D2 | The council runs only for really hard decisions, started by you with `/basalt:council` (idea 4). |
| D3 | The mascot is a **desktop overlay**: a small always-on-top window in the screen corner (idea 3). |
| D4 | The plugin gets **its own repo**, modelled on `moku-labs/claude` (see "Repo layout" below). |
| D5 | The mascot overlay app **lives in the plugin repo**, under `mascot/`. Its per-OS builds are published as release downloads of that repo. |
| D6 | `/basalt:init` and `/basalt:check` are part of M1 (see "Commands" below). |
| D7 | Every command follows three conventions taken from moku: (a) plain-language arguments, (b) bundled knowledge read index-first, (c) unattended runs only on request (see "Conventions for every command" below). |
| D8 | Every change lands as a pull request: a branch per phase, CI and a Claude Code Action review must pass, a rejected review is fixed on the same branch, and the PR is squash-merged as soon as CI and the review pass, with no approval question (changed from "after the user approves" on 2026-10-31). `main` is protected (PR and CI required, admin bypass for emergencies). Applies to the basalt-js repos and to projects run with `/basalt:continue` (roadmap P1.3). |

---

## The shared piece: a `.basalt/` folder in each project

Ideas 1, 2 and 4 all need somewhere to write things down. One folder, checked into the project's repo (except `session/`):

```
.basalt/
  roadmap.md          ← idea 2: milestones → phases, with exit criteria
  progress.md         ← idea 2: where we are in the roadmap right now
  lessons/            ← idea 1: one small file per lesson
    INDEX.md          ←   one line per lesson; the only file loaded by default
  council/            ← idea 4: one transcript per discussion
  session/            ← idea 3: live state for the mascot (gitignored)
    state.json
```

Plain markdown in the repo means you can read, edit, diff and review everything the plugin "knows".

---

## 1. Progressive learning

**The idea:** the more you use the plugin, the better it gets at your project.

**What "learning" can really mean.** The model itself can't change. What can grow is a set of notes the plugin reads at the start of each session. So learning = **capturing lessons, curating them, and loading the right ones**.

**How it would work:**
1. **Capture.** At each phase boundary, when `progress.md` is written (idea 2), the agent proposes lessons. Examples: "tests here need `bun run check`, not `npm test`", "the user prefers small commits", "`ctx.find` trips `unicorn/no-array-callback-reference`".
2. **Review.** You approve, edit or reject each one. Unreviewed lessons are the main way this goes wrong: wrong lessons get repeated forever.
3. **Load.** A `SessionStart` hook loads `lessons/INDEX.md` (one line per lesson) under a fixed size budget. The agent opens a full lesson only when it is relevant.
4. **Prune.** Lessons that are stale, duplicated or contradicted get merged or deleted. `/basalt:lessons` could list them and suggest removals.

**What Basalt adds that generic memory can't.** A Basalt app can describe itself: `app.inspect()` (M5) returns every plugin, event, dependency and listener. The plugin doesn't need to *learn* the architecture; it can *read* it fresh every time. So lessons can be limited to things that aren't in the code: preferences, mistakes, team conventions.

**Overlap:** Claude Code already has auto-memory (the `memory/` folder this session uses). The Basalt version should differ in being per-project, in the repo, reviewed, and Basalt-aware.

**Open questions:**
- Review every lesson, or only ones the agent marks as unsure?
- Shared lessons (whole team, committed) vs personal ones (gitignored)?
- Should lessons have an expiry, or a "confirmed N times" counter?

---

## 2. Roadmap first, then `/basalt:continue`

**The idea:** every Basalt project starts with a roadmap. As each milestone or phase finishes, the plugin records where we are in a progress file. In any new conversation, `/basalt:continue` reads that file and does the next thing. No huge sessions that degrade, and no manual handoff step.

This is how the kernel itself is being built: the design doc's §40 milestones are the roadmap, and each session picks up the next one.

### Step 1: `/basalt:plan` creates the roadmap

The first thing in any Basalt project. The agent asks what you're building, then writes `.basalt/roadmap.md`:

```md
# Roadmap: my-blog

## M1: Site skeleton
Exit: `bun run check` passes; home page renders.
- [ ] P1.1 Framework config and router plugin
- [ ] P1.2 Home and post pages
- [ ] P1.3 Tests for routing

## M2: Content
Exit: posts load from markdown; RSS feed builds.
- [ ] P2.1 Content plugin with the markdown pipe
...
```

- **Milestones** are deliverables with **exit criteria**: the check that proves the milestone is done.
- **Phases** are sized to fit **one session**. That is the key rule: a phase that can't finish in one conversation gets split.
- You approve the roadmap before any work starts.

### Step 2: `progress.md` is updated at every phase boundary

When a phase finishes, the agent ticks it in the roadmap and rewrites `.basalt/progress.md`. Writing happens at phase boundaries, never after every reply, so it costs almost nothing:

```md
# Progress
Current: M1 → P1.3 Tests for routing (next)
Last done: P1.2 Home and post pages

## State
`bun run check` passes.

## Decisions
- Posts use slugs, not ids (P1.2)

## Blockers / waiting on you
- None

## Read first next time
- src/plugins/router/index.ts
- tests/integration/routing.test.ts
```

Each session ends cleanly at a phase boundary: the phase is done, progress is written, and everything is in one pull request (D8). If a session has to stop mid-phase, the agent writes a "partial" note under the current phase so nothing is lost.

### Step 3: `/basalt:continue` does the next thing

1. Reads `roadmap.md` and `progress.md`.
2. Checks them against `git status` and `git log`. Git wins if they disagree, and the agent says so.
3. Opens the "read first" files.
4. Says in one or two lines where it is picking up, then starts the next phase.
5. At the end of the phase: runs the exit checks, updates progress, commits on the phase branch and opens a PR. It fixes what CI or the Claude review rejects, squash-merges once CI and the review pass, and stops, so the next phase gets a fresh session.

### Changing the plan

Plans change. When the agent finds the roadmap is wrong (a missing phase, a wrong order), it proposes the edit and you approve it. It never silently rewrites the roadmap. Roadmap changes are logged in `progress.md` under Decisions.

**Open questions:**
- Should `/basalt:continue` stop after one phase, or keep going while the session is still small?
- ~~Commit automatically at each phase end, or ask first?~~ Answered by D8: commit, open the PR and merge it automatically once CI and the review pass.
- One roadmap per project, or allow parallel tracks (e.g. a `docs` track next to the main one)?

---

## 3. Mascot interface: `/basalt:interface`

**The idea:** a mascot in the bottom-right corner with four animations (Idle, Thinking, Creating, Polishing). Each subagent appears as a small mascot in its own colour, living next to the main one.

**The catch: a terminal can't draw sprites in a corner.** Claude Code's own UI only offers text surfaces: the status line, a per-subagent status line, and plugin panels. So there are three ways to build it:

| Option | What you see | Effort |
|---|---|---|
| **A. Status line** | A small text/emoji mascot in the status line, e.g. `◕‿◕ creating… · 🟣 security 🟠 devil` | Small |
| **B. Desktop overlay** | A real animated mascot in a small transparent always-on-top window in the screen corner, with mini mascots for subagents | Medium: a small separate app (e.g. Tauri) |
| **C. VS Code panel** | An animated mascot in a webview panel beside the chat | Medium |

**Decided (D3): B, the desktop overlay.** A status-line version can still be a quick first step to prove the event wiring.

**Overlay design sketch:**
- A small app (Tauri is a good fit: small binary, transparent windows) that opens a transparent, always-on-top, click-through window in the bottom-right corner.
- It watches `.basalt/session/state.json`, which the plugin's hooks keep up to date: the main agent's state, plus a list of running subagents with their role and colour.
- `/basalt:interface` starts the app (or brings it back if it's hidden) for the current project. Closing the window doesn't affect Claude Code.
- Packaging is the hard part: a native app needs a build per OS (Windows, macOS, Linux), published as GitHub release downloads that `/basalt:interface` fetches on first use.

**How the states are driven: hooks, zero tokens.** Claude Code hooks fire on events and run a tiny script that updates `.basalt/session/state.json`. The mascot app watches that file.

| Animation | Triggered by |
|---|---|
| Idle | `Stop` (the agent finished its turn) |
| Thinking | `UserPromptSubmit`, and any time between tool calls |
| Creating | `PreToolUse` on `Write` / `Edit` |
| Polishing | `PreToolUse` on `Bash` running lint, tests or `check` |
| Mini mascot appears / leaves | `SubagentStart` / `SubagentStop`, coloured by agent type or council role |

**Cost:** none in tokens. The model never sees any of this; it's local scripts and an animation.

**Branding:** the Claude character belongs to Anthropic, so a published plugin is safer with an original Basalt mascot. A little basalt-rock or crystal creature fits the name, and its four animations could be designed from scratch.

**Open questions:**
- Should clicking a mini mascot show what that subagent is doing?
- One overlay per project, or one overlay showing every running Claude Code session?

---

## 4. Agent council: `/basalt:council`

**The idea:** for really hard projects, where a decision is costly to get wrong, several subagents discuss it in a shared space, each with a role: the main agent is team lead, plus cybersecurity, devil's advocate, thinker, developer and so on.

**When it runs: only for hard decisions.** The council is never part of the normal flow. Day-to-day work goes through the roadmap and `/basalt:continue` with a single agent. The council is for decisions like "monorepo or many repos", "which auth model", "do we break the public API". During planning or work, the agent may *suggest* a council when it hits a decision like that, but only you start it with `/basalt:council <question>`. Its outcome goes into `progress.md` under Decisions (and into the roadmap, if it changes the plan).

**How agents can "talk":**
- **Shared transcript (simple, predictable).** The lead runs rounds. Each role agent reads `council/<topic>.md`, appends its turn, and stops. The lead summarises and decides. This is the pattern moku's brainstorm agents use (present → challenge → decide).
- **Agent teams (live, harder to control).** Claude Code can run teammates that message each other directly. It's closer to a real conversation, but cost and length are harder to bound.

**Proposed roles.** Each is a subagent definition with its own short instructions, and optionally its own model:

| Role | Job | Model idea |
|---|---|---|
| Lead | Frames the question, runs rounds, makes the call | main session |
| Developer | Proposes the concrete implementation | strong model |
| Devil's advocate | Attacks the proposal, finds the failure modes | cheap model |
| Security | Threat-models the change | strong model, only when relevant |
| Thinker | Steps back: is this the right problem? | cheap model |
| Basalt architect | Checks against the design doc's invariants (B1–B15) | cheap model + design doc |

**Cost: the real risk, and how to cap it.** Every subagent starts from zero and has to read its brief. Five roles × two rounds = ten agent runs, each costing roughly as much as a small fresh session. Kept to hard decisions only, it's a handful of runs per project, which is fine. On top of that:
1. **Few roles.** The lead picks 2–3 roles for the question, not all of them.
2. **Fixed rounds.** Default two rounds, then the lead decides.
3. **Short briefs.** Role agents get a one-page brief (the question plus the relevant excerpts), not the whole repo.
4. **Cheap models** for critique roles. The `model` field on each subagent definition sets this.
5. **A visible budget.** Print a rough cost estimate before starting, and the actual usage at the end.

**Ties to idea 3:** each council member is a mini mascot in its role colour, so you can watch the discussion happen.

**Open questions:**
- Shared transcript or live agent teams? (Recommendation: transcript first.)
- Should the agent suggest a council at all, or should it be purely your call when to start one?
- Which roles are worth having at all? Start with three and add more only if they earn it?

---

## Repo layout (modelled on `moku-labs/claude`)

Moku's plugin repo is itself a marketplace: it contains `.claude-plugin/marketplace.json` pointing at `./`. Users install it with `/plugin marketplace add moku-labs/claude`. Ours would work the same way: `/plugin marketplace add basalt-js/claude`, then `/plugin install basalt@basalt`.

```
claude/                          github.com/basalt-js/claude
  .claude-plugin/
    plugin.json                  name "basalt", version, description
    marketplace.json             makes the repo installable as a marketplace
  commands/                      one file per slash command
    init.md                      /basalt:init       → new project with @basalt-js/ci tooling
    plan.md                      /basalt:plan       → roadmap.md
    continue.md                  /basalt:continue   → next phase
    status.md                    /basalt:status     → where are we (read-only)
    check.md                     /basalt:check      → diagnostics, token footprint
    interface.md                 /basalt:interface  → start the mascot overlay
    council.md                   /basalt:council    → hard-decision discussion
    lessons.md                   /basalt:lessons    → review and prune lessons
  agents/                        subagents, e.g. the council roles
    council-developer.md
    council-devils-advocate.md
    council-security.md
    ...
  references/
    plain-language-arguments.md  shared rules for free-text arguments (D7a)
  templates/                     roadmap.md, progress.md
  skills/                        knowledge loaded on demand, index first (D7b)
    basalt-core/                 the kernel API: the core design doc, split by section, with an index (P1.5)
    basalt-plugin/               plugin tiers and file contracts
  scripts/
    sync-basalt-core.sh          refreshes skills/basalt-core from basalt-js/core (P1.5)
  hooks/
    hooks.json                   which script runs on which event
    mascot-state.sh              writes .basalt/session/state.json (idea 3)
    session-start.sh             loads progress.md and the lessons index
    precompact-progress.sh       re-injects progress before compaction
  mascot/                        the overlay app (D5); per-OS builds ship as release downloads
  README.md
  CHANGELOG.md
```

**Worth copying from moku:**
- **`next` and `status` commands.** Moku's `/moku:next` detects the project state and runs the next step, which is the same idea as `/basalt:continue`. Its `/moku:status` is a read-only "where are we".
- **Compaction hooks.** Moku re-injects a bounded slice of its state file before Claude Code compacts the conversation, so long sessions don't lose track. Useful even with phase-sized sessions.
- **Spec grounding.** Every moku command points the agent at its vendored spec before any architectural decision. Ours would point at the Basalt design doc the same way.
- **Commands only you can run.** Moku marks its commands `disable-model-invocation: true`, so the model can't start a build or a brainstorm by itself. `/basalt:council` should work this way, since it's the expensive one.

**One deliberate difference:** moku keeps its `.planning/` state local-only and never commits it. We'd commit `roadmap.md` and `progress.md`, so `/basalt:continue` works on any machine and for anyone on the team. Only `.basalt/session/` stays local.

---

## Commands, and what we took from moku's

Every `/moku:*` command (moku v0.60.0) was reviewed against this design. Moku's `/moku:build` runs one wave per invocation by default and stops "to prevent context exhaustion", which is the same choice as D1.

### The command set

| Command | When | What it does |
|---|---|---|
| `/basalt:init` | M1 (D6) | Sets up a new Basalt project: installs `@basalt-js/ci` and extends its Biome, ESLint and TypeScript configs, adds the standard scripts, then hands over to `/basalt:plan`. |
| `/basalt:plan` | M1, built | Asks, drafts and gets approval for the roadmap. Later gains `--deep` (research before drafting) and a `migrate` verb. |
| `/basalt:continue` | M1, built | Does one phase, checks, commits, updates progress, stops. Offers an unattended run (D7c). |
| `/basalt:status` | M1, built | Read-only position report. |
| `/basalt:check` | M1 (D6) | Diagnostics: the install, tooling versions, whether roadmap, progress and git agree. `check usage` reports the plugin's token footprint. Once `app.inspect()` exists (core M5): the plugin dependency graph and events nobody listens to. |
| `/basalt:interface` | M2–M3 | Starts the mascot overlay. |
| `/basalt:lessons` | M4 | Lists, reviews and prunes lessons. |
| `/basalt:council` | M5 | Hard-decision discussion (D2). |
| `/basalt:plan migrate` | Later | A roadmap for porting existing code. First target: **Moku → Basalt**, using the mapping table in the core design doc (§19). |
| `/basalt:upgrade` | Later, after core's first breaking release | Moves a project to newer `@basalt-js/*` versions and applies the code changes they need, from a migration list. |
| `/basalt:design`, `/basalt:e2e` | Later, with `@basalt-js/web` | UI design exploration and browser testing. They are web-specific. |

### Moku commands we don't copy as commands

| moku | Instead |
|---|---|
| `brainstorm` | `/basalt:plan --deep` for unclear projects; the council for hard decisions. |
| `build`, `next` | Both are `/basalt:continue`. From `build` we take three things: a `--continue` flag that keeps going but pauses on its own when the conversation gets large; a cheap review of the phase's changes before committing; and stopping when the same error keeps coming back after fixes. |
| `clean` | Our state is committed and permanent, so there's nothing temporary to delete. We take its summary idea: when the last milestone finishes, `/basalt:continue` writes a short cycle summary to `.basalt/history.md`, which also feeds lessons. |

### Conventions for every command (D7)

**a. Plain-language arguments.** Every command accepts free text as well as exact arguments: `/basalt:plan a blog with markdown posts`, `/basalt:check is my tooling up to date`. The command maps the text onto its arguments, echoes one line, `Interpreting as: …`, and carries on. It asks only for a missing required value, never for a restatement. Exact arguments are used as given, with no echo. Plain language never skips an approval step. The rules live in one shared file, `references/plain-language-arguments.md`, which every command points to.

**b. Index first, read on demand.** The plugin bundles Basalt's knowledge (the core design doc, later the framework specs and tooling versions) in a skill, split into sections with a short index. Commands and agents read the index and open only the section they need, so the bundled docs cost almost nothing until used. Every command that makes an architecture decision is told to consult the index first and cite the section it relied on, as moku does with its spec.

**c. Unattended runs, opt-in.** `/basalt:continue` can offer a ready-to-paste `/goal` line (Claude Code v2.1.139+) that keeps running phases until a condition holds or a turn cap is reached. For example: "progress.md shows M1 done, or stop after 30 turns". It is never the default: running several phases in one session grows that session, which is what D1 avoids. When it is used, the session still pauses on its own when the conversation gets large.

---

## Suggested order

| # | Build | Why this order |
|---|---|---|
| 1 | `/basalt:plan` + `progress.md` + `/basalt:continue`, then `/basalt:init` and `/basalt:check` | The core workflow every project uses; cheapest; no dependencies |
| 2 | Mascot v1 in the status line, then the overlay | Zero token cost; the hook wiring is reused by everything else |
| 3 | Lessons captured at phase boundaries + review | Builds on the phase boundaries from #1 |
| 4 | `/basalt:council` with 3 roles and 2 rounds | Only needed for hard projects; the budget rules need real usage to tune |

The plugin could start alongside kernel work (M2+). Its commands don't depend on the kernel, except for the `inspect()`-based parts, which need M5.
