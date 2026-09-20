
---

## BUILD GREEN 2026-09-20 — `gfx906-substrate-v041` compiles on v0.4.1

`cmake --build` exit 0, zero errors, 124 binaries. It took **five passes and four distinct defect
classes**, every one of them invisible to git:

| pass | defect | file | why git was silent |
|---:|---|---|---|
| 1 | `redefinition of fast_bf16_hardware_available` | `ggml-cuda/common.cuh` | **no textual conflict at all** — the two branches define it at different *places*, so both were merged |
| 2 | `use of undeclared identifier s12 / s13 / ne_get_rows` | `ggml-cuda/mmq.cu` | upstream hunks resolved into the fork's surrounding function |
| 3 | `process_decode` referenced twice, declared zero times (+11 orphan `verify_h`, 9 `pending_h`) | `common/speculative.cpp` | same, worse |
| 4 | 188 x `qualified-id in declaration before '('` | `src/llama-context.cpp` | my **"keep both"** resolution produced two `if`s and an unmatched brace; the error location pointed nowhere near the defect |
| 5 | `common_speculative_reset was not declared` | `tools/server/server-context.cpp` | the fork's server depends on the fork's deferred spec interface |

**The lesson, recorded as T9 in the action plan.** "Conflicts resolved" is a progress note, never a
result. Only a build is evidence, and only a test is evidence the build is right. And `git`'s silence
about a file means nothing once two branches have diverged architecturally — pass 1 had **zero**
conflicts reported and still would not compile.

Note also that "keep both" is as much a side-picking shortcut as "take ours": it is valid only when the
two sides are genuinely **additive** (`llama-arch.cpp`: upstream added an arch case, the fork added a
comment — those coexist), and produces syntactically broken code when both sides modify the same
construct.

### What the green build does and does not contain

Present: the substrate's end state on v0.4.1 — meta/TP backend, `q8_repack/`, MoE fusion, graph/lane
work, the fork's `mtp_prefill_kv_only` KV-only prefill path in `qwen35.cpp`.

**Deferred, all bin `technique-requires-implementation`:**
1. the fork's chunked-column MMQ (upstream's `mmq.cu` taken whole)
2. the fork's `process_decode` MTP draft mirroring and per-draft `tensor_parallel_size`
3. our own adaptive MTP draft depth (upstream PR 27210, still open)
4. `common_speculative_reset` — the draft-state invalidation on slot release

**CONSEQUENCE: this base must not be run with MTP enabled**, and **R3.9's MTP gate is blocked on
implementation work, not measurement.** That is a real scope discovery: R3.9 previously looked like
"run an A/B", and it is actually "reimplement a subsystem against upstream's virtual
`process(const llama_batch &)` interface, then run an A/B".

### Still open before this branch can be pushed

- **C5 gate**: `test-backend-ops` (running) and perplexity 16K/6 against the reference. A green build is
  necessary, not sufficient.
- The 12 conflicts between our patches and the substrate (Stage C4) — and per T9 they must be resolved
  at file granularity or merged semantically, never per-hunk.
- Nothing pushed until the gate passes.
