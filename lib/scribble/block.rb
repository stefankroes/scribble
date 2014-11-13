module Scribble
  class Block < Method
    include Support::Context

    def self.block?
      true
    end

    def nodes
      @nodes || @call.nodes
    end

    def split_nodes
      nodes.take_while.with_index do |node, index|
        if node.split?
          @nodes = nodes.drop index + 1
          node.evaluate self, allow_split: true, allow_block: false
          false
        else
          true
        end
      end
    end
  end
end
