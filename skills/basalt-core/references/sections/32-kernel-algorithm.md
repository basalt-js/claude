## 32. Kernel algorithm (Basalt)

```
compose(options):
  validate(defaults)                         // names, identity dupes, deps, catalogs, hooks targets
  freeze plan; return { createApp, createAppSync }

createApp(options):                          // async
  plugins = flattenPacks([...plan.defaults, ...options.plugins])
  validate(plugins)                                             // + every plugin from this framework
  global  = freeze(await resolveConfig(framework.config, options.config))   // defaults or schema
  shared  = createSharedStore(framework.shared)                 // per instance
  bus     = createBus(catalog(plugins), tracers, onError, checks)
  for s in services:   cfg(4-level merge → await schema) → state → api → await onInit
  for p in plugins:    cfg(3-level merge → await schema) → state(StateContext)
  phase = "wiring"                                              // emit* throws
  for p in plugins:    apis[p] = p.api(WiringContext(p))         // get(dep) OK if built, else E_NOT_READY
  for p in plugins:    bus.register(p, p.hooks(PluginContext(p))) // all APIs exist
  phase = "live"
  for p in plugins:    await p.onInit(PluginContext(p))          // createAppSync: thenable → E_ASYNC_INIT
  await framework.onReady(appCtx); await consumer.onReady(appCtx)
  status = "ready"; return freeze(app)
```

`start`/`stop`/rollback follow §27. Every phase boundary writes a trace record.
