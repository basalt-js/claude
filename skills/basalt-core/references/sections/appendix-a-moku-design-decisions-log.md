# Appendix A — Moku design decisions log (condensed, from spec 13 §1)

| # | Decision | Alternative rejected | Basalt |
|---|---|---|---|
| 1 | 3-step factory chain | One `createCore` with all generics | Kept as 2 framework steps + `createApp` |
| 2 | 2 generics on `createCoreConfig` | Adding `State` | Events are now values; shared state added |
| 3 | 0 generics on `createPlugin` | 4–7 explicit generics | Kept |
| 4 | 3 lifecycle phases | Pre/post hooks per phase | Kept (+ rollback, timeouts) |
| 5 | Structured `createApp` namespaces | Flat options with runtime key discrimination | Kept |
| 6 | Sequential execution | Parallel within phases | Kept |
| 7 | Shallow merge | Deep merge | Kept |
| 8 | Instance-based `depends` | Strings | Kept, now checked by identity |
| 9 | `ctx.global` = config; global state deferred | `{ config, state }` | **Shared state added** (§26) |
| 10 | No topological sort | Auto-sort | Kept |
| 11 | Configs frozen, state mutable | All mutable or all frozen | Kept, plus definitions frozen |
| 12 | No sub-plugins | Depth-first flattening | Mostly kept: named packs (`framework.pack`) flatten one level, in place |
| 13 | Minimal lifecycle contract | Transactional lifecycle | **Replaced** by the state machine + rollback (§27) |
| 14 | Stop propagates the first error | Best-effort | **Replaced** by best-effort + aggregate error |
| 15 | Helpers as an intersection type | 6th generic | Kept |
