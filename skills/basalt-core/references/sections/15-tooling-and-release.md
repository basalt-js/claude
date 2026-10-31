## 15. Tooling and release

- **Bun:** exact-pinned installs.
- **Lint:** Biome (format + lint) plus ESLint (`jsdoc`, `sonarjs`, `unicorn`, `consistent-type-imports`).
- **Lefthook pre-commit:** build + `publint` + `attw`, Biome, ESLint, and all three test projects.
- **CI:** a matrix over TS 6.0 and 7.0.
- **Release:** auto-release a patch on every merge to `main` through the internal `@moku-labs/ci` (`moku-release`). Dependabot updates `@moku-labs/*` with auto-merge.
