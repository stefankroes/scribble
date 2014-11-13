module Scribble
  module Nodes
    class Value < Node
      attr_reader :value

      def initialize slice, value
        super(slice)
        @value = value
      end

      def evaluate context, **options
        @value
      end
    end
  end
end
