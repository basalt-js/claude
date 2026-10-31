## 35. The Basalt framework contract

Every Basalt framework package must:

1. Call `defineFramework` once and `compose` once, and export **documented consts**: `createApp`, `createAppSync`, `definePlugin`, `event`, plus plugin definitions and helpers. Never destructured exports.
2. Re-export everything a consumer needs, so **apps never depend on `@basalt-js/core`**. The guardrail is a lint rule (§38).
3. Publish separate **entry points per runtime** where needed (`.`, `./browser`, `./worker`). Each entry composes its own default plugins, and node-only plugins never leak into browser bundles.
4. Ship `llms.txt` generated from `framework.inspect()` plus hand-written guidance.
5. Use the kernel primitives instead of reinventing them:
   - **collect events** for contributions (routes, head tags, sitemap entries, CLI commands);
   - **pipe events** for transforms and middleware (request → response, markdown → HTML);
   - **shared state** for app-wide facts;
   - **services** for infrastructure.
6. Keep resource handles out of shared state. Anything request-scoped is passed as arguments (see O7).
