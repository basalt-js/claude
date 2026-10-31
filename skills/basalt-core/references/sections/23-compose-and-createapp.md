## 23. `compose` and `createApp`

```ts
framework.compose({
  plugins: readonly (PluginDefinition | Pack)[];    // framework defaults (validated NOW)
  pluginConfigs?: TypedOverrides<Plugins | Services>; // typed (fixes Q12)
  tracer?: Tracer;
  lifecycle?: { initTimeoutMs?; startTimeoutMs?; stopTimeoutMs? };
  checks?: "full" | "minimal";                     // runtime guard level (default "full"; createApp can override)
  contextStore?: ContextStore;                      // async causality for tracing (§29)
  onReady? / onStart? / onStop?: (ctx: AppContext) => void | Promise<void>;  // full context (fixes Q15)
  onError?: (error: BasaltError, ctx: AppContext) => void;
}) => { createApp, createAppSync }

createApp(options?: {
  plugins?: readonly (PluginDefinition | Pack)[];    // appended after defaults
  config?: Partial<GlobalConfig>;
  pluginConfigs?: TypedOverrides<…>;
  tracer?: Tracer;                                   // fans out with the framework tracer
  lifecycle?: …; checks?: …;
  onReady? / onStart? / onStop? / onError?: …;
}) => Promise<App>
```

**The `App` object** (frozen):

| Member | What it is |
|---|---|
| `start()`, `stop()` | Lifecycle (§27). |
| `status` | Getter for the current state (§27). |
| `settled()` | Resolves when no event work is in flight (§25). |
| `emit`, `dispatch`, `collect`, `pipe` | Typed with **every** event in the app: global + all plugin events (fixes Q10). |
| `get(p)`, `find(p)`, `has(p \| name)` | Unrestricted for consumers. |
| `shared` | `{ state, actions }` (§26). |
| `inspect()` | The manifest (§28). |
| `[Symbol.asyncDispose]` | Stops the app if it is running. |
| `[pluginName]`, `[serviceName]` | Plugin and service APIs. |

**Safety checks (O12, decided).** `checks` is `"full"` by default. A framework can set it in `compose`, and an app can override it in `createApp`; the app's value wins. `"minimal"` skips only the runtime checks that cost speed: unknown-event and event-kind checks, and the shared-state write trap. Name, dependency and framework checks, plus config-schema validation, always run.
