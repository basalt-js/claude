## 36. Planned packages (outline; each gets its own spec)

| Package | Kind | Contents | Kernel features it leans on |
|---|---|---|---|
| `@basalt-js/core` | Kernel | Part II. | — |
| `@basalt-js/std` | Shared infra | `logService`, `envService` (validated, provider-based), `clockService` (testable time); `consoleTracer`, `memoryTracer`; branded CLI kit; test utilities (`createTestApp`, mock contexts built from `PluginCtx`). | services, tracing |
| `@basalt-js/web` | Framework | Moku-web's model (SSG/SPA/hybrid, islands, route builder, content providers, head/SEO, build/deploy/cli). | `collect` for `head` tags, sitemap and feed entries, and route contributions; `pipe` for the content transform chain (markdown → HTML → sanitize → directives); shared state for `locale`/`stage`; tracer drives the dev CLI's live build panel; `inspect()` produces the build report. |
| `@basalt-js/worker` | Framework | Moku-worker's model (server/endpoints, KV/D1/R2/Queues/DO keyed maps, deploy manifest). | `pipe` for request middleware (`server:request` → `Response`); `collect` for endpoint and binding manifests (deploy reads `inspect()`); lifecycle timeouts for cold start. |
| Plugin packs (`@basalt-js/room`, …) | Pack | Built with `framework.pack(...)` (below). | — |

**Plugin packs (O8, decided).** A pack is a named, ordered group of plugins made for one framework:

```ts
// @basalt-js/room (built for @basalt-js/web)
export const stagePack = web.pack("roomStage", [peerPlugin, syncPlugin, stagePlugin]);

// app
const app = await createApp({ plugins: [stagePack, gamePlugin] });
app.stage.lobbyCode();   // pack plugins are typed like any other plugin
```

- **Flattened in place.** `compose` and `createApp` accept packs in `plugins` and flatten them where they appear, keeping order. Every rule (order, `depends`, names) applies to the flattened list.
- **Same framework only.** Every plugin in a pack must come from the pack's framework, and the pack must match the app's framework (`E_FOREIGN_PLUGIN`).
- **Flat and config-free (O16, decided).** Packs can't contain or depend on other packs, and they carry no default `pluginConfigs`. Their plugins are configured through `pluginConfigs` like any other plugin.
- **Visible.** `inspect()` shows `pack: "roomStage"` on each plugin that came from a pack.

**Request scope (O7, decided):** deferred to the `@basalt-js/worker` spec.
