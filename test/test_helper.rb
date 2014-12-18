require 'pry'
require 'minitest/autorun'

require_relative '../lib/scribble'

module MiniTest::Assertions
  def assert_scribble_parse source, serialized_transform
    assert_equal serialized_transform, serialize_transform(Scribble::Template.new(source).nodes)
  end

  def assert_scribble_render source, render_result, template: {}, **options
    assert_equal render_result, Scribble::Template.new(source, **template).render(options)
  end

  def assert_scribble_raises source, exception_class = Scribble::Errors::Undefined, message = nil, **options
    e = assert_raises exception_class do
      Scribble::Template.new(source).render(options)
    end
    assert_equal message, e.message unless message.nil?
  end

  def assert_raises_message regex, exception_class = RuntimeError, &block
    assert_match regex, assert_raises(exception_class, &block).message
  end

  def serialize_transform node = transform
    case node
    when Array                then node.map { |node| serialize_transform node }.join(', ')
    when Scribble::Nodes::Value  then node.value.is_a?(String) ? "'#{node.value}'" : node.value.inspect
    when Scribble::Nodes::Call
      call = node.name.to_s
      call = "#{serialize_transform(node.receiver)}.#{call}" if node.receiver
      call = "#{call}(#{serialize_transform node.args})"     unless node.allow_variable
      call = "#{call} { #{serialize_transform node.nodes} }" if node.nodes
      call
    else raise "Unable to serialize transform: #{node.inspect}"
    end
  end
end

class MockLoader
  def initialize partials
    @partials = partials
  end

  def load name
    source, format = @partials[name.to_sym]
    Scribble::Partial.new source, format: format
  end
end

MockConverter = Struct.new :from, :to do
  def convert source
    "#{from} > #{to}(#{source})"
  end
end

class Scribble::Registry
  def reset
    class_names, methods = @class_names.dup, @methods.dup
    yield
  ensure
    @class_names, @methods = class_names, methods
  end
end
