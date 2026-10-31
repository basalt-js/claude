#!/usr/bin/env bash
# Refreshes skills/basalt-core from basalt-js/core's design doc (D7b).
#
# Splits docs/basalt-design.md into one file per section under references/sections/
# and rewrites the generated block of references/index.md. Everything outside that
# block (the routing table, the rules) is written by hand and kept as it is.
#
# Usage:
#   bash scripts/sync-basalt-core.sh [--ref <branch|tag|sha>] [--check]
#   bash scripts/sync-basalt-core.sh --from <file> --sha <sha> [--check]
#
#   --ref    git ref of basalt-js/core to read (default: main), pinned to its commit SHA.
#            Needs gh (preferred) or curl.
#   --from   read a local copy of the doc instead, recorded as commit <sha>.
#   --check  change nothing; exit 1 if the skill differs from the doc.
#   --out    skill folder to write (default: skills/basalt-core). For tests.
#
# Exit codes: 0 done (or up to date), 1 differs (--check) or a routing link is broken,
# 2 bad usage or the doc couldn't be fetched.

set -u
export LC_ALL=C

root=$(cd "$(dirname "$0")/.." && pwd)
repo=basalt-js/core
path=docs/basalt-design.md
ref=main
from=
sha=
check=0
out="$root/skills/basalt-core"

usage() { sed -n '8,19p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --ref) ref=${2:-}; shift 2 || usage ;;
    --from) from=${2:-}; shift 2 || usage ;;
    --sha) sha=${2:-}; shift 2 || usage ;;
    --out) out=${2:-}; shift 2 || usage ;;
    --check) check=1; shift ;;
    -h|--help) usage ;;
    *) printf 'unknown argument: %s\n' "$1" >&2; usage ;;
  esac
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
doc="$tmp/doc.md"

# --- Get the doc ------------------------------------------------------------

if [ -n "$from" ]; then
  [ -f "$from" ] || { printf 'no such file: %s\n' "$from" >&2; exit 2; }
  [ -n "$sha" ] || { printf -- '--from needs --sha\n' >&2; exit 2; }
  cp "$from" "$doc"
else
  # Pin to the last commit that touched the doc, never to the moving ref.
  if command -v gh >/dev/null 2>&1; then
    sha=$(gh api "repos/$repo/commits?path=$path&sha=$ref&per_page=1" --jq '.[0].sha' 2>/dev/null)
  elif command -v curl >/dev/null 2>&1; then
    sha=$(curl -fsSL "https://api.github.com/repos/$repo/commits?path=$path&sha=$ref&per_page=1" 2>/dev/null \
      | sed -n 's/^ *"sha": *"\([0-9a-f]\{40\}\)".*/\1/p' | head -n 1)
  else
    printf 'needs gh or curl\n' >&2; exit 2
  fi
  [ -n "$sha" ] || { printf 'could not resolve %s at %s\n' "$repo" "$ref" >&2; exit 2; }
  if command -v gh >/dev/null 2>&1; then
    gh api "repos/$repo/contents/$path?ref=$sha" -H 'Accept: application/vnd.github.raw' > "$doc" 2>/dev/null
  else
    curl -fsSL "https://raw.githubusercontent.com/$repo/$sha/$path" > "$doc" 2>/dev/null
  fi
  [ -s "$doc" ] || { printf 'could not fetch %s at %s\n' "$path" "$sha" >&2; exit 2; }
fi

# --- Split by section -------------------------------------------------------
#
# A section starts at each "## " heading, and at each "# " heading other than the
# title and the "# Part …" headings; those are the appendices. Part headings only
# group sections in the index.
# Text before the first section (the title block) becomes intro.md. Headings inside
# code fences don't count. "## 19. API at a glance" becomes 19-api-at-a-glance.md;
# unnumbered headings use the slug alone. Trailing blank lines and "---" are dropped.
#
# manifest.tsv: part <TAB> file <TAB> id <TAB> title <TAB> lines <TAB> subheadings

