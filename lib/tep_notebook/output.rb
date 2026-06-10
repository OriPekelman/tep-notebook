module Tep
  module Notebook
    # A cell's output: a (possibly empty) append-only stream of typed
    # events plus a terminal result (livebook DESIGN.md §3.2).
    #
    #   stream   — append-only events, each a string-keyed Hash tagged
    #              with a "kind" key (toy/v1's events.jsonl is an instance
    #              of this shape; the engine doesn't know that). Read via
    #              stream_length / each_event.
    #   terminal — final typed payload { "type" => "text"|"html"|"json"|
    #              "error"|…, "value" => String }; meaningful only once
    #              finished? is true (it is never nil — a nil|Hash union
    #              goes poly under Spinel and unresolves `[]`)
    #   status   — :pending | :running | :ok | :stale | :error
    #
    # Plain data, no transport: renderers/transports subscribe elsewhere.
    # Written in the conservative Spinel dialect (no String#<<, explicit
    # loops, concrete types, no metaprogramming) — tep's own house style.
    class Output
      attr_reader :terminal, :status

      def initialize
        # Lazy-typed stream: Spinel can't make an *empty* hash-array (a
        # bare [] infers int_array; poly_array has no pop/shift/slice!),
        # so slot 0 holds a placeholder until the first real push
        # replaces the whole array. @count is the source of truth.
        @stream = [make_terminal("", "")]
        @count = 0
        @terminal = make_terminal("", "")
        @finished = false
        @status = :pending
      end

      def running!
        @status = :running
        self
      end

      # Append one typed event to the stream.
      def push(event)
        if @count == 0
          @stream = [event]
        else
          @stream.push(event)
        end
        @count = @count + 1
        self
      end

      def stream_length
        @count
      end

      def each_event
        i = 0
        while i < @count
          yield @stream[i]
          i += 1
        end
        self
      end

      # Set the terminal payload and final status.
      def finish!(type, value, status = :ok)
        @terminal = make_terminal(type, value)
        @finished = true
        @status = status
        self
      end

      def stale!
        @status = :stale
        self
      end

      def finished?
        @finished
      end

      # The one literal site for the terminal hash — keeps its inferred
      # type a single concrete shape instead of a per-site union.
      def make_terminal(type, value)
        { "type" => type, "value" => value }
      end
    end
  end
end
