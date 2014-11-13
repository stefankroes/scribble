module Scribble
  Registry.for String do
    to_boolean { !empty? }
    to_string  { self }

    # Logical operators
    method :or,  Object, cast: 'to_boolean'
    method :and, Object, cast: 'to_boolean'

    # Equality
    method :equals,  String, as: '=='
    method :differs, String, as: '!='
    method :equals,  Object, returns: false
    method :differs, Object, returns: true

    # Unary operators
    method :not, cast: 'to_boolean'

    # Size and length
    method :size
    method :length
    method :empty, as: 'empty?'

    # Concatenation
    method :add,     Fixnum, to: ->(fixnum) { self + fixnum.to_s }
    method :add,     String, as: '+'
    method :append,  String, as: '+'
    method :prepend, String

    # Repetition
    method :multiply, Fixnum, to: ->(count) { Support::Utilities.repeat self, count }
    method :repeat,   Fixnum, to: ->(count) { Support::Utilities.repeat self, count }

    # Truncation
    method :truncate, Fixnum,               to: ->(length)           { Support::Utilities.truncate self, false, length, ' ...' }
    method :truncate, Fixnum, String,       to: ->(length, omission) { Support::Utilities.truncate self, false, length, omission }
    method :truncate_words, Fixnum,         to: ->(length)           { Support::Utilities.truncate self, true,  length, ' ...' }
    method :truncate_words, Fixnum, String, to: ->(length, omission) { Support::Utilities.truncate self, true,  length, omission }

    # Replacement
    method :replace,       String, String, to: ->(replace, with) { self.gsub replace, with }
    method :replace_first, String, String, to: ->(replace, with) { self.sub  replace, with }

    # Removal
    method :subtract,     String, to: ->(remove) { self.gsub remove, '' }
    method :remove,       String, to: ->(remove) { self.gsub remove, '' }
    method :remove_first, String, to: ->(remove) { self.sub  remove, '' }

    # Case manipulation
    method :capitalize
    method :upcase
    method :downcase

    # Reversal
    method :reverse

    # Whitespace removal
    method :strip
    method :strip_left,  as: 'lstrip'
    method :strip_right, as: 'rstrip'
  end
end
