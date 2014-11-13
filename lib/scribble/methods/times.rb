module Scribble
  module Methods
    class Times < Block
      register :times, on: Fixnum

      def times
        render * @receiver
      end
    end
  end
end
