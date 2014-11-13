module Scribble
  Registry.for Fixnum do
    name 'number'

    to_boolean { !zero? }
    to_string  { to_s }

    # Logical operators
    method :or,  Object, cast: 'to_boolean'
    method :and, Object, cast: 'to_boolean'

    # Equality
    method :equals,  Fixnum, as: '=='
    method :differs, Fixnum, as: '!='
    method :equals,  Object, returns: false
    method :differs, Object, returns: true

    # Comparisons
    method :greater,          Fixnum, as: '>'
    method :greater_or_equal, Fixnum, as: '>='
    method :less,             Fixnum, as: '<'
    method :less_or_equal,    Fixnum, as: '<='

    # Calculations
    method :add,       Fixnum, as: '+'
    method :subtract,  Fixnum, as: '-'
    method :multiply,  Fixnum, as: '*'
    method :remainder, Fixnum, as: '%'

    method :divide,    Fixnum, to: ->(n) {
      begin
        self / n
      rescue ZeroDivisionError
        raise Errors::UnlocatedArgument.new "Division by zero"
      end
    }

    # Unary operators
    method :negative, to: -> { -self }
    method :not, cast: 'to_boolean'

    # String manipulations
    method :add,      String, cast: 'to_string'
    method :multiply, String, to: ->(string) { Support::Utilities.repeat string, self }

    # Unary methods
    method :abs
    method :odd,  as: 'odd?'
    method :even, as: 'even?'
    method :zero, as: 'zero?'
    method :nonzero,  to: -> { self != 0 }
  end
end
