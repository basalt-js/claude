## 21. `definePlugin`

| Field | Receives | Change from Moku |
|---|---|---|
| `config` | — | A complete default object (as in Moku) **or a Standard Schema** such as `z.object({...})` (§21.1). |
| `events` | — | A plain object of `event*()` descriptors. **Keys must be `` `${pluginName}:${string}` ``**, enforced in types and at runtime (`E_EVENT_NAMESPACE`). Collisions become impossible by construction (fixes Q14). |
| `depends` | — | Required deps, validated **by identity** and order. |
| `optionalDepends` | — | **New.** If present they must come earlier, accessed with `ctx.find(p)`. They also add the dependency's events to the type surface. |
| `state` | `{ global, config, services… }` | Renamed from `createState`. Services are now visible, because they are fully initialised first. |
| `api` | `PluginContext` (wiring) | Must be sync. Emitting **throws** `E_EMIT_DURING_WIRING`. `get()` of a dependency that isn't built yet throws `E_NOT_READY` (fixes Q2). |
| `hooks` | `PluginContext` | Runs **after all APIs exist** (fixes Q1). Handler signatures depend on the event kind (§25). |
| `onInit` | `PluginContext` | **May be async** and is awaited sequentially (§27). For *loading and validating*, not for acquiring resources. |
| `onStart` | `PluginContext` + `signal` | Acquire resources. A failure triggers rollback (§27). |
| `onStop` | `TeardownContext` + `signal` | Release resources. Best-effort (§27). |
| `helpers` | — | Same as Moku: pure static functions merged onto the definition. |

**Definitions** are deep-frozen `{ kind: "plugin", framework, name, spec, catalog, _phantom, ...helpers }`. `catalog` is the normalised event list, so tooling can read it without building an app. `framework` is the id of the framework whose `definePlugin` created it; apps reject plugins from another framework (`E_FOREIGN_PLUGIN`).

**Name rule:** `^[a-z][A-Za-z0-9]*$`, which keeps every name a valid property for `app.name`. The name must not be reserved (§30).

### 21.1 Config: defaults or a schema (O10, decided)

`config` takes either a complete default object, as in Moku, or any **Standard Schema**. Standard Schema is a small shared interface (the `~standard` property) that Zod, Valibot, ArkType and other libraries implement. The kernel copies the interface's type definitions, so it still has zero runtime dependencies.

```ts
import { z } from "zod";

export const analyticsPlugin = definePlugin("analytics", {
  config: z.object({
    trackingId: z.string().min(1),                    // no default → the app must provide it
    sampleRate: z.number().min(0).max(1).default(1),
    endpoint:   z.string().url().default("https://collect.example.com"),
  }),
  api: ctx => ({ track: (name: string) => send(ctx.config.endpoint, ctx.config.trackingId, name) }),
});

// app
const app = await createApp({ pluginConfigs: { analytics: { trackingId: "G-123" } } });
```

**How a schema config is resolved:**

1. Shallow-merge the overrides, framework first, then the app: `{ ...composeOverride, ...appOverride }`.
2. Run `schema["~standard"].validate(merged)`. The schema fills in its own defaults and runs any transforms.
3. If there are issues, `createApp` rejects with `E_CONFIG_INVALID`, naming the plugin and listing each issue's path and message.
4. Freeze the output. That output is `ctx.config`.

**Types:** `ctx.config` is the schema's *output* type, and `pluginConfigs.analytics` is `Partial` of its *input* type.

**Decided (O15):** when a schema has fields without defaults, the plugin's key in `pluginConfigs` becomes **required** in the `createApp` types (unless the framework already supplies those fields in `compose`). A missing value is then a compile error, with `E_CONFIG_INVALID` as the runtime backstop. Prototype the error message in M1 and make sure it names the missing field.

**What this replaces:** Moku's "sentinel default plus a check in `onInit`" pattern. A field without a default is simply required.

**Other rules:**
- The same applies to the global config in `defineFramework` and to service configs.
- Validation can be async. `createApp` awaits it, and `createAppSync` throws `E_ASYNC_INIT` if `validate` returns a promise.
- Validation always runs, even with `checks: "minimal"`, because it produces the config.
- Merging is still shallow: an override of a nested object replaces it whole, and the schema then re-applies nested defaults.
- `inspect()` lists config keys, not schemas.
