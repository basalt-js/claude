# Appendix B — Draft LLM prompt fragment for Basalt

```
You are writing code for a Basalt-based app.

LAYERS: @basalt-js/core (kernel; never import in apps) → framework package (defineFramework +
compose; exports createApp, definePlugin, event) → app (createApp + definePlugin from the framework).

PLUGIN:
  export const fooPlugin = definePlugin("foo", {            // name: camelCase identifier
    config:  z.object({ /* … */ }),                           // or a plain object of complete defaults
    events:  { "foo:changed": event<{ id: string }>("…") }, // keys MUST start with "foo:"
    depends: [barPlugin],                                   // listed earlier; ctx.get(barPlugin)
    optionalDepends: [bazPlugin],                           // ctx.find(bazPlugin) → api | undefined
    state:   ({ global, config }) => ({ /* private mutable state */ }),
    api:     ctx => ({ /* sync factory; no emit here; methods may emit */ }),
    hooks:   ctx => ({ "bar:ready": p => { … } }),         // only visible events
    onInit:  async ctx => { /* load/validate; no resources */ },
    onStart: async ctx => { /* acquire; honour ctx.signal */ },
    onStop:  async ctx => { /* release; own state + services only */ },
    helpers: { /* pure static functions */ },
  });

EVENTS: event<P>() notify → ctx.emit (fire-and-forget) | await ctx.dispatch (wait);
        event.collect<P,R>() → await ctx.collect → R[];  event.pipe<T>() → await ctx.pipe → T.
        Events are notifications/contributions; use ctx.get(plugin).method() for requests.

SHARED STATE: read ctx.shared.state.x (readonly); write ctx.shared.actions.setX(v).

PACKS: plugins: [somePack, fooPlugin]  // a pack is a named group of plugins, flattened in place

APP: const app = await createApp({ plugins, config, pluginConfigs });
     await app.start(); app.foo.method(); await app.settled(); await app.stop();

RULES: index.ts is wiring only (~30 lines); logic in api.ts/state.ts/handlers.ts.
       No classes, services, or managers outside definePlugin. No raw console/process.env
       (use ctx.log / ctx.env). Never import @basalt-js/core in app code.
```
