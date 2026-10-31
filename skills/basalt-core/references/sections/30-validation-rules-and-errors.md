## 30. Validation rules and errors

**Error type.** Every kernel error is a `BasaltError` with a `code`, a `frameworkId`, and an optional `plugin`. Errors that aggregate several failures extend `AggregateError`.

**Message format** (Moku's, plus the code):

```
[site] Plugin "seo" depends on "router", but "router" appears after "seo". [E_DEPENDENCY_ORDER]
  Move "router" before "seo" in your plugin list.
```

| Code | When |
|---|---|
| `E_INVALID_NAME` | The name breaks `^[a-z][A-Za-z0-9]*$`, is reserved, or is an `Object.prototype` key. **Reserved:** `start stop status settled emit dispatch collect pipe get find has shared inspect global config state signal services basalt`. |
| `E_INVALID_SPEC` | A spec field has the wrong type, or a helper key collides. |
| `E_CONFIG_INVALID` | A resolved config failed its schema. Lists each issue's path and message. |
| `E_FOREIGN_PLUGIN` | A plugin or pack defined by another framework was passed to this framework's `compose`/`createApp`, or added to its pack. |
| `E_DUPLICATE_NAME` | The same name appears twice across services and plugins. |
| `E_DEPENDENCY_MISSING` / `E_DEPENDENCY_ORDER` | A `depends`/`optionalDepends` entry is missing or comes later, checked **by identity** (fixes Q11). |
| `E_UNDECLARED_DEPENDENCY` | `ctx.get(p)` was called with `p` not in `depends`. |
| `E_NOT_READY` | `ctx.get(p)` was called inside `api()` before `p` was built. |
| `E_EVENT_NAMESPACE` | A plugin event isn't prefixed `name:`. |
| `E_EVENT_CONFLICT` | An event name is declared twice. |
| `E_UNKNOWN_EVENT` / `E_UNKNOWN_HOOK` | An emit or hook names an undeclared or invisible event. |
| `E_EVENT_KIND` | A mode was called against the wrong kind (`emit` on a collect event, etc.). |
| `E_EMIT_DURING_WIRING` | An emit happened inside `api()`. |
| `E_ASYNC_INIT` | `createAppSync` hit an async `onInit`. |
| `E_INVALID_STATE` | `start()` was called in the wrong state. |
| `E_START_FAILED` / `E_STOP_FAILED` | Lifecycle failure (with `cause` / `errors`). |
| `E_TIMEOUT` | A lifecycle target exceeded its timeout. |
| `E_DISPATCH_FAILED` | One or more handlers failed in `dispatch`/`collect`/`pipe`. |
| `E_HANDLER_FAILED` | A hook handler failed during an `emit`. Reported through `onError`, not thrown; `cause` holds the original error. |
| `E_SHARED_READONLY` | A write went through the shared-state view. |
| `E_EMIT_AFTER_STOP` | An emit happened after `stopped`. Reported, not thrown. |

**Definitions are deep-frozen.** `compose` validates the framework defaults immediately (fixes Q13), and `createApp` validates the merged list.
