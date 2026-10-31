## 2. Package facts

| Item | Value |
|---|---|
| Runtime exports | `createCoreConfig`, `createCorePlugin` |
| Public type exports | `PluginCtx`, `EmitFn`, plus declaration-emit types (`App`, `PluginInstance`, `CreateAppOptions`, `CoreConfigResult`, `CreateCoreResult`, `BoundCreatePluginFunction`, `RegisterFunction`, `CorePluginInstance`, …). These are exported only so downstream `.d.ts` files can name them (avoids TS4023). |
| Dependencies | Zero runtime deps. The README targets < 8 KB gzipped. |
| Build | `tsdown` emits ESM `.mjs` + CJS `.cjs` + `.d.mts`/`.d.cts`. `"sideEffects": false`. Checked with `publint` and `attw`. |
| Engines | node ≥ 24, bun ≥ 1.3.8. The repo develops on Bun 1.4.3. |
| TypeScript | `strict`, `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, `verbatimModuleSyntax`, `module: Preserve`. CI typechecks and tests on TS 6.0 **and** TS 7.0. |
| Version labels | `package.json` says `1.5.0`, but README and CLAUDE.md still say "early release 0.1.x" (see §16). |