mkdir -p "$tmp/sections"
awk -v dir="$tmp/sections" -v manifest="$tmp/manifest.tsv" '
  # Asides in parentheses and apostrophes are dropped, then at most six words kept:
  # "Planned packages (outline; each gets its own spec)" -> "planned-packages".
  function slug(text,   s, n, words, i, out) {
    s = tolower(text)
    gsub(/\([^)]*\)/, "", s)
    gsub("\047", "", s)
    gsub(/[^a-z0-9]+/, "-", s)
    gsub(/^-+|-+$/, "", s)
    n = split(s, words, "-")
    out = ""
    for (i = 1; i <= n && i <= 6; i++) out = out (i > 1 ? "-" : "") words[i]
    return out
  }
  function flush(   last, i) {
    if (file == "") return
    last = count
    while (last > 0 && (buf[last] ~ /^[ \t]*$/ || buf[last] == "---")) last--
    for (i = 1; i <= last; i++) print buf[i] > (dir "/" file)
    close(dir "/" file)
    printf "%s\t%s\t%s\t%s\t%d\t%s\n", part, file, id, title, last, subs > manifest
    file = ""
  }
  function open_section(heading, level,   text, base, num) {
    flush()
    if (level == 1) part = "Appendices"
    text = substr(heading, level + 2)
    id = ""
    if (match(text, /^[0-9]+\. /)) {
      num = substr(text, 1, RLENGTH - 2)
      id = "§" num
      text = substr(text, RLENGTH + 1)
      base = sprintf("%02d-%s", num + 0, slug(text))
    } else {
      base = slug(text)
    }
    if (base in used) base = base "-" (++used[base])
    used[base] = 1
    file = base ".md"
    title = text
    subs = ""
    count = 0
  }
  BEGIN { part = ""; file = ""; fence = 0; titled = 0 }
  {
    sub(/\r$/, "")
    outside = !fence
    if ($0 ~ /^(```|~~~)/) fence = !fence

    if (outside && $0 ~ /^# Part /) { flush(); part = substr($0, 3); next }
    if (outside && $0 ~ /^# / && !titled) titled = 1
    else if (outside && $0 ~ /^## /) open_section($0, 2)
    else if (outside && $0 ~ /^# /) open_section($0, 1)
    if (outside && $0 ~ /^### /) subs = subs (subs == "" ? "" : " · ") substr($0, 5)

    if (file == "") {
      if ($0 ~ /^[ \t]*$/ || $0 == "---") next
      # The title block, or text right under a Part heading before its first section.
      file = (part == "" ? "intro.md" : slug(part) ".md")
      id = ""; title = (part == "" ? "Title and status" : part " (intro)"); subs = ""; count = 0
    }
    buf[++count] = $0
  }
  END { flush() }
' "$doc"

[ -s "$tmp/manifest.tsv" ] || { printf 'no sections found in %s\n' "$path" >&2; exit 2; }

# --- Build the generated block of the index ---------------------------------

block="$tmp/block.md"
{
  printf '<!-- generated:start: written by scripts/sync-basalt-core.sh, do not edit by hand -->\n'
  printf '> Source: `github.com/%s` `%s` at commit `%s`.\n' "$repo" "$path" "$sha"
  printf '> %d sections, %d lines in all. Refresh with `bash scripts/sync-basalt-core.sh`.\n' \
    "$(wc -l < "$tmp/manifest.tsv" | tr -d ' ')" "$(awk -F '\t' '{ n += $5 } END { print n }' "$tmp/manifest.tsv")"
  printf '\n## Section map\n'
  awk -F '\t' '
    NR == 1 || $1 != part { part = $1; printf "\n### %s\n\n", (part == "" ? "Front matter" : part) }
    {
      name = ($3 == "" ? $4 : $3 " " $4)
      printf "- `sections/%s` **%s** (%d lines)%s\n", $2, name, $5, ($6 == "" ? "" : ": " $6)
    }
  ' "$tmp/manifest.tsv"
  printf '<!-- generated:end -->\n'
} > "$block"

index="$out/references/index.md"
new_index="$tmp/index.md"
if [ -f "$index" ] && grep -q '^<!-- generated:start' "$index" && grep -q '^<!-- generated:end -->' "$index"; then
  awk -v block="$block" '
    /^<!-- generated:start/ { while ((getline line < block) > 0) print line; skip = 1; next }
    /^<!-- generated:end -->/ { skip = 0; next }
    !skip
  ' "$index" > "$new_index"
else
  { printf '# Basalt core design: index\n\n'; cat "$block"; } > "$new_index"
fi

# --- Compare or write -------------------------------------------------------

differs=0
if ! diff -r "$tmp/sections" "$out/references/sections" >/dev/null 2>&1; then differs=1; fi
if ! cmp -s "$new_index" "$index"; then differs=1; fi

if [ "$check" -eq 1 ]; then
  if [ "$differs" -eq 1 ]; then
    printf 'basalt-core differs from %s at %s:\n' "$path" "$sha"
    diff -rq "$out/references/sections" "$tmp/sections" 2>&1 | sed "s|$tmp/||; s|$out/references/||; s/^/  /"
    cmp -s "$new_index" "$index" || printf '  index.md\n'
  else
    printf 'basalt-core is up to date with %s at %s\n' "$path" "$sha"
  fi
else
  mkdir -p "$out/references/sections"
  rm -f "$out/references/sections/"*.md
  cp "$tmp/sections/"*.md "$out/references/sections/"
  cp "$new_index" "$index"
  if [ "$differs" -eq 1 ]; then
    printf 'basalt-core synced to %s at %s (%s sections)\n' "$path" "$sha" "$(wc -l < "$tmp/manifest.tsv" | tr -d ' ')"
  else
    printf 'basalt-core already up to date with %s at %s\n' "$path" "$sha"
  fi
fi

# --- Hand-written links must still point at real sections -------------------

broken=0
for link in $(awk '/^<!-- generated:start/ { skip = 1 } !skip { print } /^<!-- generated:end -->/ { skip = 0 }' "$new_index" \
  | grep -o 'sections/[A-Za-z0-9._-]*\.md' | sort -u); do
  if [ ! -f "$tmp/$link" ]; then
    printf 'broken link in index.md: %s (renamed or removed upstream; fix the routing table)\n' "$link"
    broken=1
  fi
done

[ "$differs" -eq 1 ] && [ "$check" -eq 1 ] && exit 1
[ "$broken" -eq 1 ] && exit 1
exit 0
