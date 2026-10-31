## 18. What Basalt keeps from Moku (non-negotiable)

1. **Three layers.** Consumers import only from a framework, never from `@basalt-js/core`.
2. **Two-step framework definition** (define → compose). It is required to break the `config.ts` ↔ plugin-file import cycle.
3. **Plugins are plain objects.** APIs are closures over private mutable state. Configs are frozen.
4. **Order is explicit.** Array order is init/start order, and stop runs in reverse. `depends` only validates.
5. **Zero explicit generics** on plugin definitions.
6. **Strict events.** No untyped emit.
7. **Phase-appropriate context tiers.**
8. **Shallow config merge** with optional `Partial` overrides. Defaults come from a complete default object *or* from a schema (§21.1).
9. **Error format** `[id] description.\n  suggestion.`
10. **Moku's conventions:** tiers, file contracts, JSDoc contract, public export shape, test layout, `llms.txt`.
