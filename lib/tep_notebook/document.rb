require_relative "cell"

module Tep
  module Notebook
    # An ordered collection of cells with a static HTML rendering — the
    # walking skeleton's "one trivial class" (DESIGN.md §7.4). Live
    # rendering (LiveView deltas) and the DAG/staleness engine come later;
    # this proves the model compiles and serves.
    class Document
      attr_reader :title, :cells

      def initialize(title)
        @title = title
        @cells = []
      end

      def add(cell)
        @cells.push(cell)
        cell
      end

      def fetch(id)
        found = nil
        @cells.each { |c| found = c if found.nil? && c.id == id }
        found
      end

      # Cells whose inputs name the given cell — the outgoing DAG edges.
      def dependents_of(id)
        out = []
        @cells.each { |c| out.push(c) if c.depends_on?(id) }
        out
      end

      # Minimal static HTML: one <section> per cell with its source,
      # stream length, and terminal payload. Deliberately unstyled.
      def to_html
        out = "<!doctype html><html><head><meta charset=\"utf-8\">"
        out = out + "<title>" + esc(@title) + "</title></head><body>"
        out = out + "<h1>" + esc(@title) + "</h1>"
        @cells.each { |c| out = out + cell_html(c) }
        out + "</body></html>"
      end

      def cell_html(c)
        h = "<section id=\"cell-" + esc(c.id) + "\" data-kind=\"" + c.kind.to_s +
            "\" data-cost=\"" + c.cost_class.to_s + "\">"
        h = h + "<h2>" + esc(c.id) + " <small>" + c.kind.to_s + " · " +
            c.cost_class.to_s + " · " + c.output.status.to_s + "</small></h2>"
        h = h + "<pre>" + esc(c.source) + "</pre>"
        n = c.output.stream_length
        if n > 0
          h = h + "<p>stream: " + n.to_s + " events</p>"
        end
        if c.output.finished?
          t = c.output.terminal
          ttype = t["type"].to_s
          tval  = t["value"].to_s
          h = h + "<div class=\"terminal\" data-type=\"" + esc(ttype) + "\">"
          h = h + (ttype == "html" ? tval : "<pre>" + esc(tval) + "</pre>")
          h = h + "</div>"
        end
        h + "</section>"
      end

      # HTML-escape & < > " — char-by-char (the Spinel dialect; same shape
      # as Tep::Url.unescape).
      def esc(s)
        str = s.to_s
        out = ""
        i = 0
        n = str.length
        while i < n
          ch = str[i]
          if ch == "&"
            out = out + "&amp;"
          elsif ch == "<"
            out = out + "&lt;"
          elsif ch == ">"
            out = out + "&gt;"
          elsif ch == "\""
            out = out + "&quot;"
          else
            out = out + ch
          end
          i += 1
        end
        out
      end
    end
  end
end
