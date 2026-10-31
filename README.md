# basalt: the Claude Code plugin for Basalt

A Claude Code plugin for projects built with [Basalt](https://github.com/basalt-js/core), the micro-kernel TypeScript plugin framework.

> **Status: M1 (roadmap workflow), in progress.** The mascot overlay, lessons and the council are planned; see [docs/design.md](docs/design.md) and [.basalt/roadmap.md](.basalt/roadmap.md).

## The workflow

Every project starts from a roadmap, and every session does one phase of it. Sessions stay small, so the model never works in a huge, degrading context.

| Command | What it does |
|---|---|
| `/basalt:plan` | Asks what you're building and drafts a roadmap of milestones and phases. Once you approve it, writes `.basalt/roadmap.md` and `.basalt/progress.md`. |
| `/basalt:continue` | Reads where the last session stopped, does the next phase, runs its checks, commits, updates progress, and stops. Run it again in a fresh conversation for the next phase. |
| `/basalt:status` | Shows the current milestone and phase, what's done, and what's next. Changes nothing. |

The plugin also adds the current position to Claude's context when a session starts, and again after a conversation is compacted.

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
| `templates/` | The roadmap and progress templates the commands follow |
| `hooks/` | Session-start and post-compaction context |
| `docs/design.md` | The design: every idea, decision and open question |
| `.basalt/` | This plugin's own roadmap and progress: it is built with its own workflow |

Check the plugin with `claude plugin validate .`.

## License

MIT
