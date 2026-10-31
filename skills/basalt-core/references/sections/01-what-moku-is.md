## 1. What Moku is

Moku is a **micro-kernel plugin framework for TypeScript** built for codebases that LLMs write. Its thesis is *constraints, not conventions*. The architecture has three layers, and each layer physically limits the one above it. Generated code is confined to plugins, which talk to each other only through typed APIs and typed events.

```
┌──────────────────────────────────────────────────────────┐
│ Layer 3  Consumer app     createApp(), createPlugin()    │  configure, compose, ship
├──────────────────────────────────────────────────────────┤
│ Layer 2  Framework        createCoreConfig + createCore  │  config shape, events, default plugins
├──────────────────────────────────────────────────────────┤
│ Layer 1  @moku-labs/core  2 runtime functions            │  zero domain knowledge
└──────────────────────────────────────────────────────────┘
```

The kernel does **six things and nothing else**:

1. Collect plugins into an ordered list.
2. Validate them: reserved names, duplicates, dependency presence and order.
3. Resolve config with a shallow merge, never a deep one.
4. Run three lifecycle phases: `onInit` → `onStart` → `onStop`. Stop runs in reverse order.
5. Dispatch strictly typed events with `emit`, fire-and-forget.
6. Freeze the app and all configs. Plugin state stays mutable.

The spec also states what Moku is **not**: a reactive UI framework, a streaming engine, a networking/sync engine, zero-overhead, or batteries-included.
