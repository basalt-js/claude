## 22. `defineService`

Services keep Moku's core-plugin model with three deliberate relaxations:

| | Moku core plugin | Basalt service |
|---|---|---|
| Context | `{ config, state }` | `{ global, config, state, …earlier services }` |
| Depends on other services | ✗ | ✓, via `depends: [envService]`. Must be listed earlier, validated by identity. |
| Events and hooks | ✗ | ✗ (unchanged; services stay below the event graph) |
| Visible in plugin `onStop` | ✗ | ✓, because services stop after plugins and are still alive |
| Config merge | 4 levels | 4 levels: spec → `defineFramework.serviceConfigs` → `compose.pluginConfigs` → `createApp.pluginConfigs`. The spec's config may be a schema (§21.1). |
