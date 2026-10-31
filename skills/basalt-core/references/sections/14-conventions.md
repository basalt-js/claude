## 14. Conventions (outside the kernel, but part of the product)

**Plugin tiers** (spec 15):

| Tier | Size | Layout |
|---|---|---|
| Nano | < 30 lines | `index.ts`, `README.md`, `__tests__/unit/` |
| Micro | 30–80 lines | `index.ts`, `README.md`, `__tests__/unit/` |
| Standard | Any domain function > 20 lines | `index.ts` (~30-line wiring harness), `types.ts`, `state.ts`, `api.ts`, `handlers.ts`, `helpers.ts` |
| Complex | Sub-domains | Adds subfolders such as `providers/` or `transforms/` (one barrel level max) |
| Very complex | Coupled modules | Module dirs (`content/`, `media/`, …), each with `types/state/api`. Namespaced API (`app.cms.content.create()`), composed state, the plugin owns all events. |

**File contracts:**
- `index.ts` only wires. It holds no logic and no types.
- `state.ts` exports `create<Name>State`, has no side effects, and never emits.
- `api.ts` exports `create<Name>Api` and does no init and no I/O.
- `handlers.ts` holds thin dispatchers.
- Plugins never import each other's internals. They import instances only, for `depends`.

**JSDoc:**
- Lint requires description, `@param`, `@returns`, and `@example` on everything in `src/`.
- API docs go on the exported `XxxApi` type members, because implementation JSDoc never reaches the `.d.ts`.
- **Public export shape:** never `export const { createApp } = createCore(...)`. A destructured binding loses its JSDoc in emitted `.d.ts`, so use `export const createApp = framework.createApp` with its own doc block.

**Tests** use Vitest projects:
- `unit`;
- `integration` (real `createApp`);
- `sandbox` (realistic multi-plugin frameworks plus type tests via `expectTypeOf` and `@ts-expect-error`).

Per plugin: `__tests__/unit/*.test.ts` (flat) and `__tests__/integration/<plugin>.test.ts`. Coverage thresholds are 90%.

**LLM surface:**
- `llms.txt` (~10 KB) and `llms-full.txt` (~31 KB) at the repo root.
- A ready-made "system prompt fragment" (spec 12 §5) that teaches the whole API in under ~1000 tokens.
