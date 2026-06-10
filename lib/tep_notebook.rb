# Tep::Notebook — the domain-agnostic notebook engine for the toy/tao/tep
# stack (design: ../livebook/DESIGN.md). Cells with explicit named inputs,
# Output = stream + terminal, and (later) RunStore + cost-class staleness.
# Knows nothing about Toy, ML, or events.jsonl — that mapping lives in the
# Tao adapter layer (tao/docs/livebook-seams.md).
#
# Pure Ruby, no runtime deps, Spinel-compilable. Files are required
# individually (no autoload/tree-shaking under Spinel).
require_relative "tep_notebook/version"
require_relative "tep_notebook/output"
require_relative "tep_notebook/cell"
require_relative "tep_notebook/document"
