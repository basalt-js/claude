## 20. `defineFramework` (Layer 2, step 1)

```ts
defineFramework(id: string, options: {
  config: GlobalConfig | StandardSchema;      // complete defaults or a schema (§21.1)
  events?: EventCatalog;                      // { "domain:action": event<P>("…") }
  shared?: { initial: () => S; actions: Record<string, (s: S, ...args) => void> };
  services?: readonly ServiceDefinition[];    // ordered; may depend on earlier services
  serviceConfigs?: { [service]?: Partial<ServiceConfig> };
}): Framework
```

Returns `{ id, definePlugin, compose, pack }`. **The returned object is frozen.**

- **Validation at call time:** id format, service names and order, and the event catalog (names, kinds, duplicates).
- **Widening config types.** Config types are inferred from the defaults. To widen a field, cast it in place (`"development" as Mode`) or annotate a `const` first.

**Decided (O2):** both forms are supported. Inference is the default. Writing the type explicitly uses a curried call, so the remaining types are still inferred:

```ts
defineFramework("site", { config: { mode: "development" as Mode } });       // inferred
defineFramework<SiteConfig>()("site", { config: { mode: "development" } }); // checked against SiteConfig
```
