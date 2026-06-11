# frozen_string_literal: true

require_relative "lib/tep_notebook/version"

Gem::Specification.new do |spec|
  spec.name    = "tep-notebook"
  spec.version = Tep::Notebook::VERSION
  spec.authors = ["Ori Pekelman"]
  spec.email   = ["ori@pekelman.com"]

  spec.summary  = "Tep::Notebook — domain-agnostic notebook engine (cells, outputs, documents) for the toy/tao/tep stack"
  spec.description = "The first external Tep battery: a Pluto-style notebook model adapted to " \
                     "slow-feedback ML work. Cells with explicit named inputs, Output = " \
                     "stream + terminal, cost-class staleness (engine logic to come). Pure " \
                     "Ruby, no runtime deps, Spinel-compilable via the spinelgems convention."
  spec.homepage = "https://github.com/OriPekelman/tep-notebook"
  spec.license  = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir["lib/**/*.rb"] + Dir["sig/**/*.rbs"] + %w[README.md]
  spec.require_paths = ["lib"]

  # Pure Ruby — no spinel-ext.json, no native extensions, no runtime deps.
  # The v0 *engine* (LiveView transport) will depend on tep; the model layer
  # deliberately doesn't (livebook DESIGN.md §6 "transport-free inner module").
end
