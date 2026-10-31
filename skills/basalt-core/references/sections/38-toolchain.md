## 38. Toolchain

**Same baseline as Moku:**
- Bun (exact pins);
- TypeScript strict (+ `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, `verbatimModuleSyntax`);
- tsdown (ESM + CJS + d.ts);
- `publint`, `attw`;
- Biome + ESLint (`jsdoc` with mandatory `@example` in `src/`, `sonarjs`, `unicorn`);
- Vitest projects;
- Lefthook;
- a TS 6/7 CI matrix.

**Additions:**
- **Runtime matrix:** Bun, Node 24, a browser (Vitest browser mode or happy-dom), and Workers (Miniflare/workerd) for `@basalt-js/core`.
- **Bundle-size gate** for `@basalt-js/core` (≤ 12 KB gz).
- **Lint rules** (shipped from the `ci` repo):
  - `basalt/no-kernel-import-in-app`: apps must not import `@basalt-js/core`. This turns Moku's convention into enforcement.
  - `basalt/no-destructured-public-export`.
  - `basalt/plugin-index-is-wiring`: an `index.ts` over ~50 lines with logic gets a warning.
- **Generated docs:** `llms.txt` and plugin README tables built from `inspect()`.
