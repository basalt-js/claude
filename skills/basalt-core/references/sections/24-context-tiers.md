## 24. Context tiers

| Tier | Used by | Contents |
|---|---|---|
| `StateContext` | plugin `state` | `global`, `config`, services |
| `WiringContext` | `api` factory | `global`, `config`, `state`, `shared`, `get`/`find`/`has`, services; `emit*` present but throws until wiring ends |
| `PluginContext` | `hooks`, `onInit`, `onStart`, handlers, API method bodies | everything above plus working `emit`/`dispatch`/`collect`/`pipe`; `onStart` also gets `signal` |
| `TeardownContext` | `onStop` | `global`, `config`, `state`, services, `signal` |
| `ServiceContext` | service methods | `global`, `config`, `state`, earlier services |
| `AppContext` | framework and consumer callbacks | `global`, `shared`, `emit*`, `get`/`find`/`has`, all plugin and service APIs |

**`get` rules** (enforced in types and at runtime):

| Call | Result |
|---|---|
| `ctx.get(p)` where `p` is in `depends` | Its API. |
| `ctx.get(p)` where `p` is not declared | `E_UNDECLARED_DEPENDENCY`. |
| `ctx.find(p)` where `p` is in `optionalDepends` | Its API, or `undefined`. |
| A dependency whose API isn't built yet (only possible inside `api()`) | `E_NOT_READY`, with a hint to call `get` lazily. |

**Decided (O3):** `get` is restricted to declared deps. Moku's `require` reaches any plugin, which makes `depends` advisory and the dependency graph in tooling incomplete.
