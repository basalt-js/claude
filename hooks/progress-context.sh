#!/usr/bin/env bash
# Adds the roadmap position to Claude's context.
#
#   SessionStart: a short note (current phase, last done, which command to run).
#   PostCompact:  the whole of progress.md (bounded), so a compacted session keeps its place.
#
# Usage: progress-context.sh <SessionStart|PostCompact>
# Prints hookSpecificOutput JSON, or nothing when the project has no .basalt/progress.md.
# No dependencies beyond bash: JSON is escaped by hand.

event="${1:-SessionStart}"
progress="${CLAUDE_PROJECT_DIR:-.}/.basalt/progress.md"
[ -f "$progress" ] || exit 0

# Escape a string for use inside a JSON string literal.
json_escape() {
  local text="$1"
  text="${text//\\/\\\\}"
  text="${text//\"/\\\"}"
  text="${text//$'\t'/\\t}"
  text="${text//$'\r'/}"
  text="${text//$'\n'/\\n}"
  printf '%s' "$text"
}

current=$(grep -m1 '^Current:' "$progress")
last=$(grep -m1 '^Last done:' "$progress")

if [ "$event" = "PostCompact" ]; then
  # Strip the template's HTML comments; cap the size in case the file has grown.
  body=$(sed '/<!--/,/-->/d' "$progress" | head -n 80)
  context="Basalt roadmap state (re-added after compaction). Stay on the current phase.

$body

Full roadmap: .basalt/roadmap.md"
else
  context="This project follows a Basalt roadmap (.basalt/roadmap.md).
${current:-Current: unknown (progress.md has no Current line)}
${last:-Last done: unknown}
To do the next phase, the user runs /basalt:continue. For the position only: /basalt:status."
fi

printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' \
  "$event" "$(json_escape "$context")"
exit 0
