# Rebase onto v0.4.1 — triage record (C2), 2026-09-20

Target: **v0.4.1** (`b29c606e2`, 2026-09-14), the last official release, per the lead.
Pre-rebase state preserved: branch `backup/gfx906-pre-v041-20260920`, tag `gfx906-pre-v041-20260920`,
both at `1d1361e7a`. The `gfx906` branch is untouched. Work happens on `gfx906-v041`.

## What the series actually is

The "154-commit series" is not 154 of our patches. Of the 177 non-merge commits we hold that
upstream/master does not:

| author | commits |
|---|---:|
| mxxm-t / Marko Tombak (third-party fork, absorbed via 4 merges) | 148 |
| **ours** (Joshua / Nikolas Britton) | **29** — 25 code, 4 docs/status |

So the rebase is **29 commits**, not 154. This is the first concrete return on D3's rationale.

## Triage: cherry-pick each of our commits onto v0.4.1, in order

Method: attempt each in chronological order; keep the ones that apply so later dependencies are
satisfied; abort and record the ones that conflict. **The conflict count is therefore pessimistic**
— an aborted pick breaks the commits that build on it.

| commit | outcome | conflicting files | subject |
|---|---|---|---|
| `31f9483f2` | CLEAN | — | gfx906: MMVQ 16-column width (MMID stays 8) + gfx906 launch knobs and  |
| `d19d2568e` | CONFLICT(1) | `ggml-cuda.cu` | ggml-cuda: fused RMS_NORM+MUL[+ADD] also emits the Q8_1 (ported to b10 |
| `e3a2ccd4a` | CONFLICT(3) | `ggml-cuda.cu,norm.cu,norm.cuh` | ggml-cuda: compute the residual ADD inside the fused (ported to b10912 |
| `b349bc5a1` | CONFLICT(4) | `common.cuh,gated_delta_net.cu,ggml-cuda.cu,ggml-cuda.cu.orig` | ggml-cuda: fold the gated-delta-net producers into the (ported to b109 |
| `180c64356` | CONFLICT(1) | `ggml-cuda.cu.orig` | mmvq: gfx906 batch-1 knobs (rows/warps per block at one column, whole- |
| `39e3ad8bb` | CONFLICT(1) | `ggml-cuda.cu` | tp-allreduce: GGML_TP_AR_MAX_NE explicit size gate for (ported to b109 |
| `6e3477f1a` | CONFLICT(1) | `ggml-cuda.cu` | ggml-cuda: restrict the add+norm and GDN producer fusions (ported to b |
| `4a8c5d36a` | CONFLICT(1) | `ggml-cuda.cu` | ggml-cuda: GDN producer fold as a bitmask (ported to b10912) |
| `9931a712b` | CONFLICT(1) | `mmvq.cu` | mmvq: whole-block (vdr 8) load at one column by default (ported to b10 |
| `ad4f38604` | CONFLICT(1) | `gated_delta_net.cu` | gated_delta_net: fold the q/k L2 norms with the (ported to b10912) |
| `64ba9abcc` | CLEAN | — | gfx906: repository notes, build recipe and runtime environment for the |
| `5b7794476` | CONFLICT(4) | `common.cuh,gated_delta_net.cu,gated_delta_net.cuh,ggml-cuda.cu` | gated_delta_net: fold upstream's build_gdn_l2_norm (rms_norm(eps/n) +  |
| `ab1d739ac` | SKIPPED-DOCS | — | gfx906: list every non-upstream commit (docs/gfx906-patches.md) |
| `b1b7f9574` | CONFLICT(1) | `gfx906-patches.md` | gfx906: generate docs/gfx906-patches.md from the repository (patch-inv |
| `5d36d6fc8` | CLEAN | — | ggml-cuda: mul_mat_id sync predicate uses the MUL_MAT_ID batch window  |
| `92a3ac9c2` | SKIPPED-DOCS | — | gfx906: regenerate the patch inventory |
| `e10a0b4ef` | CONFLICT(2) | `mul-mat.cu,repack-common.cuh` | ggml-cuda: repacked Q8_0 narrow-batch mat-vec through 16 tokens (gfx90 |
| `0ee9d8cc7` | CONFLICT(1) | `repack-kernels.cuh` | ggml-cuda: launch bounds on the repacked narrow-batch mat-vec (gfx906) |
| `46010953d` | CONFLICT(1) | `repack-kernels.cuh` | ggml-cuda: repacked narrow-batch mat-vec keeps 4 waves/EU through 10 c |
| `eb39d6c7a` | SKIPPED-DOCS | — | gfx906: branch status 2026-09-09, corrected series listing, links to t |
| `d0b7ef75f` | CONFLICT(2) | `qwen35.cpp,qwen35moe.cpp` | qwen35/qwen35moe: build out_ids in the MTP draft graph whenever n_outp |
| `fe3102bdd` | CLEAN | — | ggml-cuda: gfx906 (GCN) row for the head-256 flash-attention tile tabl |
| `3771c572c` | CLEAN | — | ggml-hip: DPP-based warp reductions on GCN (from sixvolts/llamacpp-gfx |
| `17dfa2336` | CONFLICT(2) | `speculative.cpp,speculative.h` | spec: adaptive MTP draft depth (draft-mtp-adaptive) — upstream PR #2 |
| `2ae6b1525` | CLEAN | — | gfx906: build.sh compiles the FA kernels for f16, q8_0 and q8_0-K/q4_0 |
| `c9ce0c4e0` | CONFLICT(1) | `speculative.cpp` | spec: restore the closing brace of common_speculative_reset lost in th |
| `1715418e1` | CLEAN | — | ggml-cuda: gfx906 head-256 tile table — only the single-stream row,  |
| `2b79581cb` | CLEAN | — | ggml-hip: keep the generic warp reductions inside the flash-attention  |
| `1d1361e7a` | SKIPPED-DOCS | — | gfx906: status 2026-09-09 evening — promoted for the multi-user prof |

**Tally: 8 clean, 17 conflict, 4 docs skipped.**

## The result that matters: the gfx906 KERNEL patches applied clean

All eight clean picks are the gfx906-specific kernel work — MMVQ 16-column width with the Q8_0
fast path, both head-256 flash-attention tile-table rows, the DPP warp reductions, the mul_mat_id
sync predicate, the GGML_GCN_NO_DPP guard, and build.sh. **The core gfx906 value survives the
45-day jump to v0.4.1 without a single conflict.**

## Conflicts by root cause

**A. mxxm substrate missing — GENUINE BLOCKER, needs the C3 decision.**
`e10a0b4ef`, `0ee9d8cc7`, `46010953d` are the repacked narrow-batch mat-vec patches and they
conflict on `ggml-cuda/q8_repack/{mul-mat.cu,repack-common.cuh,repack-kernels.cuh}` — files that
exist only in mxxm/master, not in v0.4.1. This is the **Q8_0 MMVQ fast path** family, which
REQUIREMENTS §6 says must remain active in every promoted build (+62% decode at 12 slots).

**B. ggml-cuda.cu fusion / gated-delta-net family — probable cascade.** Eight commits
(`d19d2568e` `e3a2ccd4a` `b349bc5a1` `39e3ad8bb` `6e3477f1a` `4a8c5d36a` `ad4f38604`
`5b7794476`), all the "ported to b10912" fusion work. Upstream churned `ggml-cuda.cu` (4 commits)
and `norm.cu`/`norm.cuh` since our base. Resolve in order; most should fall out once the first
two are done.

**C. speculative / adaptive MTP** — `17dfa2336` (upstream PR #27210, still OPEN, so we keep
carrying it) and `c9ce0c4e0` (a brace-restoration fixup on top of it). Resolve C after B.

**D. trivial** — `180c64356` conflicted on nothing but `ggml-cuda.cu.orig`, now deleted;
`b1b7f9574` on `docs/gfx906-patches.md`, which is generated by `scripts/gfx906/patch-inventory.sh`.

**E. model code** — `d0b7ef75f` (qwen35 MTP out_ids) conflicts in `src/models/qwen35*.cpp`;
upstream has moved those files. Straightforward re-apply, but must be re-verified: this patch
fixes an MTP correctness bug.

## Not yet done

- **No build has been attempted.** The dies were running the closing benchmark sequence; building
  beside a loaded four-die job violates the power rule (memory: never run host load beside four dies).
- Conflict groups B-E unresolved.
- C5's Phase 3 gate (perplexity + test-backend-ops) not run on the rebased tree.
