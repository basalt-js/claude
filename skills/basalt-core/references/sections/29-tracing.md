## 29. Tracing

```ts
type Tracer = (record: TraceRecord) => void;

type TraceRecord =
  | { kind: "status";  at: number; from: AppStatus; to: AppStatus }
  | { kind: "phase";   at: number; phase: "init" | "start" | "stop" | "rollback";
      target: string; status: "begin" | "end" | "error"; durationMs?: number; error?: unknown }
  | { kind: "event";   at: number; id: number; parentId?: number;
      mode: "emit" | "dispatch" | "collect" | "pipe"; event: string; source: string }
  | { kind: "handler"; at: number; eventId: number; event: string; plugin: string;
      status: "end" | "error"; durationMs: number; error?: unknown }
  | { kind: "shared";  at: number; action: string; source: string };
```

**Sources.** Tracers can be set in `compose` (framework) and in `createApp` (consumer), and both receive every record.

**Attribution.** Each plugin's `emit*` is bound to its name, so `source` is always known (fixes Q9). For the app object, `source` is `"app"`.

**Cost.** With no tracer, the cost is a single boolean check per site.

**Isolation.** Tracers are **not** on the event bus, which avoids recursion. A throwing tracer is swallowed.

**Causality (O6, decided).** `parentId` links an emit to the handler that caused it. On its own, the kernel tracks this only for the synchronous part of a handler. A framework can pass `compose({ contextStore })`: any object with `run(value, fn)` and `get()`, which `AsyncLocalStorage` satisfies. Links then survive `await`. The kernel never imports it, so it stays runtime-agnostic.

**Ready-made tracers** ship in `@basalt-js/std`:
- `consoleTracer()` — pretty, filterable;
- `memoryTracer()` — for test assertions such as `expect(trace).toContainEvent("router:navigate")`;
- `otelTracer()` — later, optional, as a separate package.
