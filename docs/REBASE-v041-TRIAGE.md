
---

## Repo topology CONFIRMED by the lead 2026-09-20 — collapse, do not replicate

One code repo, three branches, a common base:

```
exabit-io/llama.cpp                     (remote `origin`, already exists)
  gfx906-base    = v0.4.1 + the mxxm substrate      -> the shared term everything composes on
  gfx906-multi   = gfx906-base + multi-user set     -> /opt/llama.cpp-gfx906
  gfx906-single  = gfx906-base + single-user set    -> /opt/llama.cpp-mxxm-fh
  remotes: upstream (ggml-org/llama.cpp), mxxm (mxxm-t/mx-llama.cpp)
```

This replaces **six source trees** with one repo. The three pristine upstream checkouts
(`/root/llama.cpp` @ b10288, `llama.cpp-b10837`, `llama.cpp-b10859`) have zero local commits and need
no rebase at all — they are historical reference checkouts. The two `mx-llama.cpp-*` trees become
read-only provenance.

### The measured justification for a common base

The single-user patch set is **10 commits**, and every one maps 1:1 to a multi-user twin. Applying each
set to `gfx906-base`:

| | clean | conflict |
|---|---:|---:|
| multi-user set (29) | 17 | 12 |
| single-user set (10) | 1 | 9 |

**The 9 conflicting single-user patches are the SAME patches as 9 of the 12 conflicting multi-user
ones.** They overlap the substrate in `mmvq.cu`, the `ggml-cuda.cu` fusion path and
`gated_delta_net.cu`. On the shared base they are resolved **once** and both profiles inherit the
result; on the old split bases (multi on b10913+merges, single on b10912) the identical resolution had
to be done twice. That is the duplication the collapse removes, and it is why R2.7's two profiles
should be two branches rather than two repos.

### Remaining work, scoped

1. **Resolve the 9 shared + 3 multi-user-only conflicts once against `gfx906-base`.** These are
   genuine overlaps between our patches and the substrate, so each is also a
   `conflicts-with-another-patch` candidate whose interaction must be measured on both axes.
2. **Build and run the C5 Phase-3 gate** (perplexity 16K/6 + `test-backend-ops`) on all three branches.
3. **Then push** all three to `exabit-io/llama.cpp`. Not before: pushing branches that have never
   compiled to a public repo is not acceptable.
4. Tidy: drop the temporary local `single-src` remote and the scratch branches
   (`gfx906-v041-full`, `gfx906-b10254`, `mxxm-b10*`) once the resolution lands.

---

## IMPORTANT: what `gfx906-base` contains today is NOT "the patches that help both profiles"

Lead asked 2026-09-20: *"gfx906-base contains the set of patches that improve performance on both
gfx906-single and also gfx906-multi?"* **No — and the name invites exactly that error.**

**Today** `gfx906-base` = v0.4.1 + the **entire mxxm substrate end-state, untested and unbinned**.
Nothing in it has been measured on either axis. Some of it may regress one or both profiles. It is a
scaffold to begin binning from, not a binned result. (Same class of error as saying we "hold" the 148
commits — language that smuggles in a verdict.)

**After the survey**, the composition becomes:

| bin | goes to |
|---|---|
| `both` | `gfx906-base` |
| `neutral-required-substrate` | `gfx906-base` — see below |
| `multi-user-only` | `gfx906-multi` |
| `single-user-only` | `gfx906-single` |
| `regresses-both` | dropped |
| `conflicts-with-another-patch` | resolved per profile |
| `upstream-already-has-it` | dropped — already in v0.4.1 |
| `technique-requires-implementation` | in no branch until implemented |

**Proposed rename to stop the name lying:** the current branch becomes **`gfx906-substrate-v041`**
(the unbinned substrate on the common base) and **`gfx906-base` is reserved** for the post-survey
composition of `both` + required substrate. Topology as approved by the lead is unchanged.

**A gap in the bin taxonomy this exposes.** Some substrate patches are *enabling infrastructure*, not
optimisations — the meta/TP backend, the `q8_repack/` files. Each may measure as **neutral in
isolation while being required** by patches that do win: proven already, since our three repacked
mat-vec patches cannot even apply without `q8_repack/`. So `neutral` must not imply "drop". It needs
splitting:

- **`neutral-drop`** — no gain on either axis and nothing depends on it. Remove.
- **`neutral-required-substrate`** — no gain of its own, but a winning patch depends on it. Keep in
  the base, and record in the verdict which patch requires it.

Without that split, composing the builds from the bins would delete files that dependent patches need,
and the composition would not build.
