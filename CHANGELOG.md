# Changelog

## Unreleased

- `/basalt:plan`, `/basalt:continue` and `/basalt:status`: the roadmap-first workflow.
- Roadmap and progress templates.
- Session-start and post-compaction hooks that add the roadmap position to the context.
- Hook tests (`bash tests/run.sh`), run in CI on Linux, macOS and Windows.

### Fixed

- After compaction, a one-line `<!-- -->` comment in progress.md no longer hides the rest of the file.
- The hooks print valid JSON when progress.md contains control characters.
