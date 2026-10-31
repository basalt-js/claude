## 33. Invariants

Breaking any of these is a kernel bug.

- **B1.** Plugin order is array order. Init and start run forward, stop runs reverse, rollback runs reverse over targets that already started.
- **B2.** Names are unique across services and plugins, identifier-shaped, and not reserved.
- **B3.** Every `depends`/`optionalDepends` entry is present (if required) and earlier, compared by identity.
- **B4.** Configs, global config, definitions, and the app are frozen. Only plugin state is directly mutable. Shared state changes only through actions.
- **B5.** No handler runs synchronously inside `emit()`. `settled()` resolves only when no dispatch is in flight.
- **B6.** No error is silently swallowed. It goes to `onError`, to the default reporter, or to the awaiting caller.
- **B7.** `start()` either reaches `running` or leaves every started target stopped (`failed`).
- **B8.** `stop()` is idempotent, best-effort, and calls each `onStop` at most once.
- **B9.** A plugin receives no events after its `onStop` begins.
- **B10.** Each lifecycle method is called at most once per app instance.
- **B11.** `ctx.get` reaches only declared dependencies. Consumers (`app.get`) reach everything.
- **B12.** Every event that is emitted, hooked, or listed in `inspect()` exists in the catalog, under `checks: "full"`.
- **B13.** Tracers and `inspect()` never change behaviour.
- **B14.** No plugin or service code sees a config that hasn't passed its schema (when it has one).
- **B15.** An app contains only plugins defined by its own framework.
