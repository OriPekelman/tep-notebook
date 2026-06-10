# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "minitest/autorun"
require "tep_notebook"

class NotebookTest < Minitest::Test
  def make_doc
    doc = Tep::Notebook::Document.new("E0 smoke")
    doc.add(Tep::Notebook::Cell.new("config", :value, "STEPS: 5\nSEED: 0"))
    doc.add(Tep::Notebook::Cell.new("train", :task, "toy train …",
                                    { "config" => "config" }, :expensive))
    doc.add(Tep::Notebook::Cell.new("figure", :prose, "loss curve",
                                    { "run" => "train" }))
    doc
  end

  def test_document_holds_ordered_cells
    doc = make_doc
    assert_equal %w[config train figure], doc.cells.map(&:id)
    assert_equal :task, doc.fetch("train").kind
    assert_nil doc.fetch("nope")
  end

  def test_explicit_inputs_give_the_dag
    doc = make_doc
    assert doc.fetch("train").depends_on?("config")
    refute doc.fetch("train").depends_on?("figure")
    assert_equal %w[train], doc.dependents_of("config").map(&:id)
    assert_equal %w[figure], doc.dependents_of("train").map(&:id)
  end

  def test_cost_class
    doc = make_doc
    assert doc.fetch("train").expensive?
    refute doc.fetch("figure").expensive?
  end

  def test_output_lifecycle_stream_then_terminal
    out = Tep::Notebook::Output.new
    assert_equal :pending, out.status
    refute out.finished?
    assert_equal 0, out.stream_length

    out.running!
    out.push({ "kind" => "step", "step" => 1, "loss" => 6.0 })
    out.push({ "kind" => "step", "step" => 2, "loss" => 5.5 })
    assert_equal :running, out.status
    assert_equal 2, out.stream_length
    steps = []
    out.each_event { |e| steps.push(e["step"]) }
    assert_equal [1, 2], steps

    out.finish!("text", "final loss 5.5")
    assert_equal :ok, out.status
    assert out.finished?
    assert_equal "text", out.terminal["type"]

    out.stale!
    assert_equal :stale, out.status
    assert out.finished?     # stale keeps the old terminal around
  end

  def test_to_html_renders_every_cell_with_escaping
    doc = make_doc
    doc.fetch("config").output.finish!("text", "parsed <ok> & loaded")
    html = doc.to_html
    assert_includes html, "<title>E0 smoke</title>"
    assert_includes html, 'id="cell-config"'
    assert_includes html, 'data-kind="task"'
    assert_includes html, 'data-cost="expensive"'
    assert_includes html, "parsed &lt;ok&gt; &amp; loaded"   # escaped terminal
    refute_includes html, "<ok>"
  end

  def test_html_terminal_embedded_raw
    doc = Tep::Notebook::Document.new("t")
    c = doc.add(Tep::Notebook::Cell.new("fig", :prose, "x"))
    c.output.finish!("html", "<svg/>")
    assert_includes doc.to_html, "<svg/>"
  end

  def test_seed_runs_clean
    assert require_relative("../lib/tep_notebook/seed")
  end
end
