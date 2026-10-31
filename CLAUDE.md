# CLAUDE.md

This repo is the `basalt` Claude Code plugin. Read `docs/design.md` before changing anything: it holds the ideas, decisions (D1–D8) and open questions.

This plugin is built with its own workflow: `.basalt/roadmap.md` is the plan and `.basalt/progress.md` is where work stands. Work one phase at a time, and update both files at each phase boundary as `commands/continue.md` describes.

## Rules

- **Check:** `claude plugin validate .` and `bash tests/run.sh` must pass before calling work done. Change a hook and its tests together.
- **Pull requests only (D8).** Every change goes to a branch and a PR; never push to `main`. CI and the Claude review must pass; a rejected review is fixed on the same branch. Once CI and the review pass, merge with `gh pr merge --squash`, without asking first.
- **Commands are prompts.** Files in `commands/` are instructions the model follows. Write them as direct, numbered steps; say what to do when files are missing or git disagrees.
- **Plain-language arguments (D7a):** every command has an "Arguments" section with its exact form and a few examples, and points to `references/plain-language-arguments.md` for the rules. Change the rules there, not in each command.
- **Bundled knowledge, index first (D7b):** `skills/basalt-core/` holds the core design doc split by section, behind `references/index.md`. Commands that make architecture decisions point to the index, never to a section directly. Never edit `references/sections/` or the generated block of the index by hand: refresh both with `bash scripts/sync-basalt-core.sh` (`--check` reports drift). The rules and the routing table above the generated block are hand-written; the script keeps them and flags links to sections that no longer exist.
- **Commands the model can't start by itself:** every command sets `disable-model-invocation: true`.
- **Hooks are plain bash** with no dependencies beyond bash (no python3, no jq), because they run on users' machines, including Windows with Git Bash. Invoke them as `bash "${CLAUDE_PLUGIN_ROOT}/hooks/<script>.sh"`, so the executable bit doesn't matter. A hook that has nothing to say prints nothing and exits 0.
- **Templates are the contract.** Hooks read the `Current:` and `Last done:` lines of `progress.md`. Change `templates/progress.md` and `hooks/progress-context.sh` together.
- **Versions:** bump `version` in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
