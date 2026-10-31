# Changelog

## Unreleased

- `/basalt:plan`, `/basalt:continue` and `/basalt:status`: the roadmap-first workflow.
- Roadmap and progress templates.
- Session-start and post-compaction hooks that add the roadmap position to the context.
- Hook tests (`bash tests/run.sh`), run in CI on Linux, macOS and Windows.
- `/basalt:continue` lands each phase as a pull request: a branch per phase, CI and the Claude review must pass, rejected reviews are fixed on the same branch, and the PR is squash-merged only after you approve. An unmerged phase PR is picked up by the next session.
- This repo's PRs get the Claude review (`claude / review`, from `basalt-js/ci`).

### Fixed

- After compaction, a one-line `<!-- -->` comment in progress.md no longer hides the rest of the file.
- The hooks print valid JSON when progress.md contains control characters.
