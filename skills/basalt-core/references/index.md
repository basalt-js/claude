# Basalt core design: index

Basalt's design doc (`docs/basalt-design.md` in `basalt-js/core`), one file per section. It is the source of truth for the kernel, the frameworks built on it, and the project's decisions. **Don't read it all.** Scan this index, then open only the one or two sections a decision needs.

## Rules

1. **Look it up before deciding.** Before an architecture decision in a Basalt project (API names, plugins, services, config, events, lifecycle, context, errors, packages, repos, tooling), find the section below and open it. Don't decide from memory.
2. **Cite what you relied on**, by section: `core §25`, `core §27.4`, `core Part V (O10)`, `core Appendix B`. Put the citation where the decision is recorded: the roadmap, progress.md's Decisions, a commit or PR body.
3. **Read the status.** Part I describes **Moku**, the baseline, not Basalt. From Part II on, **Decided** means agreed in review, **Decision** a recommendation not yet reviewed, **Open** unresolved. Part V lists every decision and the section it applies to.
4. **Ask before going against it.** A plan that contradicts a Decided item needs the user's approval; name the section.
5. **Inside `basalt-js/core`**, its working copy of `docs/basalt-design.md` may be newer than this one. Use this index to find the section, then read it there.

## Where to look

| I need to… | Open |
|---|---|
| Know the API names, or how a Moku name maps to Basalt | `sections/19-api-at-a-glance.md` |
| Define a framework: global config, events, shared state, services | `sections/20-defineframework.md` |
| Write a plugin, or give it config defaults or a schema | `sections/21-defineplugin.md` |
| Write a service, or choose between a service and a plugin | `sections/22-defineservice.md` |
| Compose a framework; `createApp` options; runtime checks | `sections/23-compose-and-createapp.md` |
| Know what `ctx` holds in each phase; `get` vs `find` vs `has` | `sections/24-context-tiers.md` |
| Pick an event kind: `emit`, `dispatch`, `collect`, `pipe` | `sections/25-events-four-modes.md` |
| Share state between plugins | `sections/26-shared-state.md` |
| Lifecycle: states, init, start, stop, rollback, timeouts, disposal | `sections/27-lifecycle.md` |
| Introspection (`app.inspect()`) | `sections/28-introspection.md` |
| Tracing | `sections/29-tracing.md` |
| Error codes and the message format | `sections/30-validation-rules-and-errors.md` |
| Compile-time rules and how types flow | `sections/31-type-system-plan.md` |
| The kernel's algorithm, step by step | `sections/32-kernel-algorithm.md` |
| Invariants every kernel change must keep (B1–B15) | `sections/33-invariants.md` |
| Goals, non-goals, size budget; what is kept from Moku | `sections/17-goals-and-non-goals.md`, `sections/18-what-basalt-keeps-from-moku.md` |
| Rules every framework package follows | `sections/35-the-basalt-framework-contract.md` |
| Which packages exist or are planned, and what each relies on | `sections/36-planned-packages.md` |
| Which repo code belongs in | `sections/37-repositories.md` |
| Toolchain, lint rules, the size gate | `sections/38-toolchain.md` |
| Kernel test suites and the coverage gate | `sections/39-testing-strategy.md` |
| Milestones | `sections/40-milestones.md` |
| Whether something is already decided, or still open | `sections/decided-in-review.md`, `sections/still-open.md` |
| How Moku does it (the baseline) and what's wrong with it | Part I below; its problems are in `sections/16-findings-quirks-gaps-and-spec-drift.md` |
| The whole API in one prompt-sized summary | `sections/appendix-b-draft-llm-prompt-fragment.md` |

<!-- generated:start: written by scripts/sync-basalt-core.sh, do not edit by hand -->
> Source: `github.com/basalt-js/core` `docs/basalt-design.md` at commit `1a7c21322664ba8f704653b4f55e04bcdd050373`.
> 46 sections, 1090 lines in all. Refresh with `bash scripts/sync-basalt-core.sh`.

## Section map

### Front matter

- `sections/intro.md` **Title and status** (6 lines)
- `sections/how-to-read-this-document.md` **How to read this document** (20 lines)

### Part I — Moku core, reverse-engineered

