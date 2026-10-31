#!/usr/bin/env bash
# Sets up a new Basalt project in a folder: the files /basalt:init writes (P1.6).
#
# Usage:
#   bash init-project.sh --kind <package|app> --name <npm name> [--description <text>]
#                        [--repo <owner/name>] [--dir <folder>] [--no-install] [--no-check]
#
#   --kind         package: published to npm (build, package validation, size gate, release
#                  workflow). app: not published (private, no build job).
#   --repo         GitHub repo, for package.json's repository, homepage and bugs fields.
#   --dir          folder to set up (default: the current one). Created if missing.
#   --no-install   write the files only; skip installing and the check. For tests.
#   --no-check     install, but don't run `bun run check`.
#
# Versions are never hard-coded. @basalt-js/ci is the latest published one. Its peers
# (Biome, ESLint, TypeScript) get the versions ci itself is tested with, read from its
# package.json; the other tools get their latest. The CI workflow's TypeScript and Bun
# versions follow what was installed.
#
# Needs bash, git and bun. Exit codes: 0 done, 1 install or check failed, 2 bad usage or
# the folder already has files this would overwrite.

set -u

root=$(cd "$(dirname "$0")/.." && pwd)
templates="$root/templates/init"
kind=
name=
description=
repo=
dir=.
install=1
check=1

usage() { sed -n '4,13p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
die() { printf '%s\n' "$1" >&2; exit "${2:-2}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --kind) kind=${2:-}; shift 2 || usage ;;
    --name) name=${2:-}; shift 2 || usage ;;
    --description) description=${2:-}; shift 2 || usage ;;
    --repo) repo=${2:-}; shift 2 || usage ;;
    --dir) dir=${2:-}; shift 2 || usage ;;
    --no-install) install=0; check=0; shift ;;
    --no-check) check=0; shift ;;
    -h|--help) usage ;;
    *) printf 'unknown argument: %s\n' "$1" >&2; usage ;;
  esac
done

# --- Validate ---------------------------------------------------------------

case "$kind" in package|app) ;; *) die "--kind must be package or app" ;; esac
printf '%s' "$name" | grep -Eq '^(@[a-z0-9~-][a-z0-9._~-]*/)?[a-z0-9~-][a-z0-9._~-]*$' \
  || die "--name must be a valid npm package name, such as my-lib or @acme/my-lib"
[ -z "$repo" ] || printf '%s' "$repo" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$' \
  || die "--repo must look like owner/name"
case "$description" in *"
"*) die "--description must be one line" ;; esac
command -v git >/dev/null 2>&1 || die "needs git"
command -v bun >/dev/null 2>&1 || die "needs bun (https://bun.sh)"

mkdir -p "$dir" && cd "$dir" || die "can't use folder $dir"

# Template path -> project path: a "dot-" prefix on any part becomes "." (dot-github -> .github).
target_of() { printf '%s' "$1" | sed 's|^dot-|.|; s|/dot-|/.|g'; }

files=$( (cd "$templates/common" && find . -type f; cd "$templates/$kind" && find . -type f) \
  | sed 's|^\./||' | sort -u)

# Never overwrite. README.md and .gitignore are kept if present (.gitignore gets our lines).
conflicts=
for t in package.json .bun-version; do [ -e "$t" ] && conflicts="$conflicts $t"; done
for f in $files; do
  t=$(target_of "$f")
  case "$t" in README.md|.gitignore) continue ;; esac
  [ -e "$t" ] && conflicts="$conflicts $t"
done
[ -z "$conflicts" ] || die "this folder already has:$conflicts. /basalt:init only sets up new projects."

# --- Write the files --------------------------------------------------------

# Escapes a value for the right-hand side of a sed s||| command.
esc() { printf '%s' "$1" | sed 's/[\\&|]/\\&/g'; }

