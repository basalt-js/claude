## 3. The factory chain

There are three steps, and each one captures types in a closure and hands them downstream:

```ts
// framework/config.ts — Step 1: bind Config + Events (+ core plugins)
export const coreConfig = createCoreConfig<Config, Events>("my-site", {
  config: { siteName: "Untitled", mode: "development" },
  plugins: [logPlugin, envPlugin],          // core plugins (optional)
  pluginConfigs: { log: { level: "warn" } } // core-plugin overrides (optional)
});
export const { createPlugin, createCore } = coreConfig;

// framework/plugins/router.ts — plugins import the BOUND createPlugin
export const routerPlugin = createPlugin("router", { /* spec */ });

// framework/index.ts — Step 2: bind default plugins
export const { createApp, createPlugin } = createCore(coreConfig, {
  plugins: [routerPlugin],
  pluginConfigs: { router: { basePath: "/" } },
  onReady: ({ config }) => {}, onError: (err, coreApis) => {}
});

// app/main.ts — Step 3: consumer
const app = createApp({ plugins: [blogPlugin], config: { siteName: "Blog" },
  pluginConfigs: { router: { basePath: "/blog" } }, onReady, onError, onStart, onStop });
await app.start(); app.router.navigate("/about"); await app.stop();
```

**Why three steps and not two.** Plugin files need a `createPlugin` that is bound to `Config`/`Events`, and the framework's index needs the plugins. If one call did both, `config.ts` and the plugin files would import each other. Splitting setup into Step 1 (`config.ts`) and Step 2 (`index.ts`) breaks that cycle.

Consumers never import `@moku-labs/core`. The Moku tooling treats a direct import as a blocker.
