require_relative 'test_helper'

describe Scribble::Registry do
  before do
    @registry = Scribble::Registry.new
  end

  it 'gathers methods' do
    @registry.for String do
      method :foo
      method :bar
    end

    assert_equal 2, @registry.methods.size
    assert_equal [:foo, :bar], @registry.methods.map(&:method_name)
  end

  it 'gathers method signatures along with method names' do
    @registry.for String do
      method :foo, String
      method :bar, Fixnum, [String]
    end

    assert_equal [String],           @registry.methods[0].signature
    assert_equal [Fixnum, [String]], @registry.methods[1].signature
  end

  it 'gathers methods for multiple classes at once' do
    @registry.for TrueClass, FalseClass do
      method :foo
    end

    assert_equal 2, @registry.methods.size
    assert_equal [TrueClass, FalseClass], @registry.methods.map(&:receiver_class)
  end

  describe 'methods' do

    it 'calculates arity' do
      @registry.for String do
        method :foo
        method :bar, String, Fixnum
        method :baz, [String]
        method :qux, String, [String, 3]
      end

      assert_equal 0,   @registry.methods[0].min_arity
      assert_equal 0,   @registry.methods[0].max_arity
      assert_equal 2,   @registry.methods[1].min_arity
      assert_equal 2,   @registry.methods[1].max_arity
      assert_equal 0,   @registry.methods[2].min_arity
      assert_equal nil, @registry.methods[2].max_arity
      assert_equal 1,   @registry.methods[3].min_arity
      assert_equal 4,   @registry.methods[3].max_arity
    end
  end

  describe 'block and split' do

    it 'knows if names have block methods' do
      @registry.for String do
        method :foo
        method :bar, block: true
      end

      assert_equal false, @registry.block?(:foo)
      assert_equal true,  @registry.block?(:bar)
      assert_equal nil,   @registry.block?(:baz)
    end

    it 'knows if names have split methods' do
      @registry.for String do
        method :foo
        method :bar, split: true
      end

      refute @registry.split? :foo
      assert @registry.split? :bar
    end
  end

  describe 'Rails autoloading support' do

    it 'can unregister a method by class name' do
      class MyMethod < Scribble::Method
        def bar; end
        setup String, :bar, []
      end

      MyMethod.insert @registry

      @registry.for String do
        method :foo
        method :baz
      end

      assert_equal 3, @registry.methods.size

      @registry.unregister 'MyMethod'

      assert_equal 2, @registry.methods.size
      assert_equal [:foo, :baz], @registry.methods.map(&:method_name)
    end
  end

  describe 'evaluation' do

    it 'it delegates evaluation to matching methods' do
      @registry.for Fixnum do
        method :foo,                   returns: 0
        method :foo, String,           returns: 1
        method :foo, String, Fixnum,   returns: 2
        method :foo, Fixnum,           returns: 3
        method :foo, Fixnum, [String], returns: 4
        method :foo, [String, 2],      returns: 5
        method :foo, [String],         returns: 6
        method :foo, [String], Fixnum, returns: 7
        method :foo, [Object],         returns: 8
      end

      assert_equal 0, @registry.evaluate(:foo, 0, [])
      assert_equal 1, @registry.evaluate(:foo, 0, [''])
      assert_equal 2, @registry.evaluate(:foo, 0, ['', 0])
      assert_equal 3, @registry.evaluate(:foo, 0, [0])
      assert_equal 4, @registry.evaluate(:foo, 0, [0, ''])
      assert_equal 4, @registry.evaluate(:foo, 0, [0, '', ''])
      assert_equal 5, @registry.evaluate(:foo, 0, ['', ''])
      assert_equal 5, @registry.evaluate(:foo, 0, ['', ''])
      assert_equal 6, @registry.evaluate(:foo, 0, ['', '', ''])
      assert_equal 7, @registry.evaluate(:foo, 0, ['', '', 0])
      assert_equal 8, @registry.evaluate(:foo, 0, [false])
    end

    it 'raises an error when no method matches' do
      @registry.for String do
        method :add, String, to: ->(other) { self + other }
      end

      assert_raises(Scribble::Support::Unmatched) { @registry.evaluate :add, 'foo', [] }
      assert_raises(Scribble::Support::Unmatched) { @registry.evaluate :addd, 'foo', ['bar'] }
      assert_raises(Scribble::Support::Unmatched) { @registry.evaluate :add, 'foo', ['bar', 'baz'] }
      assert_raises(Scribble::Support::Unmatched) { @registry.evaluate :add, 'foo', [1] }
      assert_raises(Scribble::Support::Unmatched) { @registry.evaluate :add, 1, ['foo'] }
    end

    it 'provides different implementation options for methods' do
      @registry.for TrueClass do
        method :baz, Object, to: ->(object) { object }
      end

      @registry.for String do
        to_boolean { true }
        method :foo, Object, as: '=='
        method :bar, Object, to: ->(object) { object }
        method :baz, Object, cast: 'to_boolean'
        method :qux, Object, returns: 'qux'
      end

      assert_equal true,  @registry.evaluate(:foo, 'foo', ['foo'])
      assert_equal false, @registry.evaluate(:foo, 'foo', ['bar'])
      assert_equal 'baz', @registry.evaluate(:bar, 'foo', ['baz'])
      assert_equal 'baz', @registry.evaluate(:baz, 'foo', ['baz'])
      assert_equal 'qux', @registry.evaluate(:qux, 'foo', ['baz'])
    end

    it 'gathers and evaluates to_boolean cast methods' do
      @registry.for String do
        to_boolean { self == 'foo' }
      end

      @registry.for Fixnum do
        to_boolean { self > 0 }
      end

      assert_equal 2, @registry.methods.size

      assert_equal @registry.to_boolean('foo'), true
      assert_equal @registry.to_boolean('bar'), false
      assert_equal @registry.to_boolean(1), true
      assert_equal @registry.to_boolean(0), false
    end

    it 'gathers and evaluated to_string cast methods' do
      @registry.for String do
        to_string { self }
      end

      @registry.for Fixnum do
        to_string { to_s }
      end

      assert_equal 2, @registry.methods.size

      assert_equal @registry.to_string('foo'), 'foo'
      assert_equal @registry.to_string(12345), '12345'
    end
  end

  describe 'sanity checks' do

    it 'makes sure method names are symbols' do
      assert_raises_message(/needs to be a Symbol/) { @registry.for(String) { method 'foo' } }
    end

    it 'does not allow methods with duplicate class, name and signature' do
      @registry.for String do
        method :foo
        method :foo, String
        method :bar, String
      end

      @registry.for Fixnum do
        method :foo
      end

      assert_raises_message(/Duplicate method/) { @registry.for(String) { method :foo } }
      assert_raises_message(/Duplicate method/) { @registry.for(String) { method :bar, String } }
      assert_raises_message(/Duplicate method/) { @registry.for(Fixnum) { method :foo } }

      assert_equal 4, @registry.methods.size
    end

    it 'only allows a single implementation option per method' do
      assert_raises_message(/multiple implementation options/) { @registry.for(String) { method :foo, as: 'bar', to: -> {} } }
    end

    it 'checks the type of implementation options and split' do
      assert_raises_message(/requires String/) { @registry.for(String) { method :foo, as: :bar } }
      assert_raises_message(/requires Proc/)   { @registry.for(String) { method :foo, to: :bar } }
      assert_raises_message(/:cast must be/)   { @registry.for(String) { method :foo, cast: 'to_float' } }
      assert_raises_message(/:split must be/)  { @registry.for(String) { method :foo, split: :true } }
    end

    it 'requires methods with the same name to always or never be a block' do
      @registry.for String do
        method :foo
        method :bar, block: true
      end

      assert_raises_message(/must be a non-block/) { @registry.for(String) { method :foo, String, block: true } }
      assert_raises_message(/must be a block/)     { @registry.for(String) { method :bar, String } }

      assert_raises_message(/must be a non-block/) { @registry.for(Fixnum) { method :foo, block: true } }
      assert_raises_message(/must be a block/)     { @registry.for(Fixnum) { method :bar } }

      assert_equal 2, @registry.methods.size
    end

    it 'requires methods with the same name to always or never be splits' do
      @registry.for String do
        method :foo
        method :bar, split: true
      end

      assert_raises_message(/must be a non-split/) { @registry.for(String) { method :foo, String, split: true } }
      assert_raises_message(/must be a split/) { @registry.for(String) { method :bar, String } }

      assert_raises_message(/must be a non-split/) { @registry.for(Fixnum) { method :foo, split: true } }
      assert_raises_message(/must be a split/) { @registry.for(Fixnum) { method :bar } }

      assert_equal 2, @registry.methods.size
    end
  end
end
