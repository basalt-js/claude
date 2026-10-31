# CLAUDE.md

This repo is the `basalt` Claude Code plugin. Read `docs/design.md` before changing anything: it holds the ideas, decisions (D1–D5) and open questions.

This plugin is built with its own workflow: `.basalt/roadmap.md` is the plan and `.basalt/progress.md` is where work stands. Work one phase at a time, and update both files at each phase boundary as `commands/continue.md` describes.

## Rules

- **Check:** `claude plugin validate .` must pass before calling work done.
- **Commands are prompts.** Files in `commands/` are instructions the model follows. Write them as direct, numbered steps; say what to do when files are missing or git disagrees.
- **Commands the model can't start by itself:** every command sets `disable-model-invocation: true`.
- **Hooks are plain bash** with no dependencies beyond bash (no python3, no jq), because they run on users' machines, including Windows with Git Bash. Invoke them as `bash "${CLAUDE_PLUGIN_ROOT}/hooks/<script>.sh"`, so the executable bit doesn't matter. A hook that has nothing to say prints nothing and exits 0.
- **Templates are the contract.** Hooks read the `Current:` and `Last done:` lines of `progress.md`. Change `templates/progress.md` and `hooks/progress-context.sh` together.
- **Versions:** bump `version` in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
