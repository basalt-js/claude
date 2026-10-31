## 25. Events: four modes

Each event is declared once with a **kind**:

```ts
event<P>(description?)              // notify  — fire-and-forget or awaited broadcast
event.collect<P, R>(description?)   // collect — every handler returns R; caller gets R[]
event.pipe<T>(description?)         // pipe    — handlers transform T in order; caller gets final T
event.map<Map>(descriptions?)       // bulk notify declarations from a pre-declared type
```

| Call | Event kinds | Returns | Semantics |
|---|---|---|---|
| `emit(name, p)` | notify | `void` | Fire-and-forget. The dispatch is **queued as a microtask** (no handler runs inside `emit()`, which fixes the half-sync behaviour in Q9). It is tracked for `settled()`. Each failing handler is reported to `onError` as `E_HANDLER_FAILED` (with the plugin and `cause`), and the remaining handlers still run. |
| `await dispatch(name, p)` | notify | `DispatchResult` | Runs every handler sequentially in plugin order. If any handler fails, it still runs the rest, then **rejects** with `E_DISPATCH_FAILED` (an `AggregateError` with per-plugin causes). It does not call `onError`, because the caller owns the failure. |
| `await collect(name, p)` | collect | `R[]` | Handlers run sequentially. Results come back in plugin order. Errors behave as in `dispatch`. |
| `await pipe(name, v)` | pipe | `T` | Each handler receives the previous handler's output. If a handler throws, the pipe rejects. This replaces Moku's hand-rolled `api.use(fn)` middleware pattern. |

**Hook handler types** follow the kind:

| Kind | Handler type |
|---|---|
| notify | `(p) => void \| Promise<void>` |
| collect | `(p) => R \| Promise<R>` |
| pipe | `(v: T) => T \| Promise<T>` |

Calling a mode against the wrong kind is a compile error, and a runtime `E_EVENT_KIND` under full checks.

**Visibility** (unchanged from Moku): global + own + **direct** `depends`/`optionalDepends`. Not transitive.

**Runtime catalog checks.** Because the catalog exists at runtime:
- `emit` of an undeclared name throws `E_UNKNOWN_EVENT` (under `checks: "full"`), which covers JS consumers and `as any`;
- `hooks` keys that aren't in the plugin's visible catalog fail at `createApp`;
- duplicate declarations fail with `E_EVENT_CONFLICT`.

**Intrinsic events** use the reserved `basalt:` namespace, which plugins may hook:
- `basalt:shared` — `{ action, source }`
- `basalt:status` — `{ from, to }`

**Default error reporting.** If nobody passes `onError`, errors go to `console.error` and are never silently swallowed (fixes Q8).

**`settled()`.** The kernel keeps a `Set` of in-flight dispatch promises, and `settled()` loops `Promise.allSettled` until the set is empty. Tests use it, and so does `stop()`, as a bounded barrier.

**Decided (O4):** `collect` and `pipe` belong in the kernel. Every Moku framework re-implements "contribute X" and "transform X" through `api.use()` + state arrays. Making them event kinds gives typing, ordering, tracing, and catalog entries for free.
