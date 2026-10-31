## 5. The plugin spec

Every field is optional, and none of them takes an explicit generic. Everything is inferred from the spec object.

| Field | Shape | Receives | Notes |
|---|---|---|---|
| `config` | `C` (full default value) | — | `C` is inferred from it. Consumers override with `Partial<C>`. |
| `events` | `register => ({ "x:y": register<P>("desc") })` | `RegisterFunction` | **Type inference only — the kernel never calls it.** `register.map<EventMap>({...descs})` registers a whole map at once. |
| `depends` | `readonly PluginInstance[]` | — | Validation plus type plumbing only: dependency events become visible, and `require` is typed. No reordering. |
| `createState` | `ctx => S` | `{ global, config }` | Called once per app. This is the only mutable store. |
| `api` | `ctx => A` | full `PluginContext` | Mounted as `app[name]`. Must be sync. The spec says it must not emit. |
| `hooks` | `ctx => ({ "event": handler })` | full `PluginContext` | The handler map is keyed by known event names. Unknown keys fail to compile. |
| `onInit` | `ctx => void` | full `PluginContext` | Sync. Runs inside `createApp`. |
| `onStart` | `ctx => void \| Promise<void>` | full `PluginContext` | Runs during `app.start()` and is awaited sequentially. |
| `onStop` | `ctx => void \| Promise<void>` | `{ global, config, state }` | Runs during `app.stop()` in reverse order and is awaited sequentially. |
| `helpers` | `{ name: (...a) => r }` | — | Pure static functions **spread onto the plugin instance** (`routerPlugin.route(...)`), for use before `createApp`. |

**The instance** is a plain object: `{ name, spec, _phantom: {} as { config; state; api; events }, ...helpers }`. `_phantom` is never read at runtime. It exists only so the type system can carry information.
