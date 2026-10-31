## 28. Introspection

### `app.inspect(options?) → AppManifest`

The manifest is frozen and JSON-serialisable:

```ts
type AppManifest = {
  framework: { id: string };
  status: AppStatus;
  services: Array<{ name: string; depends: string[]; api: string[]; config?: object }>;
  plugins: Array<{
    name: string; index: number; origin: "framework" | "app";
    depends: string[]; optionalDepends: string[];
    api: string[];                                  // method/namespace keys
    events: string[];                               // declared (owned)
    hooks: string[];                                // subscribed
    lifecycle: Array<"onInit" | "onStart" | "onStop">;
    config?: object;                                // only with { config: true }
  }>;
  events: Array<{ name: string; kind: "notify" | "collect" | "pipe";
                  description?: string; owner: string /* "framework" | plugin */;
                  listeners: string[] }>;
  shared: { keys: string[]; actions: string[] };
};
```

- **Config values are excluded by default**, because they may hold secrets. `inspect({ config: true, redact?: (path, value) => value })` includes them.
- **Static introspection** (no app needed): `inspectPlugin(def)` and `framework.inspect()`. Event catalogs are plain data on definitions, so docs generators, `llms.txt` builders, linters, and agents can read a framework without running it.

**Uses:**
- generated plugin READMEs and event tables;
- generated `llms.txt` sections;
- devtools panels;
- architecture validators (dependency graph, orphan events, events nobody listens to);
- "what can I hook?" autocomplete for agents.