- `sections/01-what-moku-is.md` **§1 What Moku is** (24 lines)
- `sections/02-package-facts.md` **§2 Package facts** (11 lines)
- `sections/03-the-factory-chain.md` **§3 The factory chain** (32 lines)
- `sections/04-source-map.md` **§4 Source map** (14 lines)
- `sections/05-the-plugin-spec.md` **§5 The plugin spec** (18 lines)
- `sections/06-core-plugins.md` **§6 Core plugins (`createCorePlugin`)** (10 lines)
- `sections/07-kernel-algorithm-createapp.md` **§7 Kernel algorithm — `createApp` (exact order from `core.ts` + `app.ts`)** (22 lines)
- `sections/08-start-stop.md` **§8 `start()` / `stop()`** (5 lines)
- `sections/09-context-tiers.md` **§9 Context tiers** (12 lines)
- `sections/10-events.md` **§10 Events** (14 lines)
- `sections/11-config.md` **§11 Config** (6 lines)
- `sections/12-type-system-techniques.md` **§12 Type-system techniques (Moku's real IP)** (18 lines)
- `sections/13-validation-and-errors.md` **§13 Validation and errors** (15 lines)
- `sections/14-conventions.md` **§14 Conventions (outside the kernel, but part of the product)** (34 lines)
- `sections/15-tooling-and-release.md` **§15 Tooling and release** (7 lines)
- `sections/16-findings-quirks-gaps-and-spec-drift.md` **§16 Findings: quirks, gaps, and spec drift** (31 lines)

### Part II — Basalt kernel

- `sections/17-goals-and-non-goals.md` **§17 Goals and non-goals** (16 lines)
- `sections/18-what-basalt-keeps-from-moku.md` **§18 What Basalt keeps from Moku (non-negotiable)** (12 lines)
- `sections/19-api-at-a-glance.md` **§19 API at a glance** (89 lines): Moku → Basalt mapping
- `sections/20-defineframework.md` **§20 `defineFramework` (Layer 2, step 1)** (23 lines)
- `sections/21-defineplugin.md` **§21 `definePlugin`** (59 lines): 21.1 Config: defaults or a schema (O10, decided)
- `sections/22-defineservice.md` **§22 `defineService`** (11 lines)
- `sections/23-compose-and-createapp.md` **§23 `compose` and `createApp`** (39 lines)
- `sections/24-context-tiers.md` **§24 Context tiers** (21 lines)
- `sections/25-events-four-modes.md` **§25 Events: four modes** (44 lines)
- `sections/26-shared-state.md` **§26 Shared state** (29 lines)
- `sections/27-lifecycle.md` **§27 Lifecycle** (73 lines): 27.1 States · 27.2 Init (inside `createApp`) · 27.3 `start()` · 27.4 `stop()` · 27.5 Timeouts and cancellation · 27.6 Disposal
- `sections/28-introspection.md` **§28 Introspection** (36 lines): `app.inspect(options?) → AppManifest`
- `sections/29-tracing.md` **§29 Tracing** (30 lines)
- `sections/30-validation-rules-and-errors.md` **§30 Validation rules and errors** (36 lines)
- `sections/31-type-system-plan.md` **§31 Type-system plan** (22 lines)
- `sections/32-kernel-algorithm.md` **§32 Kernel algorithm (Basalt)** (25 lines)
- `sections/33-invariants.md` **§33 Invariants** (19 lines)

### Part III — Basalt frameworks (Layer 2)

- `sections/34-the-moku-family-as-reference.md` **§34 The Moku family as reference** (17 lines)
- `sections/35-the-basalt-framework-contract.md` **§35 The Basalt framework contract** (14 lines)
- `sections/36-planned-packages.md` **§36 Planned packages (outline; each gets its own spec)** (27 lines)

### Part IV — Repo, tooling, delivery

- `sections/37-repositories.md` **§37 Repositories** (24 lines)
- `sections/38-toolchain.md` **§38 Toolchain** (20 lines)
- `sections/39-testing-strategy.md` **§39 Testing strategy (kernel)** (12 lines)
- `sections/40-milestones.md` **§40 Milestones** (13 lines)

### Part V — Decisions and open questions

- `sections/decided-in-review.md` **Decided in review (2026-10-30)** (20 lines)
- `sections/still-open.md` **Still open** (3 lines)

### Appendices

- `sections/appendix-a-moku-design-decisions-log.md` **Appendix A — Moku design decisions log (condensed, from spec 13 §1)** (19 lines)
- `sections/appendix-b-draft-llm-prompt-fragment.md` **Appendix B — Draft LLM prompt fragment for Basalt** (38 lines)
<!-- generated:end -->
