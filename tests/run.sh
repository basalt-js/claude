#!/usr/bin/env bash
# Tests for hooks/progress-context.sh.
#
# Usage: bash tests/run.sh
# Needs node to parse the hook's JSON. The hook itself needs only bash.
# HOOK_BASH picks the bash that runs the hook (default: bash), e.g. /bin/bash for 3.2 on macOS.

set -u

root=$(cd "$(dirname "$0")/.." && pwd)
hook="$root/hooks/progress-context.sh"
hook_bash="${HOOK_BASH:-bash}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

passed=0
failed=0

pass() { passed=$((passed + 1)); printf 'ok   %s\n' "$1"; }
fail() { failed=$((failed + 1)); printf 'FAIL %s\n     %s\n' "$1" "$2"; }

# New project folder with the given progress.md content ($2 may be empty for no file).
project() {
  local dir="$tmp/$1"
  mkdir -p "$dir/.basalt"
  [ -n "${2:-}" ] && printf '%s' "$2" > "$dir/.basalt/progress.md"
  printf '%s' "$dir"
}

# Runs the hook in project $1 with event argument $2 (omitted when empty).
run_hook() {
  if [ -n "${2:-}" ]; then
    CLAUDE_PROJECT_DIR="$1" "$hook_bash" "$hook" "$2"
  else
    CLAUDE_PROJECT_DIR="$1" "$hook_bash" "$hook"
  fi
}

# Reads hook JSON on stdin and prints hookSpecificOutput.<field>; exits 1 if the JSON is invalid.
json_field() {
  node -e '
    let input = require("fs").readFileSync(0, "utf8");
    try { input = JSON.parse(input); } catch (e) { console.error(e.message); process.exit(1); }
    process.stdout.write(String(input.hookSpecificOutput[process.argv[1]]));
  ' "$1"
}

# Checks that $3 (the text) contains $2; $1 names the test.
expect_contains() {
  case "$3" in
    *"$2"*) pass "$1" ;;
    *) fail "$1" "missing: $2" ;;
  esac
}

expect_lacks() {
  case "$3" in
    *"$2"*) fail "$1" "unexpected: $2" ;;
    *) pass "$1" ;;
  esac
}

sample='Current: M1 → P1.2 Hook tests (next)
Last done: P1.1 Scaffold (c2c5f3d)

## State

Branch main, clean.
'

# --- No progress file -------------------------------------------------------

dir=$(project empty)
for event in SessionStart PostCompact; do
  out=$(run_hook "$dir" "$event"); code=$?
  [ "$code" -eq 0 ] && [ -z "$out" ] \
    && pass "no progress file, $event: silent, exit 0" \
    || fail "no progress file, $event: silent, exit 0" "exit $code, output: $out"
done

out=$(CLAUDE_PROJECT_DIR="$tmp/does-not-exist" "$hook_bash" "$hook" SessionStart); code=$?
[ "$code" -eq 0 ] && [ -z "$out" ] \
  && pass "missing project folder: silent, exit 0" \
  || fail "missing project folder: silent, exit 0" "exit $code, output: $out"

# --- SessionStart -----------------------------------------------------------

dir=$(project start "$sample")
json=$(run_hook "$dir" SessionStart)
if event=$(printf '%s' "$json" | json_field hookEventName); then
  pass "SessionStart: valid JSON"
  [ "$event" = SessionStart ] && pass "SessionStart: event name" || fail "SessionStart: event name" "got $event"
  context=$(printf '%s' "$json" | json_field additionalContext)
  expect_contains "SessionStart: current phase (UTF-8 kept)" 'Current: M1 → P1.2 Hook tests (next)' "$context"
  expect_contains "SessionStart: last done" 'Last done: P1.1 Scaffold (c2c5f3d)' "$context"
  expect_contains "SessionStart: names the command" '/basalt:continue' "$context"
  expect_lacks "SessionStart: short note, not the whole file" '## State' "$context"
else
  fail "SessionStart: valid JSON" "$json"
fi

event=$(run_hook "$dir" | json_field hookEventName)
[ "$event" = SessionStart ] && pass "no argument: defaults to SessionStart" || fail "no argument: defaults to SessionStart" "got $event"

dir=$(project start-bare 'Some notes without the two lines.
')
context=$(run_hook "$dir" SessionStart | json_field additionalContext)
expect_contains "SessionStart, no Current line: says unknown" 'Current: unknown' "$context"
expect_contains "SessionStart, no Last done line: says unknown" 'Last done: unknown' "$context"

# --- PostCompact ------------------------------------------------------------

dir=$(project compact "$(cat "$root/templates/progress.md")")
json=$(run_hook "$dir" PostCompact)
if event=$(printf '%s' "$json" | json_field hookEventName); then
  pass "PostCompact: valid JSON"
  [ "$event" = PostCompact ] && pass "PostCompact: event name" || fail "PostCompact: event name" "got $event"
  context=$(printf '%s' "$json" | json_field additionalContext)
  expect_contains "PostCompact: whole file" '## Read first next time' "$context"
  expect_contains "PostCompact: points to the roadmap" '.basalt/roadmap.md' "$context"
  expect_lacks "PostCompact: template comment removed" 'Rules for writing this file' "$context"
  expect_lacks "PostCompact: comment markers removed" '<!--' "$context"
else
  fail "PostCompact: valid JSON" "$json"
fi

dir=$(project compact-inline 'Current: a
Last done: b
<!-- a one-line comment -->
## State
kept after the one-line comment
<!--
several
lines
-->
kept after the block comment
')
context=$(run_hook "$dir" PostCompact | json_field additionalContext)
expect_contains "PostCompact: one-line comment doesn't swallow the rest" 'kept after the one-line comment' "$context"
expect_contains "PostCompact: text after a block comment kept" 'kept after the block comment' "$context"
expect_lacks "PostCompact: one-line comment removed" 'a one-line comment' "$context"
expect_lacks "PostCompact: block comment removed" 'several' "$context"

long=''
for i in $(seq 1 200); do long="${long}line $i
"; done
dir=$(project compact-long "$long")
context=$(run_hook "$dir" PostCompact | json_field additionalContext)
expect_contains "PostCompact: keeps line 80" 'line 80
' "$context"
expect_lacks "PostCompact: capped at 80 lines" 'line 81
' "$context"

# --- JSON escaping ----------------------------------------------------------

tricky=$(printf 'Current: say "hi" in C:\\path\\to\\x\tTAB\r\nLast done: esc\033[31m ff\014 bell\007 end\r\n')
dir=$(project escape "$tricky")
for event in SessionStart PostCompact; do
  json=$(run_hook "$dir" "$event")
  if context=$(printf '%s' "$json" | json_field additionalContext); then
    pass "escaping, $event: valid JSON"
    expect_contains "escaping, $event: quotes, backslashes, tab" "$(printf 'say "hi" in C:\\path\\to\\x\tTAB')" "$context"
    expect_lacks "escaping, $event: carriage returns dropped" $'\r' "$context"
    expect_contains "escaping, $event: other control characters dropped" 'esc[31m ff bell end' "$context"
  else
    fail "escaping, $event: valid JSON" "$json"
  fi
done

# --- Template contract ------------------------------------------------------

for line in 'Current:' 'Last done:'; do
  grep -q "^$line" "$root/templates/progress.md" \
    && pass "template: has the '$line' line the hook reads" \
    || fail "template: has the '$line' line the hook reads" "no line starting with $line"
done

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
