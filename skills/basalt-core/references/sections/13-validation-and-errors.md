## 13. Validation and errors

The format is `[<framework-id>] <description>.\n  <actionable suggestion>.` Validation errors are `TypeError`s and lifecycle errors are `Error`s.

**`createPlugin` and `createCorePlugin` validate:**
- the name is a non-empty string;
- the spec is an object;
- `api`, `createState`, `onInit`, `onStart`, `onStop`, `events`, `hooks` are functions when present;
- `helpers` is an object of functions whose keys don't collide with `name`/`spec`/`_phantom`.

`createCorePlugin` also rejects `depends`, `events`, and `hooks`.

**`createApp` validates** reserved names, duplicates, dependency presence and order, and core/regular name conflicts.

**At runtime** the kernel throws for `require` of an unregistered plugin (three message variants: plugin, app, callback), `start()` twice, and `stop()` before `start()`.
