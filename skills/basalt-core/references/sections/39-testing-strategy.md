## 39. Testing strategy (kernel)

| Suite | Covers |
|---|---|
| unit | Validation, config merge, catalog building, store, bus modes, state machine transitions |
| integration | Real frameworks: ordering, rollback, best-effort stop, `settled()`, timeouts, `createAppSync` |
| types | Inference and rejection cases (`@ts-expect-error`) for every compile-time rule |
| fault injection | Throw or reject at every lifecycle point, every handler mode, and inside `onError`/tracers. Assert B6–B10. |
| concurrency | `start`/`stop` races, `stop` during `start`, emits during `stopping` |
| Moku parity | Port Moku's sandbox scenarios (router, analytics, cms, counter, env, SPA demo) as acceptance tests |

Coverage gate: 90% (Moku's level), with `src/**/types.ts` excluded.
