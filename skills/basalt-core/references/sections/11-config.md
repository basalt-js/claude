## 11. Config

- **Shallow merge only**, at every level. Nested objects are replaced wholesale.
- **Defaults must be complete.** `config` declares the full `C`, every `pluginConfigs` entry is optional `Partial<C>`, and plugins without `config` are excluded from `pluginConfigs`.
- **"Required" values** use a sentinel default (such as `""`) plus a runtime check in `onInit`.
- **Freezing.** All resolved configs are frozen, and the global config is frozen.
