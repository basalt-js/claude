## Decided in review (2026-10-30)

| # | Question | Decision | Where |
|---|---|---|---|
| O1 | Names | `define*` names adopted: `defineFramework`, `compose`, `definePlugin`, `defineService`, `ctx.get`/`ctx.find`, `dispatch`/`collect`/`pipe`. | §19 |
| O2 | Explicit config type on `defineFramework`? | Both: inferred by default, or curried `defineFramework<SiteConfig>()(…)`. | §20 |
| O3 | Restrict `ctx.get` to declared deps? | Yes. Optional deps go in `optionalDepends` and use `ctx.find`. `app.get` stays unrestricted. | §24 |
| O4 | `collect`/`pipe` in the kernel? | Yes. | §25 |
| O5 | Async `createApp`? | Async by default, plus `createAppSync` (delegated to Claude). | §27.2 |
| O6 | Async causality in tracing? | Frameworks may inject a `contextStore`; the kernel works without one. | §29 |
| O7 | Request scope for servers? | Deferred to the `@basalt-js/worker` spec. | §36 |
| O8 | Formal plugin packs? | Yes: `framework.pack(name, plugins)`. | §36 |
| O9 | Monorepo or many repos? | One repo per package. | §37 |
| O10 | Config validation? | Standard Schema libraries (`config: z.object({…})`). Plain default objects still work. | §21.1 |
| O11 | Let apps replace a default plugin? | No. | §17 |
| O12 | Runtime safety checks? | On (`"full"`) by default. `compose` or `createApp` can set `"minimal"`. | §23 |
| O14 | Release tool? | A small custom script in the shared `ci` repo. | §37 |
| O15 | Required config in the `createApp` types? | Yes, for schema fields without defaults that the framework doesn't supply. | §21.1 |
| O16 | Packs with default config, or packs depending on packs? | No and no. | §36 |
| O13 | npm scope and GitHub org? | `basalt-js` on both: packages are `@basalt-js/*`, repos are `github.com/basalt-js/*`. Both orgs created 2026-10-30. (`@basalt` belongs to another, unrelated org.) | §37 |
