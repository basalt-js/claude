# basalt: the Claude Code plugin for Basalt

A Claude Code plugin for projects built with [Basalt](https://github.com/basalt-js/core), the micro-kernel TypeScript plugin framework.

> **Status: M1 (roadmap workflow), in progress.** The mascot overlay, lessons and the council are planned; see [docs/design.md](docs/design.md) and [.basalt/roadmap.md](.basalt/roadmap.md).

## The workflow

Every project starts from a roadmap, and every session does one phase of it. Sessions stay small, so the model never works in a huge, degrading context.

Every command takes plain words as well as its exact arguments, for example `/basalt:status what's left in content`. The command prints one line, `Interpreting as: /basalt:status M2`, and carries on, asking only for what it can't work out.

| Command | What it does |
|---|---|
| `/basalt:init` | Sets up a new project in an empty folder: the latest `@basalt-js/ci` tooling with its Biome, ESLint and TypeScript configs, the standard scripts, CI, the Claude PR review and `main` protection. Ends with `bun run check` passing, then hands over to `/basalt:plan`. |
| `/basalt:plan` | Asks what you're building and drafts a roadmap of milestones and phases. Once you approve it, writes `.basalt/roadmap.md` and `.basalt/progress.md`. |
| `/basalt:continue` | Reads where the last session stopped and does the next phase on its own branch. It runs the phase's checks, updates progress, and opens a pull request. It fixes what CI or the Claude review rejects, squash-merges once both pass, and stops. Run it again in a fresh conversation for the next phase. |
| `/basalt:status` | Shows the current milestone and phase, what's done, and what's next. Changes nothing. |

The plugin also adds the current position to Claude's context when a session starts, and again after a conversation is compacted.

It bundles Basalt's design doc as the `basalt-core` skill: one file per section behind a short index. Before an architecture decision in a Basalt project, the commands read the index, open only the section they need, and cite it (`core §25`), so the doc costs almost nothing until it's used.

`.basalt/roadmap.md` and `.basalt/progress.md` are plain markdown, meant to be committed, so any machine or teammate can continue the work.

## Install

```
/plugin marketplace add basalt-js/claude
/plugin install basalt@basalt
```

## Repository

| Path | Contents |
|---|---|
| `.claude-plugin/` | Plugin and marketplace manifests |
| `commands/` | The `/basalt:*` commands |
| `templates/` | The roadmap and progress templates the commands follow, and `init/`, the files `/basalt:init` writes |
| `references/` | Rules every command shares, such as how plain-language arguments are read |
| `skills/basalt-core/` | The core design doc, split by section, with an index |
| `scripts/init-project.sh` | Writes and installs a new project for `/basalt:init` |
| `scripts/sync-basalt-core.sh` | Refreshes `skills/basalt-core/` from `basalt-js/core` |
| `hooks/` | Session-start and post-compaction context |
| `docs/design.md` | The design: every idea, decision and open question |
| `.basalt/` | This plugin's own roadmap and progress: it is built with its own workflow |

Check the plugin with `claude plugin validate .` and `bash tests/run.sh`.

## License

MIT
