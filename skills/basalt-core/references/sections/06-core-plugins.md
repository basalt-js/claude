## 6. Core plugins (`createCorePlugin`)

Core plugins are self-contained infrastructure such as `log`, `env`, and storage.

- **Spec fields:** `config`, `createState({ config })`, `api({ config, state })`, `onInit`, `onStart`, `onStop`. They all receive `{ config, state }` only.
- **Forbidden fields:** `depends`, `events`, `hooks`. Including them is a runtime error. Core plugins also get no `global` config.
- **Registration:** they are passed to `createCoreConfig({ plugins })`.
- **API injection:** their APIs are injected **flat onto every regular plugin's context** (`ctx.log.info()`) and onto the app.
- **Config:** a 4-level merge: spec defaults → `createCoreConfig.pluginConfigs` → `createCore.pluginConfigs` → `createApp.pluginConfigs`.
- **Lifecycle:** they init and start before regular plugins, and stop after them.
