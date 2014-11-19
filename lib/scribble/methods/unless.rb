module Scribble
  module Methods
    class Unless < Block
      register :unless, Object

      def unless object
        @paths = []
        send :elsif, !Registry.to_boolean(object)

        render(nodes: @paths.map { |condition, nodes| nodes if condition }.compact.first || [])
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
