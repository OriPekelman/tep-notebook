# tep-notebook

`Tep::Notebook` — the domain-agnostic notebook engine for the
[toy](https://github.com/OriPekelman/toy) /
[tao](https://github.com/OriPekelman/tao) /
[tep](https://github.com/OriPekelman/tep) stack, and the first *new*
external Tep battery. Design: `../livebook/DESIGN.md` (this repo is that
design becoming its own lib). Tao's side of the contract:
`tao/docs/livebook-seams.md`.

Status: **walking skeleton** (DESIGN.md §7.4). The model layer exists and
a demo app compiles to a native binary; the engine logic (fingerprints,
RunStore, DAG staleness propagation, LiveView transport) is deliberately
not here yet.

## The model (DESIGN.md §3)

- **`Cell`** — `id`, `kind` (`:prose | :value | :task`), `source`,
  explicit named `inputs` (the DAG edges — never inferred), `cost_class`
  (`:cheap` reactive / `:expensive` manual ▶), `output`.
- **`Output`** — append-only `stream` of `"kind"`-tagged events plus a
  typed `terminal` payload; `status` ∈ `:pending/:running/:ok/:stale/:error`.
  toy/v1's `events.jsonl` is an instance of this shape; the engine doesn't
  know that — the Tao adapter does the mapping.
- **`Document`** — ordered cells, lookup, dependents-of, and a minimal
  static `to_html` (live deltas come with the Tep transport later).

Pure Ruby, zero runtime deps, no metaprogramming — Spinel-safe by
construction. The v0 *engine* will depend on `tep` for the live stack
(DESIGN.md §7.3); the model layer stays transport-free (§6).

## Consuming from a Spinel app

Standard spinelgems convention (same path `toy` uses for `tep`):

```
gem "tep-notebook"        # Gemfile
bundle lock               # NOT bundle install (engine: spinel marker)
spinel-compat vendor      # → vendor/spinel/tep-notebook/lib/ + deps.rb
```

Pure Ruby — no `spinel-ext.json`, nothing to compile at vendor time.

### Type seeding (RFC spinelgems#13, open)

Uncalled public methods widen under Spinel's whole-program inference. If
your app doesn't exercise the full API, also require the seed (executable
call-site soup, same role as tep's own seed block):

```ruby
require_relative "vendor/spinel/tep-notebook/lib/tep_notebook/seed"
```

When RFC spinelgems#13 lands (gem `sig/*.rbs` as type roots), the seed
file retires in favor of shipped RBS.

## Demo: the walking skeleton

`demo/tab0/` is the ~20-line throwaway Tep app from DESIGN.md §7.4 — it
depends on `tep` + this gem (by path), vendors both, and compiles to a
native binary serving one hardcoded three-cell notebook (config →
training → figure, the Phase-0 shape):

```
cd demo/tab0
./bin/build          # bundle lock → vendor → tep build → ./tab0
./tab0 -p 4567
curl localhost:4567/
```

Green binary ⇒ the external-battery mechanism is proven; every later
phase just fills in DESIGN.md §3.

## Development (CRuby)

```
ruby -Ilib -Itest test/notebook_test.rb   # or: rake test
```

Tests run under CRuby (3.2+); Spinel parity is what the demo build
checks.
