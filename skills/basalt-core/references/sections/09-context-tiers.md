## 9. Context tiers

| Tier | Used by | Contents |
|---|---|---|
| `MinimalContext` | `createState` | `global`, `config` |
| `PluginContext` | `api`, `hooks`, `onInit`, `onStart` | `global`, `config`, `state`, `emit`, `require`, `has`, plus core APIs flat |
| `TeardownContext` | `onStop` | `global`, `config`, `state` (no communication, no core APIs) |
| `CorePluginContext` | all core-plugin methods | `config`, `state` |
| `AppCallbackContext` | consumer `onReady`/`onStart`/`onStop`/`onError` | `config`, `emit`, `require`, `has`, plus all plugin APIs |

- **`require(pluginInstance)`** accepts an instance only, never a string. It returns the fully typed API or throws, and it is *not* restricted to declared `depends`.
- **`has(name)`** is string-based and returns a boolean.
