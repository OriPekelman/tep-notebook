# Type seed: executable call sites for every public method, so Spinel's
# whole-program analyzer sees concrete argument types even for methods the
# consuming app never calls (uncalled publics otherwise widen to int/poly
# and mismatch the typed body). Same role as the seed block in tep's
# lib/tep.rb; an app that doesn't call the full API requires this file
# explicitly after vendoring.
#
# NOTE: the per-gem seed *convention* is unresolved — RFC spinelgems#13
# proposes shipping sig/*.rbs as type roots instead, which would retire
# this file. Until that lands, this is the zero-infrastructure version:
# cheap, side-effect-free, runs at require.
require_relative "../tep_notebook"

_tnb_doc = Tep::Notebook::Document.new("seed")
_tnb_cell = Tep::Notebook::Cell.new("c1", :value, "x = 1", { "in" => "c0" }, :expensive)
_tnb_doc.add(_tnb_cell)
_tnb_doc.fetch("c1")
_tnb_doc.dependents_of("c0")
_tnb_doc.to_html
_tnb_doc.cell_html(_tnb_cell)
_tnb_doc.esc("a&b")
_tnb_doc.title
_tnb_doc.cells
_tnb_cell.id
_tnb_cell.kind
_tnb_cell.source
_tnb_cell.inputs
_tnb_cell.cost_class
_tnb_cell.expensive?
_tnb_cell.depends_on?("c0")
_tnb_out = _tnb_cell.output
_tnb_out.running!
_tnb_out.push({ "kind" => "note", "t" => 0 })
_tnb_out.finish!("text", "done", :ok)
_tnb_out.stale!
_tnb_out.finished?
_tnb_out.stream_length
_tnb_out.each_event { |_e| }
_tnb_out.terminal
_tnb_out.status
_tnb_out.make_terminal("text", "x")
