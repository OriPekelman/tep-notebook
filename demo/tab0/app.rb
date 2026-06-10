require "tep"
# tep build inlines require_relative trees (vendored by spinel-compat);
# requiring the gem entry directly avoids re-inlining tep via deps.rb.
# The seed keeps uncalled public methods concretely typed (RFC spinelgems#13).
require_relative "vendor/spinel/tep-notebook/lib/tep_notebook"
require_relative "vendor/spinel/tep-notebook/lib/tep_notebook/seed"

# tab0 — one hardcoded notebook, served natively (DESIGN.md §7.4).
# Three cells in the Phase-0 shape: config (:value) → training (:task,
# :expensive, stream + terminal) → figure (:cheap, depends on the run).
DOC = Tep::Notebook::Document.new("tab0 — walking skeleton")

cfg = Tep::Notebook::Cell.new("config", :value, "STEPS: 5\nSEED: 0\nD_MODEL: 64")
cfg.output.finish!("text", "parsed: 3 hyperparameters")
DOC.add(cfg)

train = Tep::Notebook::Cell.new("train", :task, "toy train data/tiny.gguf",
                                { "config" => "config" }, :expensive)
train.output.running!
train.output.push({ "kind" => "step", "step" => 1, "loss" => 6 })
train.output.push({ "kind" => "step", "step" => 2, "loss" => 5 })
train.output.finish!("text", "run_end: reason=completed final_loss=5")
DOC.add(train)

fig = Tep::Notebook::Cell.new("figure", :prose, "loss curve over the run stream",
                              { "run" => "train" })
fig.output.finish!("html", "<svg width=\"80\" height=\"20\"><line x1=\"0\" y1=\"0\" x2=\"80\" y2=\"20\" stroke=\"black\"/></svg>")
DOC.add(fig)

get "/" do
  DOC.to_html
end
