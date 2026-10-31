## 12. Type-system techniques (Moku's real IP)

These are the parts most worth reusing.

1. **Closure-bound generics.** `Config`/`Events` are bound once in Step 1, so plugin authors never repeat them.
2. **`const` type parameters.** `const PluginName extends string`, `const Plugins extends readonly AnyPluginInstance[]`, and `const ExtraPlugins` keep names as literals and arrays as tuples without `as const`.
3. **Phantom field.** `_phantom: {} as {config; state; api; events}` carries types at zero runtime cost. `ExtractApi`/`ExtractEvents`/`ExtractName`/`ExtractConfig` pull them back out.
4. **Register callback.** `events: register => ({...register<T>()})` lets TypeScript infer the event map without explicit generics.
5. **HookHandlerMap trick.** The *return keys* of `hooks()` are inferred as a separate generic and each key is mapped to `never` unless it is a known event. That rejects unknown hook names even when they are mixed with valid ones.
6. **`UnionToIntersection`.** Used twice:
   - to merge dependency event maps;
   - to turn an event map into overloaded call signatures (`EmitFn<E>`), so extracted domain files can type `emit` without a generic `K` that would fail assignability.
7. **`IsLiteralString` filter.** Plugins with a non-literal `string` name are dropped from `App`/`pluginConfigs`, which avoids index-signature pollution. Plugins with an empty API (`Record<string, never>`) are dropped from the `App` surface.
8. **Identity defaults.** Defaults are `{}` / `Record<never, never>`, never `Record<string, never>`, because the latter's string index turns intersected keys into `never`.
9. **`PluginLike` structural type.** Used in constraint positions to sidestep variance errors that `PluginInstance<string, any…>` causes.
10. **Helpers as an intersection.** The return type is `PluginInstance<…> & Helpers` rather than a sixth generic. The intersection widens away in `depends`/`plugins` arrays.
11. **Known inference hazard.** An unannotated `register => …` is *context-sensitive*, so TypeScript defers it and checks a pre-typed `api` factory against an **empty** own-event map. The workaround is to annotate `register: RegisterFunction` or wrap the factory as `api: ctx => createApi(ctx)` (spec 14 §10 row 8, `tests/sandbox/pretyped-factory-events.test.ts`).
12. **Named return types.** Every type that appears in a public return position is exported, which keeps declaration emit working (`isolatedDeclarations`, TS4023).
