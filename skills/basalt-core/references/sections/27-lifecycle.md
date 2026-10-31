## 27. Lifecycle

### 27.1 States

```
createApp() ──► initializing ──► ready ──start()──► starting ──► running ──stop()──► stopping ──► stopped
                     │                                 │
                     └─ init error: createApp rejects  └─ start error ──► rollingBack ──► failed
```

`app.status` is one of `"ready" | "starting" | "running" | "stopping" | "stopped" | "rollingBack" | "failed"`. The `initializing` state is never observable, because no app object exists until init succeeds.

### 27.2 Init (inside `createApp`)

1. Run services' `onInit`, then plugins' `onInit`, in forward order, **each awaited**.
2. Then the framework `onReady`, then the consumer `onReady`.

**Contract:** `onInit` is for loading, validating, and wiring. Anything that must be released belongs in `onStart`/`onStop`. If init fails, `createApp` rejects, there is nothing to roll back, and no app is returned.

`createAppSync()` runs the same steps but throws `E_ASYNC_INIT` if any `onInit` returns a thenable. It attaches a catch so the stray promise can't become an unhandled rejection. Use it where top-level `await` isn't available.

**Decided (O5):** `createApp` is async by default. Making it async means TypeScript *forces* `await` (properties don't exist on `Promise<App>`), whereas a sync `createApp` plus `app.ready` makes it easy to use APIs before init finishes.

### 27.3 `start()`

| State when called | Behaviour |
|---|---|
| `ready` | Proceeds. |
| `starting` | Returns the same in-flight promise. |
| anything else | Throws `E_INVALID_STATE`. |

**Order:** services `onStart` → plugins `onStart` → framework `onStart` → consumer `onStart`, all forward and awaited. Each call gets `ctx.signal`, and `startTimeoutMs` applies per target.

**On failure**, at any point including callbacks:

1. Status becomes `rollingBack`.
2. `onStop` runs **in reverse for every target before the failure point** (services included). Rollback continues past errors.
3. Status becomes `failed`.
4. `start()` rejects with `E_START_FAILED { cause, target, rollbackErrors }` (fixes Q4).

`failed` is terminal: only `inspect()` and `stop()` (a no-op) remain useful.

### 27.4 `stop()`

**Never throws `E_INVALID_STATE`:**

| State when called | Behaviour |
|---|---|
| `ready` | Moves to `stopped` (nothing had started). |
| `stopped`, `failed` | No-op. |
| `stopping` | Returns the in-flight promise. |
| `starting` | Waits for start to settle, then stops if the app is running. |

**From `running`:**

1. Status becomes `stopping`.
2. `await settled()`, bounded by `stopTimeoutMs`.
3. Consumer `onStop`, then framework `onStop`. They run **first**, while everything is still alive (fixes Q6).
4. For each plugin in reverse order: **detach its hooks**, then call `onStop`.
5. Services' `onStop` in reverse.
6. Status becomes `stopped`.

Teardown is **best-effort**: every target gets its `onStop` even if an earlier one failed. Errors are collected and thrown afterwards as `E_STOP_FAILED` (an `AggregateError`), which fixes Q5. `stopped` is terminal; to restart, create a new app.

Emits after `stopped` are dropped and reported as `E_EMIT_AFTER_STOP` through `onError`. That catches leaked timers without crashing.

### 27.5 Timeouts and cancellation

Timeouts are optional, set per target via `lifecycle.{init,start,stop}TimeoutMs`. When a timeout fires, the kernel aborts `ctx.signal` and rejects with `E_TIMEOUT` naming the plugin. The underlying promise cannot be cancelled. Cooperative code should watch `signal`.

### 27.6 Disposal

`await using app = await createApp(...)` calls `stop()` at scope exit through `Symbol.asyncDispose`. It falls back gracefully where the symbol is missing.
