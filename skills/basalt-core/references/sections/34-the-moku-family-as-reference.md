## 34. The Moku family as reference

Taken from the moku plugin's synced docs. Versions are as published.

| Package | Kind | What it is |
|---|---|---|
| `@moku-labs/common` 0.2.1 | Shared infra | `logPlugin` / `envPlugin` core plugins (`ctx.log`, `ctx.env`) and a branded CLI kit (`@moku-labs/common/cli`: palette, box, spinner, `createBrandConsole`, styled prompts). Family rules: no raw `console.*`, no raw `process.env`, no hand-rolled ANSI. |
| `@moku-labs/web` 2.0.1 | Framework | SSG + SPA on Preact with islands. Bundles with `Bun.build` (no Vite). Two entry points: `.` (Node build) and `./browser` (node-free). Isomorphic defaults `site, i18n, router, head, spa`, plus `log`/`env` core plugins. Opt-in `content` (provider shell + `fileSystemContent`), `data` (JSON sidecars), and node-only `build`, `deploy`, `cli`. A route builder `route(pattern).load().render().head().generate()`, with `createUrls` for links. Global `config.mode = ssg \| spa \| hybrid`. Deploys to Cloudflare Pages. |
| `@moku-labs/worker` 0.11.0 | Framework | Cloudflare Workers backend. Defaults `log, env, stage, bindings, server`. Resource plugins `kv, d1, queues, storage (R2), durableObjects`, configured as **keyed maps of named instances** (`app.kv.use("cache")`). **`env` is threaded per call, never stored**, because one isolate serves concurrent requests. `endpoint(path).get(...)`, `defineDurableObject`. Node-only `deploy`/`cli` are tree-shaken. |
| `@moku-labs/room` 0.1.1 | **Plugin pack** | Couch multiplayer: a shared screen plus phones over WebRTC (trystero), with QR join. It never calls `createApp`. The app spreads `roomPlugins.stage` / `roomPlugins.controller` into its own web app. |
| `@moku-labs/ci` | Tooling | `moku-release` release automation. |
| `moku` Claude Code plugin | Tooling | Skills, plus validator, builder, and planner agents that enforce the spec (layers, tiers, JSDoc, tests, web patterns). |

**Family idioms worth keeping:**
- **Multiple `createApp` instances per project.** For example a web build app, a browser SPA app, and a worker server app.
- **One framework per `createApp`.** Frameworks integrate at the edges (HTTP, an `ASSETS` binding). They are never fused into one plugin list.
- **Exact-pinned lockstep versions across the family.** Visible in the docs, and a recurring source of upgrade churn.
