module Scribble
  Registry.for TrueClass do
    method :equals,  TrueClass,  returns: true
    method :equals,  FalseClass, returns: false
    method :differs, TrueClass,  returns: false
    method :differs, FalseClass, returns: true
  end

  Registry.for FalseClass do
    method :equals,  TrueClass,  returns: false
    method :equals,  FalseClass, returns: true
    method :differs, TrueClass,  returns: true
    method :differs, FalseClass, returns: false
  end

  Registry.for TrueClass, FalseClass do
    name 'boolean'

    to_boolean { self }
    to_string  { to_s }

    # Logical operators
    method :or,  Object, to: ->(object) { self | Scribble::Registry.to_boolean(object) }
    method :and, Object, to: ->(object) { self & Scribble::Registry.to_boolean(object) }

    # Equality
    method :equals,  Object, returns: false
    method :differs, Object, returns: true

    # Unary not
    method :not, to: -> { !self }
  end
end
