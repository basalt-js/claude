## 19. API at a glance

```ts
// ── Layer 2 · framework/src/config.ts ──────────────────────────────────────
import { defineFramework, event } from "@basalt-js/core";
import { logService, envService } from "@basalt-js/std";

type Mode = "development" | "production";

const site = defineFramework("site", {
  config: { siteName: "Untitled", mode: "development" as Mode },
  events: {
    "page:render": event<{ path: string; html: string }>("A page finished rendering"),
    "page:head":   event.collect<{ path: string }, HeadTag[]>("Contribute <head> tags"),
  },
  shared: {
    initial: () => ({ locale: "en" }),
    actions: { setLocale: (s, locale: string) => { s.locale = locale; } },
  },
  services: [envService, logService],
});

/** Define a plugin for the `site` framework. Types are inferred from the spec. */
export const definePlugin = site.definePlugin;
export { event };
export { site };

// ── Layer 2 · framework/src/plugins/router/index.ts ─────────────────────────
export const routerPlugin = definePlugin("router", {
  config: { basePath: "/" },
  events: { "router:navigate": event<{ from: string; to: string }>("Route changed") },
  depends: [rendererPlugin],
  state: ({ config }) => ({ current: config.basePath }),
  api: ctx => ({
    navigate: (to: string) => {
      const from = ctx.state.current;
      ctx.state.current = to;
      ctx.emit("router:navigate", { from, to });
    },
    current: () => ctx.state.current,
  }),
  hooks: ctx => ({ "page:render": ({ path }) => ctx.log.debug("rendered", { path }) }),
  onInit:  async ctx => { /* load / validate; may await (§27) */ },
  onStart: async ctx => { /* acquire resources; ctx.signal for cancellation */ },
  onStop:  async ctx => { /* release; reverse order */ },
  helpers: { route: (path: string, view: string) => ({ path, view }) },
});

// ── Layer 2 · framework/src/index.ts ───────────────────────────────────────
const composed = site.compose({ plugins: [rendererPlugin, routerPlugin] });
/** Create a `site` app. Resolves when every plugin has initialised. */
export const createApp = composed.createApp;
/** Synchronous variant; rejects plugins whose `onInit` is async. */
export const createAppSync = composed.createAppSync;

// ── Layer 3 · app/main.ts ──────────────────────────────────────────────────
const app = await createApp({
  plugins: [blogPlugin],
  config: { siteName: "My Blog" },
  pluginConfigs: { router: { basePath: "/blog" } },
  tracer: devTracer(),
});
await app.start();
app.router.navigate("/about");
await app.settled();          // all in-flight event work finished
console.log(app.inspect());   // manifest: plugins, events, listeners, status
await app.stop();             // idempotent; also `await using app = ...`
```

### Moku → Basalt mapping

| Moku | Basalt | Why |
|---|---|---|
| `createCoreConfig<Config, Events>(id, { config, plugins, pluginConfigs })` | `defineFramework(id, { config, events, shared, services, serviceConfigs })` | Events are declared as **values** (runtime catalog, no generic). Config type is inferred. Adds shared state. |
| `createCore(coreConfig, opts)` | `framework.compose(opts)` | Drops the redundant `coreConfig` argument. Typed `pluginConfigs` (Q12). Validates defaults early (Q13). |
| `createApp()` (sync) | `await createApp()` / `createAppSync()` | Async init (§27). |
| `createPlugin` | `definePlugin` | `define*` = declaration, `create*` = instance. Consistent naming. |
| `createCorePlugin` (core plugin) | `defineService` (service) | "Core plugin" vs "plugin" confused readers. Services are infrastructure injected flat on `ctx`. |
| `createState` | `state` | Shorter, and reads like the value it produces. |
| `events: register => ({ "a:b": register<T>("d") })` | `events: { "a:b": event<T>("d") }` | Not context-sensitive, so the inference hazard (§12.11) disappears. Readable without calling anything (catalog). |
| `register.map<E>({…})` | `event.map<E>({…})` | Same idea. |
| `ctx.require(p)` (any plugin) | `ctx.get(p)` (declared deps only) + `ctx.find(p)` (optional deps) | Enforces explicit dependencies (§24). Avoids the CommonJS `require` association. |
| `ctx.has("name")` | `ctx.has(p \| "name")` | Typed when given an instance. |
| `ctx.emit` | `emit` / `dispatch` / `collect` / `pipe` | Awaitable and value-returning events (§25). |
| `ctx.global` (config) | `ctx.global` + `ctx.shared` | Shared state (§26). |
| `start` / `stop` | + `status`, `settled()`, `inspect()`, `[Symbol.asyncDispose]` | Robustness and introspection. |
| `PluginCtx<C, S, E>` | `PluginCtx<{ config; state; events; depends? }>` | A named-field generic: no positional mistakes, and it can carry deps. |

**Decided (O1):** these names are adopted. Packages publish as `@basalt-js/*` (O13).
