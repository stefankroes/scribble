require_relative '../test_helper'

describe Scribble::Methods::Each do
  Book = Class.new(Struct.new(:author))

  it 'iterates over any enumerable' do
    Scribble::Registry.reset do
      Scribble::Registry.for Book do
        method :author
      end

      assert_scribble_render "{{ foobars.each 'item' }}{{item.author}} {{ end }}", "foo bar ", variables: { foobars: [Book.new("foo"), Book.new("bar")]}

      assert_scribble_render "{{ foobars.each 'item' }}{{item}} {{ end }}", "", variables: { foobars: [] }
      assert_scribble_render "{{ foobars.each 'item' }}{{item}} {{ end }}", "Foo ", variables: { foobars: ["Foo"]}
      assert_scribble_render "{{ foobars.each 'item' }}{{item}} {{ end }}", "Foo Bar ", variables: { foobars: ["Foo", "Bar"]}
      assert_scribble_render "{{ foobars.each 'item' }}{{item}} {{ end }}", "Foo Bar Baz ", variables: { foobars: ["Foo", "Bar", "Baz"]}
    end
  end
end
