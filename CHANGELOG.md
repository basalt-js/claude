# Changelog

## Unreleased

- `/basalt:plan`, `/basalt:continue` and `/basalt:status`: the roadmap-first workflow.
- Roadmap and progress templates.
- Session-start and post-compaction hooks that add the roadmap position to the context.
- Hook tests (`bash tests/run.sh`), run in CI on Linux, macOS and Windows.
- `/basalt:continue` lands each phase as a pull request: a branch per phase, CI and the Claude review must pass, rejected reviews are fixed on the same branch, and the PR is squash-merged once CI and the review pass. An unmerged phase PR is picked up by the next session.
- Plain-language arguments: `/basalt:plan`, `/basalt:continue` and `/basalt:status` map free text onto their arguments, echo `Interpreting as: …`, and ask only for what's missing. `/basalt:continue` takes a phase id and `/basalt:status` a milestone or phase id.
- The `basalt-core` skill: Basalt's design doc split by section behind a short index, refreshed from `basalt-js/core` by `scripts/sync-basalt-core.sh`. `/basalt:plan` and `/basalt:continue` consult the index before architecture decisions in Basalt projects and cite the section they used.
- `/basalt:init`: sets up a new `package` or `app` in an empty folder with the latest `@basalt-js/ci` tooling, CI, the Claude PR review and `main` protection, then hands over to `/basalt:plan`. Tool versions are looked up when it runs.
- This repo's PRs get the Claude review (`claude / review`, from `basalt-js/ci`).

### Fixed

- After compaction, a one-line `<!-- -->` comment in progress.md no longer hides the rest of the file.
- The hooks print valid JSON when progress.md contains control characters.
