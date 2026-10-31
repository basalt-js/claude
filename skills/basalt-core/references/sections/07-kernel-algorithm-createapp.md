## 7. Kernel algorithm — `createApp` (exact order from `core.ts` + `app.ts`)

1. `allPlugins = [...frameworkDefaults, ...consumerExtras]`. Consumers cannot remove defaults.
2. `validatePlugins` checks three things:
   - **Reserved names:** `start stop emit require has config global state __proto__ constructor prototype`.
   - **Duplicates.**
   - **Dependencies:** each `depends` entry must exist and must come earlier in the list, matched **by name**.
3. `checkCorePluginConflicts`: a regular plugin's name must not equal a core plugin's name.
4. `pluginNameSet` = core plugin names + regular plugin names.
5. **Global config:** `Object.freeze({ ...defaults, ...consumer.config })`.
6. **Core plugins**, in forward order: 4-level merge and freeze → `createState({config})` → `api({config,state})` → `onInit({config,state})`. Core APIs go into `coreApis` and into the shared `apis` map.
7. **Regular plugin configs:** a 3-level merge (spec → framework → consumer), then freeze.
8. **States:** `createState({ global, config })`, or `{}` if absent.
9. **Error handler:** `combinedOnError` calls the framework `onError(err, coreApis)` (guarded) and then the consumer `onError(err, callbackCtx)`.
10. **Event bus:** `hookMap: Map<event, handler[]>`.
11. **Hooks registered** for every plugin in forward order: `hooks(ctx)` is called and its handlers are appended. *This happens before any regular API exists* (see §16 Q1).
12. **APIs built** in forward order: `apis.set(name, api(ctx))`.
13. **`onInit`** in forward order, synchronously. The return value is ignored.
14. Framework `onReady({ config })`, then consumer `onReady(callbackCtx)`.
15. `buildApp`: `{ start, stop, emit, require, has, ...all APIs }` → `Object.freeze`.

A fresh `ctx` object is built for every call, but `state` is the same reference each time.
