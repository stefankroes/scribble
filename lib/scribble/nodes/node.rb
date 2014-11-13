module Scribble
  module Nodes
    class Node
      attr_reader :slice

      def initialize slice
        @slice = slice
      end

      def block?
        false
      end

      def split?
        false
      end

      def line_and_column
        line, column = slice.line_and_column
        "at line #{line} column #{column}"
      end
    end
  end
end
