module Scribble
  class Partial
    attr_reader :format

    def initialize source, format: nil
      @source, @format = source, format
    end

    # Parse and transform

    def parse
      @parse ||= Parsing::Parser.new.parse @source, reporter: Parsing::Reporter.new
    end

    def transform
      @transform ||= Parsing::Transform.new.apply parse
    end

    def nodes
      @nodes ||= transform.nodes
    end

    # Partial context

    class Context
      include Support::Context

      def initialize partial, context
        @partial, @context = partial, context
      end

      def nodes
        @partial.nodes
      end

      def format
        @partial.format || @context.format
      end
    end
  end
end
