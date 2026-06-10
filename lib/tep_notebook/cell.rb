require_relative "output"

module Tep
  module Notebook
    # One step of a document (livebook DESIGN.md §3.1).
    #
    #   id         — stable identity, survives edits/reorders (String)
    #   kind       — :prose | :value | :task (consumers may register more)
    #   source     — the editable content (String)
    #   inputs     — named bindings to other cells' outputs: the DAG edges
    #                ({ "name" => cell_id }); explicit, never inferred
    #   cost_class — :cheap (reactive) | :expensive (manual ▶)
    #   output     — current Output
    #
    # No fingerprint/staleness machinery yet — that's engine logic the
    # walking skeleton deliberately leaves out (DESIGN.md §7.4).
    class Cell
      attr_reader :id, :kind, :source, :inputs, :cost_class, :output

      def initialize(id, kind, source, inputs = {}, cost_class = :cheap)
        @id = id
        @kind = kind
        @source = source
        @inputs = inputs
        @cost_class = cost_class
        @output = Output.new
      end

      def expensive?
        @cost_class == :expensive
      end

      def depends_on?(cell_id)
        found = false
        @inputs.each { |_name, target| found = true if target == cell_id }
        found
      end
    end
  end
end
