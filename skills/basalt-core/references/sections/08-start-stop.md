## 8. `start()` / `stop()`

- **`start()`** throws if `started` is already true. It runs `onStart` for core plugins, then regular plugins, in forward order, awaiting each one. Then it runs the consumer `onStart(callbackCtx)` and sets `started = true` only at the very end. **There is no rollback.**
- **`stop()`** throws if `!started`. It runs regular plugins' `onStop({ global, config, state })` in reverse, then core plugins' `onStop({ config, state })` in reverse, then the consumer `onStop(callbackCtx)`. It does not reset `started`. The first error propagates, and the remaining plugins are not stopped.
- **Supported usage** is `createApp → start? → stop?`. Anything else (repeat calls, concurrent calls, recovering after a failure) is explicitly outside the contract.
