## 4. Source map

The line counts below include heavy JSDoc, because lint requires `@example` on every function and type in `src/`.

| File | Lines | Responsibility |
|---|---|---|
| `src/index.ts` | 45 | The only authority on the public surface. |
| `src/config.ts` | 129 | `createCoreConfig`: captures id, config defaults, and core plugins, validates the core plugins, and builds `createPlugin` + `createCore`. |
| `src/plugin.ts` | 959 | `createPlugin` type machinery (spec, context, event merging, `register`) plus runtime spec assertions. Returns `{ name, spec, _phantom, ...helpers }`. |
| `src/core-plugin.ts` | 391 | `createCorePlugin`: self-contained infrastructure plugins. |
| `src/core.ts` | 260 | `createCore` → `createApp`: merges plugin lists, validates, delegates to the kernel. |
| `src/app.ts` | 813 | **The kernel:** config resolution, state, event bus, context factories, app object, `start`/`stop`. |
| `src/types.ts` | 661 | Context tiers, `PluginInstance`, extraction/aggregate types, `App`, `CreateAppOptions`, `PluginCtx`. |
| `src/utilities.ts` | 330 | `UnionToIntersection`, `IsLiteralString`, `EmitFn`, plus validation (reserved names, duplicates, dependency order). |