# Replaces {{key}} placeholders in file $1 with the given key=value pairs.
fill() {
  local file=$1 script= pair
  shift
  for pair in "$@"; do script="$script s|{{${pair%%=*}}}|$(esc "${pair#*=}")|g;"; done
  sed "$script" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

[ -d .git ] || git init -q -b main . || die "git init failed" 1

for f in $files; do
  src="$templates/$kind/$f"
  [ -f "$src" ] || src="$templates/common/$f"
  t=$(target_of "$f")
  if [ "$t" = .gitignore ] && [ -e .gitignore ]; then
    # Keep the user's file; add the lines it lacks, starting on a new line.
    [ -s .gitignore ] && [ -n "$(tail -c 1 .gitignore)" ] && printf '\n' >> .gitignore
    while IFS= read -r line; do
      [ -z "$line" ] || tr -d '\r' < .gitignore | grep -qxF -- "$line" || printf '%s\n' "$line" >> .gitignore
    done < "$src"
    continue
  fi
  [ "$t" = README.md ] && [ -e README.md ] && continue
  mkdir -p "$(dirname "$t")"
  cp "$src" "$t"
  fill "$t" "name=$name" "description=${description:-A Basalt project.}"
done

bun_version=$(bun --version)
printf '%s\n' "$bun_version" > .bun-version

KIND=$kind NAME=$name DESCRIPTION=$description REPO=$repo BUN_VERSION=$bun_version \
  bun -e '
  const { KIND, NAME, DESCRIPTION, REPO, BUN_VERSION } = process.env;
  const pkg = { name: NAME, version: "0.0.0" };
  if (DESCRIPTION) pkg.description = DESCRIPTION;
  pkg.type = "module";
  if (REPO) {
    pkg.repository = { type: "git", url: `git+https://github.com/${REPO}.git` };
    pkg.homepage = `https://github.com/${REPO}#readme`;
    pkg.bugs = { url: `https://github.com/${REPO}/issues` };
  }
  const shared = {
    typecheck: "tsc --noEmit",
    lint: "biome check . && eslint .",
    "lint:fix": "biome check --write . && eslint --fix .",
    format: "biome format --write .",
    test: "vitest run",
    "test:coverage": "vitest run --coverage"
  };
  if (KIND === "package") {
    Object.assign(pkg, {
      main: "./dist/index.cjs",
      module: "./dist/index.mjs",
      types: "./dist/index.d.mts",
      exports: {
        ".": {
          import: { types: "./dist/index.d.mts", default: "./dist/index.mjs" },
          require: { types: "./dist/index.d.cts", default: "./dist/index.cjs" }
        }
      },
      sideEffects: false,
      files: ["dist", "README.md"],
      engines: { node: ">=24.0.0", bun: `>=${BUN_VERSION}` },
      publishConfig: { access: "public" },
      scripts: {
        build: "tsdown",
        ...shared,
        validate: "publint && attw --pack . --profile node16",
        size: "basalt-size dist/index.mjs --max 12kb",
        check: "bun run typecheck && bun run lint && bun run test:coverage && bun run build && bun run validate && bun run size"
      }
    });
  } else {
    Object.assign(pkg, {
      private: true,
      engines: { node: ">=24.0.0", bun: `>=${BUN_VERSION}` },
      scripts: { ...shared, check: "bun run typecheck && bun run lint && bun run test:coverage" }
    });
  }
  pkg.trustedDependencies = ["lefthook"];
  await Bun.write("package.json", JSON.stringify(pkg, null, 2) + "\n");
' || die "couldn't write package.json" 1

if [ "$install" -eq 0 ]; then
  printf 'Wrote the %s files for %s (not installed).\n' "$kind" "$name"
  exit 0
fi

# --- Install, at versions looked up now -------------------------------------

bun add -d @basalt-js/ci || die "couldn't install @basalt-js/ci" 1

# ci's peers at the versions ci is tested with (its devDependencies), within the peer range.
peers=$(bun -e '
  const ci = await Bun.file("node_modules/@basalt-js/ci/package.json").json();
  for (const [dep, range] of Object.entries(ci.peerDependencies ?? {}))
    console.log(`${dep}@${ci.devDependencies?.[dep] ?? range}`);
') || die "couldn't read @basalt-js/ci's peers" 1

tools="vitest lefthook"
[ "$kind" = package ] && tools="$tools tsdown publint @arethetypeswrong/cli"
# shellcheck disable=SC2086 # word splitting is the point
bun add -d $peers $tools || die "couldn't install the tools" 1

version_of() { bun -e "console.log((await Bun.file('node_modules/$1/package.json').json()).version)"; }
vitest_version=$(version_of vitest)
bun add -d "@vitest/coverage-istanbul@$vitest_version" || die "couldn't install vitest coverage" 1

biome_version=$(version_of @biomejs/biome)
ts_version=$(version_of typescript)
fill biome.json "biome_version=$biome_version"
fill .github/workflows/ci.yml "bun_version=$bun_version" "ts_minor=${ts_version%.*}"
bunx biome format --write package.json >/dev/null || die "couldn't format package.json" 1

printf '\nInstalled @basalt-js/ci %s with Biome %s, TypeScript %s, Vitest %s (Bun %s).\n' \
  "$(version_of @basalt-js/ci)" "$biome_version" "$ts_version" "$vitest_version" "$bun_version"

if [ "$check" -eq 1 ]; then
  bun run check || die "bun run check failed" 1
  printf '\nbun run check passes.\n'
fi
