## 31. Type-system plan

**Reuse from Moku** (§12): items 1–3, 5–10, and 12.

**Change:**
- **`events` as plain data with `event<T>()` descriptors.** This removes the context-sensitivity hazard (§12.11). A generic function call inside an object literal is not context-sensitive, so it is inferred in TypeScript's first pass.
- **Event descriptors carry `kind`, payload, and result types** (`EventDescriptor<"collect", P, R>`). The mode signatures filter on `kind`.
- **The namespace rule as a type:**

  ```ts
  { [K in keyof E]: K extends `${N}:${string}` ? EventDescriptor<any, any, any> : never }
  ```

  It is checked against the inferred `const N`. *(Verify with a prototype that error messages stay readable.)*
- **`ctx.get`/`ctx.find` are constrained** to `Deps[number]` / `OptionalDeps[number]`.
- **`PluginCtx<{ config; state; events; depends?; optionalDepends? }>`** builds the extracted-domain-file context. `emit` uses Moku's overload technique (`EmitFn`), and so do `dispatch`, `collect`, and `pipe`.
- **`App` types every mode with the union of all events** visible in the app.
- **Config schemas:** when `config` is a schema, `ctx.config` is `InferOutput<S>` and overrides are `Partial<InferInput<S>>`. A conditional type on the `~standard` key picks between this and the plain-object path.
- **Packs:** `plugins` arrays accept packs, and a type-level flatten turns `[Pack<[A, B]>, C]` into `A | B | C` for the `App` surface.
- **Shared state:** `S` is inferred from `initial()`, and the action parameter `s` is contextually typed from it. `DeepReadonly<S>` is used for the view, and actions are exposed as `(…args) => void` with the state parameter dropped.

**Type tests are first-class** (`expectTypeOf`, `@ts-expect-error`). Every row of §16 and §30 that has a compile-time side gets a test. Run them in CI against TS 6.x and 7.x, as Moku does.
