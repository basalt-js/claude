## 17. Goals and non-goals

**Goals:**

- **G1:** Keep Moku's *constraint model*: layered guardrails, inference-only authoring, strict events, frozen contracts, and explicit order.
- **G2:** Fix every Part I §16 finding by design, not by documentation.
- **G3:** Add the four capabilities: shared state, introspection + tracing, async init + awaitable events, and lifecycle robustness.
- **G4:** Keep the kernel small: zero runtime deps, runs on Bun / Node ≥ 24 / browsers / edge workers, target **≤ 12 KB gzipped**.
- **G5:** Keep the whole API learnable from one prompt fragment of about 1500 tokens (Appendix B).

**Non-goals** (unchanged from Moku):
- topological sorting;
- deep merging;
- DI containers, classes, or decorators;
- reactive UI, streaming, or networking inside the kernel;
- letting consumers remove framework defaults.
