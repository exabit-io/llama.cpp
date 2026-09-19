
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
