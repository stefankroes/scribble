module Scribble
  module Parsing
    class Nester
      def initialize nodes
        @nodes = nodes
      end

      def nodes root = true
        [].tap do |nodes|
          while step(root)
            nodes << node
            if node.block?
              @current = node
              node.nodes = nodes false
            end
          end
        end
      end

    private

      def step root
        @cursor = @cursor ? @cursor + 1 : 0

        if node.is_a? Nodes::Ending
          raise unexpected_end if root
          false
        elsif node.nil?
          raise unexpected_eot unless root
          false
        else
          true
        end
      end

      def node
        @nodes[@cursor]
      end

      def unexpected_end
        Errors::Syntax.new "Unexpected 'end' #{node.line_and_column}; no block currently open"
      end

      def unexpected_eot
        Errors::Syntax.new "Unexpected end of template; unclosed '#{@current.name}' block #{@current.line_and_column}"
      end
    end
  end
end
