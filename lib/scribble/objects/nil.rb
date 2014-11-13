module Scribble
  Registry.for NilClass do
    name 'nothing'

    to_boolean { false }
    to_string  { '' }

    # Logical operators
    method :or,  Object, cast: 'to_boolean'
    method :and, Object, cast: 'to_boolean'

    # Equality
    method :equals,  NilClass, returns: true
    method :differs, NilClass, returns: false
    method :equals,  Object, returns: false
    method :differs, Object, returns: true

    # Unary operators
    method :not, cast: 'to_boolean'
  end
end
