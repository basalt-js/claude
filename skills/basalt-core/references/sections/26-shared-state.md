## 26. Shared state

```ts
defineFramework("site", {
  shared: {
    initial: () => ({ locale: "en", user: null as User | null }),
    actions: {
      setLocale: (s, locale: string) => { s.locale = locale; },
      signIn:    (s, user: User)     => { s.user = user; },
    },
  },
});

ctx.shared.state.locale;              // DeepReadonly<S> view
ctx.shared.actions.setLocale("de");   // the only way to write
```

**Rules:**

1. **Framework-owned.** Only `defineFramework` declares shared state, like global config. Consumer apps that need shared data write a plugin with an API, as in Moku.
2. **Per app instance.** It is created inside `createApp` and is never module-level, so multiple apps, tests, and worker isolates stay independent.
3. **Writes only through actions.**
   - Actions are **synchronous**; async work happens in plugin APIs before an action is called.
   - After each action the kernel emits `basalt:shared` `{ action, source }`, attributing the plugin that called it, and writes a trace record.
4. **Reads are type-readonly.** The view is typed `DeepReadonly<S>`. Under `checks: "full"` it is a write-trapping `Proxy` that throws `E_SHARED_READONLY`. Under `"minimal"` the raw object is returned at zero cost.
5. **Plugin state stays private.** Shared state is for genuinely app-wide facts (locale, auth identity, feature flags, theme). It does not replace plugin APIs.
6. **Not for request-scoped data.** A worker isolate serves concurrent requests, so request data belongs in call arguments or a scope (§O7).

**Decision:** actions over a free mutable object. Without that constraint shared state becomes a global-variable dumping ground, which is exactly what Moku's design avoids. Actions give a single write path, attribution, and change events.
