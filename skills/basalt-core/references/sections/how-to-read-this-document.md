## How to read this document

| Part | Contents | Status |
|---|---|---|
| **I — Moku core, reverse-engineered** | How Moku actually works, taken from the source and spec, plus the quirks and spec drift found along the way. | Descriptive. This is the reference baseline. |
| **II — Basalt kernel** | Basalt's kernel: what stays, what changes, and four new capabilities. | Proposed. **Decided** = agreed in review (Part V). **Decision** = a recommendation not yet reviewed. **Open** = unresolved. |
| **III — Basalt frameworks** | Layer-2 packages built on the kernel, modelled on the Moku family. | Outline. Each framework needs its own spec later. |
| **IV — Repo, tooling, delivery** | Toolchain, testing, and milestones. | Proposed. |
| **V — Decisions and open questions** | What was decided in review, and what is still undecided. | — |

**Ground rules already agreed:**

1. **Clean-slate API.** Moku is inspiration. Basalt does not need to stay compatible with it.
2. **Scope** is the kernel *and* the Layer-2 frameworks.
3. **Four additions** on top of the Moku baseline:
   - shared/global state
   - introspection and tracing
   - async init and awaitable events
   - lifecycle robustness
4. **Review decisions** (names, dependencies, events, repos, config schemas, packs, safety checks) are listed in Part V and marked **Decided** where they apply.
