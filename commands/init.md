---
description: Set up a new Basalt project in this folder (tooling, CI, PR review, main protection), then hand over to /basalt:plan.
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
argument-hint: [package|app] [npm name] ["description"]
disable-model-invocation: true
---

# /basalt:init

Turn this folder into a Basalt project whose `bun run check` passes: the shared `@basalt-js/ci` tooling and its configs, the standard scripts, CI, the Claude PR review and `main` protection. Then hand over to `/basalt:plan`. The files come from `${CLAUDE_PLUGIN_ROOT}/templates/init/` and are written by `${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh`. Use the script; don't write or edit those files by hand.

Versions are never hard-coded. The script installs the latest published `@basalt-js/ci`, gives its peers (Biome, ESLint, TypeScript) the versions `ci` is tested with, and gives the other tools their latest.

## Arguments

The user typed: $ARGUMENTS

Read it by the rules in `${CLAUDE_PLUGIN_ROOT}/references/plain-language-arguments.md`. The exact form is `[package | app] [<npm name>] ["<description>"]`:

- `package`: a library published to npm, such as a framework, a plugin pack or a utility. It gets the build, package validation, the size gate and a release workflow.
- `app`: not published (`private`). It gets no build job and no release workflow.
- `<npm name>`, such as `blog` or `@acme/blog-kit`. Without it, offer the folder's name.
- `"<description>"`: one line for `package.json` and the README. Optional.
- Empty: Step 2 asks for the kind and the name.

In plain words, "library", "framework", "pack" or "package" means `package`, and "app", "site" or "service" means `app`. A name the user gives becomes the name, and the rest is the description.

| The user typed | Read as |
|---|---|
| `/basalt:init a library called @acme/blog-kit for markdown blogs` | `Interpreting as: /basalt:init package @acme/blog-kit "for markdown blogs"` |
| `/basalt:init a site` | `Interpreting as: /basalt:init app`, then ask for the name, offering the folder's |
| `/basalt:init package @acme/kit` | exact: no echo |
| `/basalt:init` in a folder that already has `package.json` | not this command: it's an existing project (see Step 1) |
| `/basalt:init where are we in the roadmap` | not this command: point to `/basalt:status` |

## Step 1: Check the folder and the tools

1. If `package.json` exists, stop: `/basalt:init` sets up new projects only. Point to `/basalt:plan` for a roadmap.
2. List what the folder already has. `.git`, `README.md`, `LICENSE`, `.gitignore`, `CLAUDE.md`, `.claude/` and `.basalt/` are fine: an existing README is kept, and `.gitignore` gets the missing lines. The script refuses to overwrite anything else it would write and names the files.
3. Run `bun --version` and `git --version`. Without bun, tell the user to install it (https://bun.sh) and stop. Without git, stop.
4. Run `gh auth status` and `git remote get-url origin`. Note whether GitHub can be used, and whether a remote already exists.

## Step 2: Ask what's missing

Use AskUserQuestion for every value the arguments don't give, all in one round, with the recommended option first:

- **Kind:** `package` or `app` (see Arguments).
- **Name:** the folder's name, lowercased, as the first option.
- **GitHub**, only when `gh` works:
  - with no remote: create the repo private (recommended), create it public, or skip GitHub. Offer the owners from `gh api user --jq .login` and `gh api user/orgs --jq '.[].login'`.
  - with a remote: use it, or skip the GitHub steps.

Creating a repo is visible outside this machine, so it happens only when the user picks it here.

## Step 3: Write and install

Run the script from the project folder. Pass `--repo <owner>/<name>` when Step 2 gave a GitHub repo:

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh" --kind <kind> --name <name> [--description "<description>"] [--repo <owner>/<name>]
```

It runs `git init` if needed, writes the files, installs the tools and runs `bun run check`. It prints the installed versions.

- **Exit 2:** the folder has files the script would overwrite, or an argument is wrong. Show the message and stop.
- **Exit 1:** installing or the check failed. Show the failing output and find the cause, such as the network, an old bun, or a tool release that broke the shared config. Don't weaken a config or delete a check to get past it. If the cause is in `@basalt-js/ci` or a template, say so and stop.

## Step 4: First commit

Commit everything on `main`: `git add -A`, then `git commit -m "chore: set up the project with /basalt:init"`. The lefthook pre-commit hook runs Biome, ESLint, the typecheck and the tests. It must pass; never use `--no-verify`.

This first commit is the only one that goes to `main` directly, because the repo has no `main` to protect yet. From here on, every change lands through a pull request (D8).

## Step 5: GitHub

Skip this step if the user chose to skip GitHub.

1. **Push.** For a new repo, run `gh repo create <owner>/<name> --private|--public --source . --remote origin --push`. With an existing remote, first check that it has no `main` yet (`git ls-remote --heads origin main` prints nothing), then `git push -u origin main`. If the remote already has a `main`, stop and ask the user.
2. **Review secret.** The `claude / review` check needs the `CLAUDE_CODE_OAUTH_TOKEN` or `ANTHROPIC_API_KEY` secret. Run `gh secret list`. If neither is listed (an organization secret may not show), tell the user to run `claude setup-token` and then `gh secret set CLAUDE_CODE_OAUTH_TOKEN`. Never ask for the token yourself.
3. **Protect `main`.** Require a pull request with no approvals, plus these checks: `ci / lint`, `ci / test`, `ci / types (<ts>)` and `claude / review`, and for a `package` also `ci / build`. `<ts>` is the version in `.github/workflows/ci.yml`'s `typescript-versions`, such as `6.0`. Admins can bypass, for emergencies only.

   ```
   gh api -X PUT repos/<owner>/<name>/branches/main/protection --input - <<'EOF'
   {
     "required_status_checks": { "strict": false, "contexts": ["ci / lint", "ci / test", "ci / types (6.0)", "ci / build", "claude / review"] },
     "enforce_admins": false,
     "required_pull_request_reviews": { "required_approving_review_count": 0 },
     "restrictions": null
   }
   EOF
   ```

   If GitHub refuses with 403 because a private repo on a free plan can't have protection, tell the user. Their options are making the repo public or a paid plan. Go on without protection.
4. **First CI run.** Wait for the CI run that the push started: `gh run list --limit 1`, then `gh run watch <id> --exit-status`. Report whether it passed. The review only runs on pull requests, so it doesn't run here.
5. **Releases, packages only.** Tell the user that `publish.yml` publishes through npm Trusted Publishing, which they set up once on npmjs.com for this repo and the `publish.yml` workflow.

## Step 6: Hand over

Tell the user, in a few lines:

- the kind, the name and the installed versions the script printed;
- that `bun run check` passes, plus the first commit, and the repo URL and CI result if GitHub was used;
- anything left for them to do (the review secret, protection on a private repo, npm Trusted Publishing).

Then tell them to run `/basalt:plan` next, to write the roadmap. The project is a Basalt project now (it depends on `@basalt-js/ci`), so the plan will consult the Basalt design index.
