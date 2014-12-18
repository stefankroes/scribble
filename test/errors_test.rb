require_relative 'test_helper'

describe Scribble do
  it 'provides syntax errors' do
    assert_scribble_raises '{{ + 1 }}',     Scribble::Errors::Syntax, "Unexpected '+' at line 1 column 4, expected '(', 'end', '}}' or a value"
    assert_scribble_raises '{{ 1 + }}',     Scribble::Errors::Syntax, "Unexpected '}' at line 1 column 8, expected '(' or a value"
    assert_scribble_raises '{{ 1 + ( ) }}', Scribble::Errors::Syntax, "Unexpected ')' at line 1 column 10, expected '(' or a value"
    assert_scribble_raises '{{ if',         Scribble::Errors::Syntax, "Unexpected end of template at line 1 column 6, expected '(', '}}' or an operator"
    assert_scribble_raises '{{ if {{',      Scribble::Errors::Syntax, "Unexpected '{' at line 1 column 7, expected '(', '}}', a value or an operator"
    assert_scribble_raises '{{ \' }} ',     Scribble::Errors::Syntax, "Unexpected end of template at line 1 column 9; unterminated string"
  end

  it 'provides syntax errors for inproper block nesting' do
    assert_scribble_raises '{{ if }}',      Scribble::Errors::Syntax, "Unexpected end of template; unclosed 'if' block at line 1 column 4"
    assert_scribble_raises '{{ end }}',     Scribble::Errors::Syntax, "Unexpected 'end' at line 1 column 4; no block currently open"
  end

  it 'provides syntax errors for unexpected split methods' do
    assert_scribble_raises '{{ if false }}{{ else }}{{ else }}{{ end }}', Scribble::Errors::Syntax, "Unexpected 'else' at line 1 column 28"
  end

  it 'provides syntax errors for unexpected block methods' do
    assert_scribble_raises '{{ if if false }}{{ end }}', Scribble::Errors::Syntax, "Unexpected 'if' at line 1 column 7; block methods can't be arguments"
  end

  it 'provides undefined errors' do
    assert_scribble_raises '{{ foo }}',         Scribble::Errors::Undefined, "Undefined variable or method 'foo' at line 1 column 4"
    assert_scribble_raises '{{ partial foo }}', Scribble::Errors::Undefined, "Undefined variable or method 'foo' at line 1 column 12"
    assert_scribble_raises '{{ foo() }}',       Scribble::Errors::Undefined, "Undefined method 'foo' at line 1 column 4"
    assert_scribble_raises '{{ foo 1 }}',       Scribble::Errors::Undefined, "Undefined method 'foo' at line 1 column 4"
  end

  it 'provides arity errors' do
    Scribble::Registry.reset do
      Scribble::Registry.for Fixnum do
        method :qux
        method :qux, Fixnum, String, [String, 1]
        method :qux, Fixnum, String, String, String, String, [Fixnum]
      end

      assert_scribble_raises '{{ partial }}', Scribble::Errors::Arity, "Wrong number of arguments (0 for 1-2) for 'partial' at line 1 column 4"
      assert_scribble_raises '{{ 0.add }}',   Scribble::Errors::Arity, "Wrong number of arguments (0 for 1) for 'add' at line 1 column 6"
      assert_scribble_raises '{{ 0.qux 0 }}', Scribble::Errors::Arity, "Wrong number of arguments (1 for 0, 2-3 or 5+) for 'qux' at line 1 column 6"
    end
  end

  it 'provides argument errors' do
    Scribble::Registry.reset do
      Scribble::Registry.for Fixnum do
        method :qux, [Fixnum], String
      end

      assert_scribble_raises '{{ partial 1 }}',   Scribble::Errors::Argument, "Expected string as 1st argument to 'partial', got number at line 1 column 12"
      assert_scribble_raises '{{ 0.qux 1 }}',     Scribble::Errors::Argument, "Expected string as 2nd argument to 'qux' at line 1 column 6"
      assert_scribble_raises "{{ 0.qux '', 1 }}", Scribble::Errors::Argument, "Unexpected 2nd argument to 'qux', got number at line 1 column 14"
    end
  end

  it 'provides specific argument errors with locations' do
    assert_scribble_raises "{{ '' * -1 }}",         Scribble::Errors::Argument, "Can't repeat string a negative number of times at line 1 column 7"
    assert_scribble_raises "{{ ''.truncate(-1) }}", Scribble::Errors::Argument, "Can't truncate string with a negative length at line 1 column 7"
    assert_scribble_raises "{{ 1 / 0 }}",           Scribble::Errors::Argument, 'Division by zero at line 1 column 6'
  end

  it 'combines errors generated in nested contexts' do
    Scribble::Registry.reset do
      class SomeBlock < Scribble::Block
        def foo; render; end; register :foo
        method :bar, Fixnum, returns: 'bar'
        method :baz, Fixnum, [Fixnum], returns: 'baz'
      end

      class SomeMethod < Scribble::Method
        def baz string; 'baz'; end; register :baz, String
      end

      assert_scribble_raises '{{ foo }}{{ bar }}{{ end }}',      Scribble::Errors::Arity, "Wrong number of arguments (0 for 1) for 'bar' at line 1 column 13"
      assert_scribble_raises '{{ foo }}{{ baz }}{{ end }}',      Scribble::Errors::Arity, "Wrong number of arguments (0 for 1 or 1+) for 'baz' at line 1 column 13"
      assert_scribble_raises '{{ foo }}{{ baz true }}{{ end }}', Scribble::Errors::Argument, "Expected string or number as 1st argument to 'baz', got boolean at line 1 column 17"
    end
  end

  it 'does not call split methods from a nested context' do
    Scribble::Registry.reset do
      class SomeBlock < Scribble::Block
        register :foo
        def foo; render; end
        method :bar, split: true
      end

      assert_scribble_raises '{{ foo }}{{ if true }}{{ bar }}{{ end }}{{ end }}', Scribble::Errors::Undefined, "Undefined variable or method 'bar' at line 1 column 26"
    end
  end

  it 'raises the proper errors when objects do not support cast methods' do
    assert_scribble_raises '{{ no_to_string }}',                                    RuntimeError, "Cannot cast 'Object' to string",  variables: {no_to_string: Object.new}
    assert_scribble_raises '{{ if true }}{{ no_to_string }}{{ end }}',              RuntimeError, "Cannot cast 'Object' to string",  variables: {no_to_string: Object.new}
    assert_scribble_raises '{{ if no_to_boolean }}{{ end }}',                       RuntimeError, "Cannot cast 'Object' to boolean", variables: {no_to_boolean: Object.new}
    assert_scribble_raises '{{ if true }}{{ if no_to_boolean }}{{ end }}{{ end }}', RuntimeError, "Cannot cast 'Object' to boolean", variables: {no_to_boolean: Object.new}
  end
end
