module Scribble
  module Errors
    class Error < RuntimeError
    end

    class Syntax < Error
    end

    class Undefined < Error
    end

    class Arity < Error
    end

    class Argument < Error
    end

    class UnlocatedArgument < Error
    end

    class NotFound < Error
    end
  end
end
