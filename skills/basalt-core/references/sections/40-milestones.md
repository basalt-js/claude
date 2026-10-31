## 40. Milestones

| # | Deliverable | Exit criteria |
|---|---|---|
| M0 | `ci` repo (shared workflows, lint config, release script) and `core` repo scaffold | CI green on an empty package; lint, test, and size gates wired |
| M1 | Kernel parity: define/compose/createApp, plugins, services, config (defaults and Standard Schema), packs, `emit`, init/start/stop | Moku sandbox scenarios ported and passing; Q1, Q2, Q10–Q13, Q16 fixed |
| M2 | Lifecycle robustness: state machine, rollback, best-effort stop, timeouts, `signal`, dispose, `settled()` | B5–B10 fault-injection suite passing |
| M3 | Async init and event modes: async `createApp`, `createAppSync`, `dispatch`/`collect`/`pipe` | Type and runtime tests for every kind/mode pair |
| M4 | Shared state | Readonly view, actions, `basalt:shared`, per-instance isolation tests |
| M5 | Introspection and tracing: `inspect()`, static inspection, tracer fan-out, `contextStore` injection, std tracers | Manifest snapshot tests; zero-cost-when-off benchmark |
| M6 | Spec split into `spec/NN-*.md`, `llms.txt`, prompt fragment, README | Docs reviewed; prompt fragment ≤ ~1500 tokens |
| M7 | `@basalt-js/std` | log/env/clock services, tracers, test utils |
| M8+ | `@basalt-js/web`, `@basalt-js/worker`, packs | Per-framework specs first; the worker spec settles O7 |
