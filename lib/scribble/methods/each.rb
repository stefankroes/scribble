module Scribble
  module Methods
    class Each < Block
      register :each, String, on: Enumerable

      def each name
        @receiver.map { |item|
          set_variable(name.to_sym, item)
          render
        }.join
      end
    end
  end
end
