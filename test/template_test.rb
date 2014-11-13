require_relative 'test_helper'

describe Scribble::Template do

  # Rendering

  it 'can be rendered multiple times' do
    template = Scribble::Template.new('Hello World')
    assert_equal 'Hello World', template.render
    assert_equal 'Hello World', template.render
    assert_equal 'Hello World', template.render
  end

  # Partial loading

  it "can't load partials without a loader" do
    assert_raises_message 'Cannot load partial' do
      Scribble::Template.new('Hello World').load 'some_partial', nil
    end
  end

  it "loads partials when it has a loader" do
    loader = MockLoader.new some_partial: ''
    assert_instance_of Scribble::Partial::Context, Scribble::Template.new('Hello World', loader: loader).load('some_partial', nil)
  end

  # Formats

  it "can't render in format without template format" do
    assert_raises_message 'Cannot convert to' do
      Scribble::Template.new('Hello World').render format: :render_format
    end
  end

  it "can't render in format without suitable converter" do
    assert_raises_message 'No suitable converter' do
      Scribble::Template.new('Hello World', format: :template_format).render format: :render_format
    end
  end

  it "won't need converter to render in template format" do
    assert_scribble_render 'Hello World', 'Hello World',
      format: :template_format, template: {format: :template_format}
  end

  it "renders in format when it has a template format and a suitable converter" do
    converter = MockConverter.new :template_format, :render_format
    assert_scribble_render 'Hello World', 'template_format > render_format(Hello World)',
      format: :render_format, template: {format: :template_format, converters: [converter]}
  end
end
