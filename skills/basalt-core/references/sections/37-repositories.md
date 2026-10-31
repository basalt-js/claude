## 37. Repositories

**Decided (O9): one repository per package** under `github.com/basalt-js`, as Moku does. Each package versions and releases on its own.

| Repo | Publishes | Contains |
|---|---|---|
| `core` | `@basalt-js/core` | Kernel `src/`, `tests/{unit,integration,types}`, `spec/NN-*.md`, `llms.txt` |
| `std` | `@basalt-js/std` | Services, tracers, test utilities |
| `web` | `@basalt-js/web` | Web framework |
| `worker` | `@basalt-js/worker` | Workers framework |
| one repo per pack | `@basalt-js/<pack>` | For example a multiplayer pack |
| `ci` | `@basalt-js/ci` | Reusable CI workflows, shared Biome/ESLint config, the custom lint rules (§38), release script, `llms.txt` generator |
| `examples` | — | Sample frameworks and apps; the port of Moku's `tests/sandbox/demo` |

This document moves into the `core` repo and is split into `spec/NN-*.md` once it is stable.

**The cost, and how to contain it.** Separate repos drift. In the Moku family every framework exact-pins core, so each core release forces a release of every framework. Basalt avoids that:

- Frameworks depend on core through a **semver range** (`"@basalt-js/core": "^1.2.0"`), not an exact pin. That only works if core treats its *types* as public API: a type change that breaks a framework is a major version.
- Each framework's CI runs a nightly job against core's `main`, so breakage shows up before core releases.
- Dependabot or Renovate opens PRs for `@basalt-js/*` bumps, as in Moku.
- Every repo uses the same gates through the shared `ci` repo.

**Release tool (O14, decided):** a small custom script in the `ci` repo, as Moku does with `moku-release`. Every repo calls it from the shared release workflow.
