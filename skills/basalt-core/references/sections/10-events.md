## 10. Events

- **Sources.** A plugin sees the merge `Events & PluginEvents & DepsEvents<Deps>`:
  - **Global:** the `Events` generic on `createCoreConfig`.
  - **Own:** the plugin's `events`.
  - **Dependencies:** the events of plugins it lists in `depends`, **direct dependencies only (non-transitive)**.
- **Strict emit.** Unknown names and wrong payloads are compile errors, and there is no untyped overload. A framework that wants open events sets `Events = Record<string, unknown>`.
- **Dispatch semantics** (`buildEventBus`):
  - `emit` calls `void dispatch(name, payload)` and is **fire-and-forget**.
  - `dispatch` is `async` and walks the handlers in registration (plugin) order, awaiting each one.
  - Because an `async` function runs synchronously until its first `await`, **the first handler runs synchronously inside `emit()`** and the rest run on later microtasks.
- **Errors.** A throwing handler is reported to `combinedOnError`, and dispatch moves on to the next handler. Errors thrown by the error handlers themselves are discarded. **With no `onError` at either layer, hook errors are silently swallowed.**
- **No barrier.** `createApp()` and `start()` do not wait for async hook work that they triggered.
- **Not in the kernel:** middleware and pipelines. The spec's pattern is an `api.use(fn)` that pushes into plugin state.
