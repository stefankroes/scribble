module Scribble
  module Methods
    class Unless < Block
      register :unless, Object

      def unless object
        @paths = []
        send :elsif, object

        nodes = @paths.each_with_index.map do |(condition, nodes), i|
          nodes if (i == 0 ? !condition : condition)
        end

        render(nodes: nodes.compact.first || [])
      end

      method :elsif, Object, split: true

      def elsif object
        @paths.unshift [Registry.to_boolean(object), split_nodes]
      end

      method :else, split: true

      def else
        @paths.unshift [true, nodes]
      end
    end
  end
end
