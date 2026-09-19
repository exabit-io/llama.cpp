
---

## Common base achieved 2026-09-20: `gfx906-base` and `gfx906-multi`

Lead: *"We are using applied techniques of algebra here, so everything needs a common base, and that
is v0.4.1."* The technical force of that: patches expressed against one base are **composable terms**
— they can be added, subtracted and attributed. A patch against `b10912` cannot be meaningfully
subtracted from a tree based on `b10913`, so mixed bases make leave-one-out attribution invalid.

### Method that worked: squash-merge, not sequential replay

| approach | conflict hunks |
|---|---:|
| `git rebase` replaying the fork's 148 commits | 30 in **commit 1 alone**, then cascading |
| `git merge --squash mxxm/master` onto v0.4.1 | **11 total, 9 files** |

Sequential replay fights every *intermediate* state of the fork against upstream's churn; the squash
reconciles only the final state. This is the single biggest efficiency finding of the rebase.

### Branches now

| branch | contents |
|---|---|
| `gfx906-base` | v0.4.1 + the substrate's end state (107 files, +15,859/-712), minus two excluded subsystems |
| `gfx906-multi` | `gfx906-base` + **17 of our 29** |
| `gfx906-v041` | our 29 onto bare v0.4.1 (8 clean) — kept only as evidence of which of OUR patches stand alone |
| `backup/gfx906-pre-v041-20260920` (+ tag) | the pre-rebase branch at `1d1361e7a`; `gfx906` untouched |

**The substrate dependency is confirmed and now satisfied:** our 29 went from **8 clean on bare
v0.4.1 to 17 clean on the substrate base**, and the three `q8_repack` commits that previously could
not apply at all now apply cleanly.

### The 12 of ours that still conflict are a SURVEY RESULT, not just work

`31f9483f2` `d19d2568e` `e3a2ccd4a` `b349bc5a1` `180c64356` `6e3477f1a` `4a8c5d36a` `9931a712b`
`ad4f38604` `5b7794476` `17dfa2336` `c9ce0c4e0`

Hypothesis tested and **rejected**: none of them matches an mxxm commit subject, so they are not ports
of substrate work that could simply be dropped. They are our own patches that **independently modify
the same regions** as the substrate — `mmvq.cu`, the `ggml-cuda.cu` fusion path,
`gated_delta_net.cu`, `speculative.cpp`. That makes them candidates for the
**`conflicts-with-another-patch`** bin (D12), and the conflict cannot be resolved by choosing a side:
the interaction has to be measured on both axes.

### Excluded from the base, now survey candidates in their own right

Both resolved to upstream so the base builds; bin `technique-requires-implementation`:
1. **`ggml-cuda/mmq.cu`** — the fork's chunked column loop versus upstream's NVFP4 `mmq_args`.
2. **`common/speculative.cpp`** — the fork's `process_decode` MTP mirroring versus upstream's virtual
   `process(const llama_batch &)`; plus draft TP sizing versus upstream's single-device LAYER pinning.

### Not done, deliberately

- **No build, no test, nothing binned.** The dies were running the closing benchmark sequence and a
  build beside a loaded four-die job risks the envelope.
- **Nothing pushed.** Pushing unbuilt, ungated branches to the public `exabit-io/llama.cpp` would
  publish code that has never compiled. Push after a build and the C5 Phase-3 gate (perplexity +
  `test-backend-ops`).
- The single-user lineage (`/root/mx-llama.cpp-b10912`, 10 of our patches on mxxm `b10912`) is not yet
  rebased. On the common base it should become a `gfx906-single` **branch** of this repo rather than a
  separate tree, since its 10 commits are the same logical patches as 10 of the 29 here.
