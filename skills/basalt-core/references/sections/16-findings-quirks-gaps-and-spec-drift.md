## 16. Findings: quirks, gaps, and spec drift

> These come from **reading the source** at `f011a48`. I couldn't execute probe scripts in this session, so treat the runtime behaviours as source-derived and confirm them with a test when you port them. Each row links to how Basalt answers it.

| # | Finding | Evidence | Basalt |
|---|---|---|---|
| Q1 | `hooks(ctx)` runs **before any regular API is built**. Calling `ctx.require(x)` eagerly in the hooks factory body returns a frozen `{}` instead of x's API. It works lazily, inside handlers. | `app.ts` kernel steps 8b→9. `createRequire` returns `EMPTY_API` for registered names that have no API yet. | §32: build APIs first, then hooks |
| Q2 | During `api()`, `require`-ing a registered plugin whose API isn't built yet (a later plugin, or itself) **silently returns `{}`**. A method call on it then fails with a confusing `TypeError`. | `createRequire` | §24: `E_NOT_READY` |
| Q3 | `onInit` is typed `=> void`, so TypeScript accepts an `async` function. The kernel ignores the returned promise, so a rejection becomes an unhandled rejection and `createApp` returns before the init work finishes. | `kernel` step 10 | §27: async init |
| Q4 | If `start()` fails: `started` stays `false`, so `stop()` throws "not started" and the plugins that already started **cannot be torn down**. Calling `start()` again **re-runs `onStart`** on everything, including plugins that already started. | `buildApp.start` | §27: rollback |
| Q5 | `stop()` never flips state: calling it twice runs every `onStop` twice, and `start()` after `stop()` throws "already started". The first `onStop` error aborts the rest of teardown. | `buildApp.stop` | §27: state machine, best-effort stop |
| Q6 | The consumer `onStop` runs **after** every plugin and core plugin has stopped, yet its context exposes all plugin APIs. | `buildApp.stop` | §27: app callbacks stop first |
| Q7 | `events()` is **never called**. The descriptions passed to `register("…")` are unavailable at runtime, so there is no event catalog, even though spec 14 §5 lists "carries runtime metadata" as a benefit. | `plugin.ts` §6 docs; only `assertValidEvents` touches it | §28: catalog |
| Q8 | With no `onError` at either layer, hook errors are **silently discarded**. | `buildEventBus` | §25: default reporter |
| Q9 | `emit()` runs the first handler synchronously and later handlers asynchronously. Nested emits interleave, there is no way to await completion, and nothing records which plugin emitted. | `buildEventBus` | §25, §29 |
| Q10 | `app.emit` is typed with **global** events only, so a consumer cannot emit plugin events from the app at the type level. The runtime accepts any string. | `App` type | §25 |
| Q11 | `depends` is checked **by name**, so a different instance with the same name satisfies it. Plugin instances and specs are **not frozen**; only the app and configs are. | `checkDependencyOrder`, `createPluginFactory` | §30 |
| Q12 | `createCore({ pluginConfigs })` is typed `Record<string, unknown>`, so **framework-level plugin overrides aren't type-checked**. Only the consumer's are. | `CreateCoreOptions` | §23 |
| Q13 | Default-plugin order problems surface only when `createApp` is called, not when the framework is assembled. | `core.ts` validates inside `createApp` | §30: validate at `compose` |
| Q14 | If two plugins declare the same event name with different payloads, the payload silently collapses to `never` at the type level. There is no runtime check. | `type-gaps.test.ts` "conflicting payload types" | §25: namespacing + `E_EVENT_CONFLICT` |
| Q15 | The framework's `onReady` gets only `{ config }`, the framework has no `onStart`/`onStop`, and its `onError` gets core APIs only. | `CreateCoreOptions` | §23 |
| Q16 | Plugin names may contain any characters (the tests use `"b-events"`), which forces `app["b-events"]`. `Object.prototype` keys other than `__proto__`/`constructor` (such as `toString`) are not reserved. | `RESERVED_NAMES` | §30 |

**Spec drift** (the docs disagree with the code):

- **`onStop` context.** Spec 11 §1.11's prose and spec 06 §8's example say `onStop` gets "only `global`". The code, and the table in 11 §1.11, give `{ global, config, state }`.
- **Async `onInit`.** Spec 11 §1.12 says "Plugin A's `onInit` resolves before Plugin B's `onInit` begins", which implies async. In the code `onInit` is sync.
- **Name-conflict errors.** The core/regular name-conflict and core-duplicate messages in spec 11 §1.17 don't match the code's wording.
- **Reserved names.** Spec 06 §2's reserved-name list omits `global` and `state`.
- **Export count.** "One export at Layer 1" (spec README, 01 §3, and the `config.ts` header) is stale. There are now two runtime exports.
- **Version labels.** README and CLAUDE.md say `0.1.x`, `package.json` says `1.5.0`, and the `TeardownContext` comments mention "1.6".
