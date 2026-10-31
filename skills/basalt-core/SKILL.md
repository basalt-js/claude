---
name: basalt-core
description: >
  Basalt's design: the kernel API, frameworks, packages and decisions, from the design doc in
  basalt-js/core, split by section behind a short index. Use before any architecture decision in a
  Basalt project, and when the user asks how Basalt works. Triggers on: "basalt architecture",
  "basalt design", "@basalt-js/core", "defineFramework", "definePlugin", "defineService",
  "compose", "createApp", "basalt plugin", "basalt service", "basalt events", "dispatch / collect /
  pipe", "shared state", "basalt lifecycle", "app.inspect", "basalt invariants", "Moku to Basalt".
---

# Basalt core design

Open `references/index.md` and follow its rules. In short: find the question in its table, open only the section file it points to (`references/sections/…`), and cite the section you relied on, such as `core §25`.

Don't read the whole `sections/` folder; the index exists so you don't have to.

The sections are copied from `basalt-js/core` at the commit the index names. Maintainers refresh them with `bash scripts/sync-basalt-core.sh` from this plugin's repo.
